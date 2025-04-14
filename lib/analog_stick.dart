import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnalogStick extends StatefulWidget {
  final Function(Offset)? onPositionChanged;
  final double size;
  final Color backgroundColor;
  final Color knobColor;
  final Color arcColor;

  const AnalogStick({
    Key? key,
    this.onPositionChanged,
    this.size = 150,
    this.backgroundColor = const Color(0xFFAAAAAA),
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
    _normalizedPosition = Offset(
      _position.dx / (widget.size / 2),
      _position.dy / (widget.size / 2),
    );

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
    final knobSize = 40.0;
    final knobRadius = knobSize / 2;
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
            // 方向键指示
            Positioned.fill(
              child: DirectionIndicators(
                color: widget.arcColor.withOpacity(0.5),
              ),
            ),
            // 弧光效果 - 改进为更柔和的效果
            if (_isDragging || _position != Offset.zero)
              Positioned.fill(
                child: CustomPaint(
                  painter: SoftArcPainter(
                    angle: _arcAngle,
                    color: widget.arcColor,
                    radius: radius,
                  ),
                ),
              ),
            // 中心键
            Positioned(
              left: radius + _position.dx - knobRadius,
              top: radius + _position.dy - knobRadius,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  color: widget.knobColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 替换原来的ArcPainter为更柔和的版本
class SoftArcPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double radius;

  SoftArcPainter({required this.angle, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arcRadius = radius - 5; // 稍微小于外圆

    // 使用渐变色和更宽的线条实现柔和效果
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0) // 添加模糊效果
      ..shader = RadialGradient(
        colors: [
          color,
          color.withOpacity(0.3),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: arcRadius));

    // 计算弧的起始和结束角度
    final startAngle = angle - 0.4;
    final sweepAngle = 0.8; // 稍微扩大弧的角度范围

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(SoftArcPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
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
    final indicatorSize = 12.0;
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