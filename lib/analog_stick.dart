import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmbodyColor {
  static const Color primary = Color.fromRGBO(64, 156, 255, 1.0);
  static const Color background = Color.fromRGBO(56, 56, 58, 1.0);
}

class DualAnalogStick extends StatefulWidget {
  final Function(Map<String, dynamic>)? onControlChanged;

  const DualAnalogStick({
    super.key,
    this.onControlChanged,
  });

  @override
  State<DualAnalogStick> createState() => _DualAnalogStickState();
}

class _DualAnalogStickState extends State<DualAnalogStick> {
  Offset _leftStickValue = Offset.zero;
  Offset _rightStickValue = Offset.zero;

  Map<String, dynamic> _generateControlMessage() {
    return {
      "linear": {
        "x": _leftStickValue.dy.toStringAsFixed(2),
        "y": _leftStickValue.dx.toStringAsFixed(2),
        "z": "0.00"
      },
      "angular": {
        "x": _rightStickValue.dy.toStringAsFixed(2),
        "y": "0.00",
        "z": _rightStickValue.dx.toStringAsFixed(2)
      }
    };
  }

  void _handleLeftStickChanged(Offset offset) {
    setState(() {
      _leftStickValue = offset;
    });
    if (widget.onControlChanged != null) {
      widget.onControlChanged!(_generateControlMessage());
    }
  }

  void _handleRightStickChanged(Offset offset) {
    setState(() {
      _rightStickValue = offset;
    });
    if (widget.onControlChanged != null) {
      widget.onControlChanged!(_generateControlMessage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AnalogStick(onPositionChanged: _handleLeftStickChanged),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnalogStick(onPositionChanged: _handleRightStickChanged),
          ),
        ],
      ),
    );
  }
}

class AnalogStick extends StatefulWidget {
  final Function(Offset)? onPositionChanged;
  final bool enableHapticFeedback;

  const AnalogStick({
    super.key,
    this.onPositionChanged,
    this.enableHapticFeedback = true,
  });

  @override
  State<AnalogStick> createState() => _AnalogStickState();
}

class _AnalogStickState extends State<AnalogStick>
    with SingleTickerProviderStateMixin {
  final double _size = 120;

  Offset _position = Offset.zero;
  Offset _normalizedPosition = Offset.zero;
  Offset _initialTouchPosition = Offset.zero;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  double _arcAngle = 0;

  final double _moveThreshold = 5.0;
  bool _hasMoved = false;
  bool _isDragging = false;
  bool _reachedEdge = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animation.addListener(() {
      setState(() {
        _position = _animation.value;
        // No need to notify external during animation, just update internal state
        _updateNormalizedPositionInternal();
      });
    });
  }

  // Internal update method that doesn't notify external
  void _updateNormalizedPositionInternal() {
    const knobRadius = 33.0;
    final maxDistance = (_size / 2) - knobRadius;

    final distance = _position.distance;
    final angle = _position.direction;

    final normalizedDistance = math.min(distance / maxDistance, 1.0);

    if (_position != Offset.zero) {
      final dx = normalizedDistance * math.cos(angle);
      final dy = -normalizedDistance * math.sin(angle); // 保持Y轴反转

      final maxComponent = math.max(dx.abs(), dy.abs());
      if (maxComponent > 0) {
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
  }

  // Original method remains but only called during dragging
  void _updateNormalizedPosition() {
    _updateNormalizedPositionInternal();

    // Notify position change - only notify external during dragging
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
      // Send a zero position before starting the animation
      if (widget.onPositionChanged != null && _position != Offset.zero) {
        widget.onPositionChanged!(Offset.zero);
      }

      _animation = Tween<Offset>(begin: _position, end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ),
      );
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
        _initialTouchPosition =
            renderBox.globalToLocal(details.globalPosition) - center;
        setState(() {});
      },
      onPanUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition =
            renderBox.globalToLocal(details.globalPosition) - center;

        // 移除这行
        // final invertedPosition = Offset(localPosition.dx, -localPosition.dy);

        // Calculate movement distance and check if it exceeds the threshold
        final moveDistance = (_initialTouchPosition - localPosition).distance;
        if (!_hasMoved && moveDistance > _moveThreshold) {
          _hasMoved = true;
        }

        // Only update position when movement is confirmed
        if (_hasMoved) {
          // Limit within circular range, considering the size of center knob
          final distance = localPosition.distance;

          if (widget.enableHapticFeedback &&
              distance > maxKnobDistance * 0.95 &&
              !_reachedEdge) {
            HapticFeedback.mediumImpact();
            _reachedEdge = true;
          } else if (distance <= maxKnobDistance * 0.9) {
            _reachedEdge = false;
          }

          if (distance > maxKnobDistance) {
            _position = localPosition *
                (maxKnobDistance /
                    distance); // 使用localPosition而不是invertedPosition
          } else {
            _position = localPosition; // 使用localPosition而不是invertedPosition
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
          color: EmbodyColor.background.withAlpha(128),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Positioned.fill(child: buildDirectionIndicators()),
            if (_isDragging && _position != Offset.zero)
              Positioned.fill(child: ImageArc(angle: _arcAngle)),
            Positioned(
              left: radius + _position.dx - knobRadius,
              top: radius + _position.dy - knobRadius,
              child: Image.asset(
                'assets/images/analog_stick/center.png',
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

Widget buildDirectionIndicators() {
  final indicators = [
    {'alignment': Alignment(0, -0.88), 'angle': 0.0},
    {'alignment': Alignment(0.88, 0), 'angle': math.pi/2},
    {'alignment': Alignment(0, 0.88), 'angle': math.pi},
    {'alignment': Alignment(-0.88, 0), 'angle': -math.pi/2},
  ];

  return Stack(
    children: indicators.map((indicator) {
      return Align(
        alignment: indicator['alignment'] as Alignment,
        child: Transform.rotate(
          angle: indicator['angle'] as double,
          child: Image.asset(
            'assets/images/analog_stick/arrow_up.png',
            width: 18,
            height: 18,
          ),
        ),
      );
    }).toList(),
  );
}
}

class ImageArc extends StatelessWidget {
  final double angle;
  const ImageArc({super.key, required this.angle});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SoftArcPainter(
        angle: angle,
        color: EmbodyColor.primary,
        radius: 60,
      ),
    );
  }
}

class SoftArcPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double radius;

  SoftArcPainter({
    required this.angle,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use cached calculation results
    final center = Offset(size.width / 2, size.height / 2);
    final arcRadius = radius - 2;

    final startAngle = angle - (45 * math.pi / 180);
    const sweepAngle = 0.25 * 2 * math.pi;

    final startPoint = calculatePointOnCircle(center, arcRadius, startAngle);
    final endPoint =
        calculatePointOnCircle(center, arcRadius, startAngle + sweepAngle);

    // Create a paint with gradient
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Use gradient from start to end point
    gradientPaint.shader = ui.Gradient.linear(
      startPoint,
      endPoint,
      [
        EmbodyColor.primary.withAlpha(0), // Start point transparent
        EmbodyColor.primary.withAlpha(200), // Mid point semi-transparent
        EmbodyColor.primary.withAlpha(0), // End point transparent
      ],
      [0.0, 0.5, 1.0],
    );

    // Draw arc glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      gradientPaint,
    );

    // Add glow effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90.0);

    // Use same gradient
    glowPaint.shader = gradientPaint.shader;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  Offset calculatePointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(SoftArcPainter oldDelegate) {
    return oldDelegate.angle != angle; // Only repaint when angle changes
  }
}
