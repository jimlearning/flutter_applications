import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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

  Timer? _updateTimer;
  final Duration _updateInterval = const Duration(milliseconds: 100);
  bool _needsUpdate = false;

  @override
  void initState() {
    super.initState();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      final bool shouldSend = _needsUpdate && widget.onControlChanged != null;

      if (shouldSend) {
        widget.onControlChanged!(_generateControlMessage());
        _needsUpdate = false;
      }
    });
  }

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
    if (_leftStickValue != offset) {
      _leftStickValue = offset;
      _needsUpdate = true;
    }
  }

  void _handleRightStickChanged(Offset offset) {
    if (_rightStickValue != offset) {
      _rightStickValue = offset;
      _needsUpdate = true;
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
            child: AnalogStick(
                key: const ValueKey('left_stick'),
                onPositionChanged: _handleLeftStickChanged),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnalogStick(
                key: const ValueKey('right_stick'),
                onPositionChanged: _handleRightStickChanged),
          ),
        ],
      ),
    );
  }
}

class AnalogStick extends StatefulWidget {
  final Function(Offset)? onPositionChanged;

  const AnalogStick({
    super.key,
    this.onPositionChanged,
  });

  @override
  State<AnalogStick> createState() => _AnalogStickState();
}

class _AnalogStickState extends State<AnalogStick>
    with SingleTickerProviderStateMixin {
  final double _size = 120;
  static const double _knobSize = 33.0;
  static const double _knobRadius = _knobSize / 2;

  Offset _position = Offset.zero;
  Offset _normalizedPosition = Offset.zero;
  Offset _lastStablePosition = Offset.zero;
  double _arcAngle = 0;

  bool _isDragging = false;
  int? _pointerId;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

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
      if (mounted) {
        setState(() {
          _position = _animation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _pointerId = null;
    _animationController.dispose();
    super.dispose();
  }

  void _calculateNormalizedPosition() {
    final maxDistance = (_size / 2) - _knobRadius;

    final distance = _position.distance;
    final angle = _position.direction;

    // Clamp distance to maxDistance and normalize (0.0 to 1.0)
    final normalizedDistance = math.min(distance / maxDistance, 1.0);

    if (_position != Offset.zero) {
      // Calculate components based on normalized distance and angle
      // Note: Y-axis is inverted for screen coordinates (dy is negative for up)
      final dx = normalizedDistance * math.cos(angle);
      final dy = -normalizedDistance * math.sin(angle);

      // This scaling ensures the output vector stays within a square boundary [-1,1] for both axes
      // while preserving the direction, useful for some control schemes.
      final maxComponent = math.max(dx.abs(), dy.abs());
      if (maxComponent > 0) {
        final scale = normalizedDistance / maxComponent;
        _normalizedPosition = Offset(dx * scale, dy * scale);
      } else {
        _normalizedPosition = Offset.zero;
      }

      _arcAngle = angle;
    } else {
      _normalizedPosition = Offset.zero;
    }
  }

  // Updates the internal position state, triggers UI rebuild, AND calls back immediately
  void _updatePositionAndVisuals() {
    _calculateNormalizedPosition();
    _lastStablePosition = _normalizedPosition;

    if (widget.onPositionChanged != null) {
      widget.onPositionChanged!(_lastStablePosition);
    }

    setState(() {});
  }

  void _handlePointerEnd() {
    _isDragging = false;
    _pointerId = null;

    if (widget.onPositionChanged != null) {
      _lastStablePosition = Offset.zero;
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

  @override
  Widget build(BuildContext context) {
    final radius = _size / 2;
    final maxKnobDistance = radius - _knobRadius;

    return Listener(
      onPointerDown: (details) {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }

        _pointerId = details.pointer;
        _isDragging = true;

        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition =
            renderBox.globalToLocal(details.position) - center;
        final distance = localPosition.distance;

        if (distance > maxKnobDistance) {
          _position = localPosition * (maxKnobDistance / distance);
        } else {
          _position = localPosition;
        }

        _calculateNormalizedPosition();
        _lastStablePosition = _normalizedPosition;

        if (widget.onPositionChanged != null) {
          widget.onPositionChanged!(_lastStablePosition);
        }

        setState(() {});
      },
      onPointerMove: (details) {
        if (_pointerId != details.pointer || !_isDragging) return;

        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition =
            renderBox.globalToLocal(details.position) - center;
        final distance = localPosition.distance;

        if (distance > maxKnobDistance) {
          _position = localPosition * (maxKnobDistance / distance);
        } else {
          _position = localPosition;
        }

        _updatePositionAndVisuals();
      },
      onPointerUp: (details) {
        _handlePointerEnd();
      },
      onPointerCancel: (details) {
        _handlePointerEnd();
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
              left: radius + _position.dx - _knobRadius,
              top: radius + _position.dy - _knobRadius,
              child: Image.asset(
                'assets/images/analog_stick/center.png',
                width: _knobSize,
                height: _knobSize,
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
      {'alignment': Alignment(0.88, 0), 'angle': math.pi / 2},
      {'alignment': Alignment(0, 0.88), 'angle': math.pi},
      {'alignment': Alignment(-0.88, 0), 'angle': -math.pi / 2},
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

  @override
  bool shouldRepaint(SoftArcPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }

  Offset calculatePointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }
}
