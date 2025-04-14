import 'package:flutter/material.dart';

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

    return GestureDetector(
      onPanStart: (details) {
        _isDragging = true;
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition = renderBox.globalToLocal(details.globalPosition) - center;

        // 限制在圆形范围内
        final distance = localPosition.distance;
        if (distance > radius) {
          _position = localPosition * (radius / distance);
        } else {
          _position = localPosition;
        }

        _updateNormalizedPosition();
        setState(() {});
      },
      onPanUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition = renderBox.globalToLocal(details.globalPosition) - center;

        // 限制在圆形范围内
        final distance = localPosition.distance;
        if (distance > radius) {
          _position = localPosition * (radius / distance);
        } else {
          _position = localPosition;
        }

        _updateNormalizedPosition();
        setState(() {});
      },
      onPanEnd: (details) {
        _isDragging = false;
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
            // 弧光效果
            if (_isDragging || _position != Offset.zero)
              Positioned.fill(
                child: CustomPaint(
                  painter: ArcPainter(
                    angle: _arcAngle,
                    color: widget.arcColor,
                    radius: radius,
                  ),
                ),
              ),
            // 中心键
            Positioned(
              left: radius + _position.dx - 20,
              top: radius + _position.dy - 20,
              child: Container(
                width: 40,
                height: 40,
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

class ArcPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double radius;

  ArcPainter({required this.angle, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arcRadius = radius - 5; // 稍微小于外圆

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // 计算弧的起始和结束角度
    final startAngle = angle - 0.3;
    final sweepAngle = 0.6; // 弧的角度范围

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ArcPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
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