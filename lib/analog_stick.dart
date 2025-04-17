import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnalogStick extends StatefulWidget {
  final Function(Offset)? onPositionChanged;
  final bool enableHapticFeedback;

  static const String centerImagePath = 'assets/images/analogstick/center.png';
  static const String arrowImagePath = 'assets/images/analogstick/arrow_up.png';
  static const String arcImagePath = 'assets/images/analogstick/arc.png';

  const AnalogStick({
    Key? key,
    this.onPositionChanged,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<AnalogStick> createState() => _AnalogStickState();
}

class _AnalogStickState extends State<AnalogStick> with SingleTickerProviderStateMixin {
  double _size = 120;
  Offset _position = Offset.zero;
  Offset _normalizedPosition = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  double _arcAngle = 0;
  Offset _initialTouchPosition = Offset.zero;
  double _moveThreshold = 5.0;
  bool _hasMoved = false;
  bool _reachedEdge = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animation.addListener(() {
      setState(() {
        _position = _animation.value;
        // 动画过程中不需要通知外部，只需要更新内部状态
        _updateNormalizedPositionInternal();
      });
    });
  }

  // 添加一个不通知外部的内部更新方法
  void _updateNormalizedPositionInternal() {
    const knobRadius = 33.0;
    final maxDistance = (_size / 2) - knobRadius;

    // 计算当前位置的距离和角度
    final distance = _position.distance;
    final angle = _position.direction;

    // 计算归一化距离 (0.0 到 1.0)
    final normalizedDistance = math.min(distance / maxDistance, 1.0);

    // 使用极坐标转换为笛卡尔坐标
    // 但我们需要确保在对角线方向上也能达到最大值
    // 例如，当摇杆在45度角方向上达到边缘时，x和y应该都是1.0而不是0.7071

    // 直接映射到[-1,1]x[-1,1]的正方形
    if (_position != Offset.zero) {
      // 保持方向不变，但确保在任何方向上都能达到最大值
      final dx = normalizedDistance * math.cos(angle);
      final dy = normalizedDistance * math.sin(angle);

      // 计算最大分量
      final maxComponent = math.max(dx.abs(), dy.abs());
      if (maxComponent > 0) {
        // 按最大分量缩放，确保最大分量为1.0
        final scale = normalizedDistance / maxComponent;
        _normalizedPosition = Offset(dx * scale, dy * scale);
      } else {
        _normalizedPosition = Offset.zero;
      }
    } else {
      _normalizedPosition = Offset.zero;
    }

    if (_position != Offset.zero) {
      _arcAngle = angle;
    }
    // 不通知外部
  }

  // 原方法保持不变，但只在拖动时调用
  void _updateNormalizedPosition() {
    _updateNormalizedPositionInternal();

    // 通知位置变化 - 只在拖动状态下才通知外部
    if (widget.onPositionChanged != null && _isDragging) {
      widget.onPositionChanged!(_normalizedPosition);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetKnobPosition() {
    if (!_isDragging) {
      // 在动画开始前先发送一次零位置
      if (widget.onPositionChanged != null && _position != Offset.zero) {
        widget.onPositionChanged!(Offset.zero);
      }

      _animation = Tween<Offset>(
        begin: _position,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = _size / 2;
    const double knobSize = 33.0;
    const double knobRadius = knobSize / 2;
    final maxKnobDistance = radius - knobRadius;

    return GestureDetector(
      onPanStart: (details) {
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        _isDragging = true;
        _hasMoved = false;
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        _initialTouchPosition = renderBox.globalToLocal(details.globalPosition) - center;
        setState(() {});
      },

      onPanUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition = renderBox.globalToLocal(details.globalPosition) - center;

        // 计算移动距离，判断是否超过阈值
        final moveDistance = (_initialTouchPosition - localPosition).distance;
        if (!_hasMoved && moveDistance > _moveThreshold) {
          _hasMoved = true;
        }

        // 只有当确认移动时才更新位置
        if (_hasMoved) {
          // 限制在圆形范围内，考虑中心键的大小
          final distance = localPosition.distance;

          if (widget.enableHapticFeedback && distance > maxKnobDistance * 0.95 && !_reachedEdge) {
            HapticFeedback.mediumImpact();
            _reachedEdge = true;
          } else if (distance <= maxKnobDistance * 0.9) {
            _reachedEdge = false;
          }

          if (distance > maxKnobDistance) {
            _position = localPosition * (maxKnobDistance / distance);
          } else {
            _position = localPosition;
          }

          _updateNormalizedPosition();
        }

        setState(() {});
      },
      onPanEnd: (details) {
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        _isDragging = false;
        _hasMoved = false;
        _reachedEdge = false;
        _resetKnobPosition();
      },
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: Color(0x8038383A),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageDirectionIndicators(),
            ),
            if (_isDragging && _position != Offset.zero)
              Positioned.fill(
                child: ImageArc(
                  angle: _arcAngle,
                ),
              ),
            Positioned(
              left: radius + _position.dx - knobRadius,
              top: radius + _position.dy - knobRadius,
              child: Image.asset(
                AnalogStick.centerImagePath,
                width: knobSize,
                height: knobSize,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageArc extends StatelessWidget {
  final double angle;
  const ImageArc({Key? key, required this.angle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SoftArcPainter(
        angle: angle,
        color: const Color(0xFF409CFF),
        radius: 60,
      ),
    );
  }
}

enum DirectionPosition { top, right, bottom, left }

class ImageDirectionIndicators extends StatelessWidget {
  const ImageDirectionIndicators({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final directions = [
      {'position': DirectionPosition.top, 'angle': 0.0},
      {'position': DirectionPosition.right, 'angle': math.pi / 2},
      {'position': DirectionPosition.bottom, 'angle': math.pi},
      {'position': DirectionPosition.left, 'angle': -math.pi / 2},
    ];

    return Stack(
      children: directions.map((direction) {
        final position = direction['position'] as DirectionPosition;
        final angle = direction['angle'] as double;

        return _positionArrow(position, angle);
      }).toList(),
    );
  }

  Widget _positionArrow(DirectionPosition position, double angle) {
    switch(position) {
      case DirectionPosition.top:
        return Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(child: _buildRotatedArrow(angle)),
        );
      case DirectionPosition.right:
        return Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(child: _buildRotatedArrow(angle)),
        );
      case DirectionPosition.bottom:
        return Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(child: _buildRotatedArrow(angle)),
        );
      case DirectionPosition.left:
        return Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: Center(child: _buildRotatedArrow(angle)),
        );
    }
  }

  Widget _buildRotatedArrow(double angle) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        AnalogStick.arrowImagePath,
        width: 18,
        height: 18,
      ),
    );
  }
}

class SoftArcPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double radius;

  SoftArcPainter({required this.angle, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    // 使用缓存的计算结果
    final center = Offset(size.width / 2, size.height / 2);
    final arcRadius = radius - 2;

    final startAngle = angle - (45 * math.pi / 180);
    const sweepAngle = 0.25 * 2 * math.pi;

    final startPoint = _calculatePointOnCircle(center, arcRadius, startAngle);
    final endPoint = _calculatePointOnCircle(center, arcRadius, startAngle + sweepAngle);

    // 创建一个带有渐变的画笔
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // 使用从起点到终点的渐变
    gradientPaint.shader = ui.Gradient.linear(
      startPoint,
      endPoint,
      [
        const Color(0x00409CFF), // 起点透明
        const ui.Color(0xCC409CFF), // 中点半透明
        const Color(0x00409CFF), // 终点透明
      ],
      [0.0, 0.5, 1.0],
    );

    // 绘制弧光
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      gradientPaint,
    );

    // 添加发光效果
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90.0);

    // 使用相同的渐变
    glowPaint.shader = gradientPaint.shader;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  Offset _calculatePointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle)
    );
  }

  @override
  bool shouldRepaint(SoftArcPainter oldDelegate) {
    return oldDelegate.angle != angle; // 只有角度变化时才重绘
  }
}

class DualAnalogStickController extends StatelessWidget {
  final Function(Offset)? onLeftStickChanged;
  final Function(Offset)? onRightStickChanged;

  const DualAnalogStickController({
    Key? key,
    this.onLeftStickChanged,
    this.onRightStickChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AnalogStick(
              onPositionChanged: onLeftStickChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnalogStick(
              onPositionChanged: onRightStickChanged,
            ),
          ),
        ],
      ),
    );
  }
}