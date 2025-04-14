import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class AnalogStick extends StatefulWidget {
  final Function(Offset)? onPositionChanged;
  final double size;
  final Color backgroundColor;
  final Color knobColor;
  final Color arcColor;

  // 添加静态变量统一管理图片资源路径
  static const String centerImagePath = 'assets/images/analogstick/center.png';
  static const String arrowImagePath = 'assets/images/analogstick/arrow_up.png';
  static const String arcImagePath = 'assets/images/analogstick/arc.png';

  const AnalogStick({
    Key? key,
    this.onPositionChanged,
    this.size = 120,
    this.backgroundColor = const Color(0x8038383A),
    this.knobColor = const Color(0xFFCCCCCC),
    this.arcColor = Colors.blue,
  }) : super(key: key);

  @override
  State<AnalogStick> createState() => _AnalogStickState();
}

class _AnalogStickState extends State<AnalogStick> with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  Offset _normalizedPosition = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  double _arcAngle = 0;
  Offset _initialTouchPosition = Offset.zero; // 添加初始触摸位置
  bool _hasMoved = false; // 添加是否已移动的标志

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
        _updateNormalizedPosition();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateNormalizedPosition() {
    // 计算相对于中心的归一化坐标 (-1,-1) 到 (1,1)
    // 问题在这里：需要考虑中心键的半径对最大距离的影响
    const knobRadius = 33.0; // 中心键半径
    final maxDistance = (widget.size / 2) - knobRadius; // 考虑中心键半径的最大距离

    _normalizedPosition = Offset(
      _position.dx / maxDistance, // 使用修正后的最大距离
      _position.dy / maxDistance, // 使用修正后的最大距离
    );

    // 确保归一化值不超过 1
    if (_normalizedPosition.distance > 1.0) {
      _normalizedPosition = _normalizedPosition / _normalizedPosition.distance;
    }

    // 计算弧光角度
    if (_position != Offset.zero) {
      _arcAngle = _normalizedPosition.direction;
    }

    // 通知位置变化
    if (widget.onPositionChanged != null) {
      widget.onPositionChanged!(_normalizedPosition);
    }
  }

  void _resetKnobPosition() {
    if (!_isDragging) {
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
    final radius = widget.size / 2;
    const knobSize = 33.0;
    const knobRadius = knobSize / 2;
    final maxKnobDistance = radius - knobRadius;

    return GestureDetector(
      onPanStart: (details) {
        _isDragging = true;
        _hasMoved = false; // 重置移动标志
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        _initialTouchPosition = renderBox.globalToLocal(details.globalPosition) - center;

        // 初始时不移动中心键，保持在原位
        setState(() {});
      },
      onPanUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition = renderBox.globalToLocal(details.globalPosition) - center;

        // 计算移动距离，判断是否超过阈值
        final moveDistance = (_initialTouchPosition - localPosition).distance;
        if (!_hasMoved && moveDistance > 5.0) { // 5.0是移动阈值，可以调整
          _hasMoved = true;
        }

        // 只有当确认移动时才更新位置
        if (_hasMoved) {
          // 限制在圆形范围内，考虑中心键的大小
          final distance = localPosition.distance;
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
        _isDragging = false;
        _hasMoved = false;
        _resetKnobPosition();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            // 使用图片替代方向键指示器
            Positioned.fill(
              child: ImageDirectionIndicators(),
            ),
            // 使用图片替代弧光效果
            if (_isDragging || _position != Offset.zero)
              Positioned.fill(
                child: ImageArc(
                  angle: _arcAngle,
                ),
              ),
            // 中心键 - 使用图片替代
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

// 使用图片的弧光组件
class ImageArc extends StatelessWidget {
  final double angle;

  const ImageArc({Key? key, required this.angle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 直接使用SoftArcPainter绘制弧光
    return CustomPaint(
      painter: SoftArcPainter(
        angle: angle,
        color: const Color(0xFF409CFF),
        radius: 60,
      ),
    );
  }
}

// 使用图片的方向指示器组件 - 优化逻辑
class ImageDirectionIndicators extends StatelessWidget {
  const ImageDirectionIndicators({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 定义方向和对应的角度
    final directions = [
      {'position': 'top', 'angle': 0.0},
      {'position': 'right', 'angle': math.pi / 2},
      {'position': 'bottom', 'angle': math.pi},
      {'position': 'left', 'angle': -math.pi / 2},
    ];

    return Stack(
      children: directions.map((direction) {
        // 根据方向确定位置
        Widget positionedArrow;

        switch(direction['position']) {
          case 'top':
            positionedArrow = Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: _buildRotatedArrow(direction['angle'] as double),
              ),
            );
            break;
          case 'right':
            positionedArrow = Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildRotatedArrow(direction['angle'] as double),
              ),
            );
            break;
          case 'bottom':
            positionedArrow = Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: _buildRotatedArrow(direction['angle'] as double),
              ),
            );
            break;
          case 'left':
            positionedArrow = Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildRotatedArrow(direction['angle'] as double),
              ),
            );
            break;
          default:
            positionedArrow = const SizedBox();
        }

        return positionedArrow;
      }).toList(),
    );
  }

  // 构建旋转的箭头
  Widget _buildRotatedArrow(double angle) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        AnalogStick.arrowImagePath,
        width: 20,
        height: 20,
      ),
    );
  }
}

// 替换原来的ArcPainter为带有渐变效果的版本
class SoftArcPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double radius;

  SoftArcPainter({required this.angle, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arcRadius = radius - 2; // 将半径调整得更接近边缘，从-5改为-2

    // 计算弧的起始和结束角度
    // Start -45° 相对于当前角度
    final startAngle = angle - (45 * math.pi / 180); // -45度转换为弧度
    // Sweep 25% 对应90度 (360度的25%)
    final sweepAngle = 0.25 * 2 * math.pi; // 90度转换为弧度

    // 计算弧的中点角度
    final midAngle = startAngle + sweepAngle / 2;

    // 计算弧上的三个点：起点、中点和终点
    final startPoint = Offset(
      center.dx + arcRadius * math.cos(startAngle),
      center.dy + arcRadius * math.sin(startAngle)
    );

    final midPoint = Offset(
      center.dx + arcRadius * math.cos(midAngle),
      center.dy + arcRadius * math.sin(midAngle)
    );

    final endPoint = Offset(
      center.dx + arcRadius * math.cos(startAngle + sweepAngle),
      center.dy + arcRadius * math.sin(startAngle + sweepAngle)
    );

    // 创建一个带有渐变的画笔
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // 使用从起点到终点的渐变
    gradientPaint.shader = ui.Gradient.linear(
      startPoint,
      endPoint,
      [
        const Color(0x00409CFF), // 起点透明
        const Color(0xFF409CFF), // 中点不透明
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
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

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

  @override
  bool shouldRepaint(SoftArcPainter oldDelegate) {
    return oldDelegate.angle != angle; // 只有角度变化时才重绘
  }
}

// 新增方向指示器组件
class DirectionIndicators extends StatelessWidget {
  final Color color;

  const DirectionIndicators({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DirectionIndicatorPainter(color: color),
    );
  }
}

class DirectionIndicatorPainter extends CustomPainter {
  final Color color;

  DirectionIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const indicatorSize = 12.0;
    final distance = radius * 0.7; // 方向键到中心的距离

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 上方向键
    _drawTriangle(
      canvas,
      center + Offset(0, -distance),
      indicatorSize,
      0, // 向上
      paint
    );

    // 右方向键
    _drawTriangle(
      canvas,
      center + Offset(distance, 0),
      indicatorSize,
      math.pi / 2, // 向右
      paint
    );

    // 下方向键
    _drawTriangle(
      canvas,
      center + Offset(0, distance),
      indicatorSize,
      math.pi, // 向下
      paint
    );

    // 左方向键
    _drawTriangle(
      canvas,
      center + Offset(-distance, 0),
      indicatorSize,
      -math.pi / 2, // 向左
      paint
    );
  }

  void _drawTriangle(Canvas canvas, Offset center, double size, double rotation, Paint paint) {
    final path = Path();

    // 创建一个三角形
    path.moveTo(center.dx, center.dy - size / 2);
    path.lineTo(center.dx - size / 2, center.dy + size / 2);
    path.lineTo(center.dx + size / 2, center.dy + size / 2);
    path.close();

    // 旋转画布
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // 绘制三角形
    canvas.drawPath(path, paint);

    // 恢复画布
    canvas.restore();
  }

  @override
  bool shouldRepaint(DirectionIndicatorPainter oldDelegate) {
    return oldDelegate.color != color;
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