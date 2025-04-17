import 'dart:async';
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

// --- AnalogStick Widget ---
class AnalogStick extends StatefulWidget {
  final Function(Offset)? onPositionChanged;
  final bool enableHapticFeedback;

  const AnalogStick({
    super.key,
    this.onPositionChanged,
    this.enableHapticFeedback = false,
  });

  @override
  State<AnalogStick> createState() => _AnalogStickState();
}

class _AnalogStickState extends State<AnalogStick> with SingleTickerProviderStateMixin {
  // --- Constants ---
  final double _size = 120;
  static const double _knobSize = 33.0;
  static const double _knobRadius = _knobSize / 2;
  final Duration _updateInterval = const Duration(milliseconds: 100); // Callback interval

  // --- State Variables ---
  Offset _position = Offset.zero; // Raw position of the knob relative to center
  Offset _normalizedPosition = Offset.zero; // Position normalized to [-1, 1] range (approx)
  Offset _lastStablePosition = Offset.zero; // Last position sent via callback
  double _arcAngle = 0; // Angle for the visual arc indicator

  // --- Touch/Drag State ---
  bool _isDragging = false;
  bool _reachedEdge = false;
  int? _pointerId; // ID of the pointer currently interacting with this stick

  // --- Animation & Timer ---
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  Timer? _positionUpdateTimer;

  // --- Removed Unused Variable ---
  // Offset _initialTouchPosition = Offset.zero; // This was unused

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Reset animation duration
    );
    // Animation for snapping back to center
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack, // Snap back effect
      ),
    );

    // Listener to update knob position during reset animation
    _animation.addListener(() {
      setState(() {
        _position = _animation.value;
        _calculateNormalizedPosition(); // Update internal normalized state based on animation
      });
    });
  }

  @override
  void dispose() {
    _pointerId = null; // Clear pointer ID just in case
    _positionUpdateTimer?.cancel(); // Cancel timer
    _animationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Calculates the normalized position based on the current raw _position
  void _calculateNormalizedPosition() {
    final maxDistance = (_size / 2) - _knobRadius; // Max distance knob center can travel

    final distance = _position.distance;
    final angle = _position.direction; // Angle in radians

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
        _normalizedPosition = Offset.zero; // Should not happen if distance > 0
      }

      _arcAngle = angle; // Update visual arc angle
    } else {
      _normalizedPosition = Offset.zero;
      // Keep _arcAngle as is when position is zero? Or reset? Current keeps last angle.
    }
  }

  // Updates the internal position state and triggers a UI rebuild
  void _updatePositionAndVisuals() {
    _calculateNormalizedPosition(); // Calculate the new normalized position

    // Store the latest calculated position for the timer callback
    _lastStablePosition = _normalizedPosition;

    // Trigger UI rebuild to show updated knob position and arc
    setState(() {});
  }

  // Starts the periodic timer to send position updates via callback
  void _startPositionUpdates() {
    _positionUpdateTimer?.cancel(); // Cancel any existing timer

    // Send the initial position immediately when dragging starts
    if (_isDragging && widget.onPositionChanged != null) {
      widget.onPositionChanged!(_lastStablePosition);
    }

    // Start the periodic timer
    _positionUpdateTimer = Timer.periodic(_updateInterval, (timer) {
      // If still dragging, send the last known stable position
      if (_isDragging && widget.onPositionChanged != null) {
        widget.onPositionChanged!(_lastStablePosition);
      } else {
        // Optional: Cancel timer if not dragging anymore (should be handled by _handlePointerEnd)
        // timer.cancel();
      }
    });
  }

  // Stops the periodic timer
  void _stopPositionUpdates() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = null;
  }

  // Handles the end of a touch interaction (Up or Cancel)
  void _handlePointerEnd() {
    // Called ONLY from onPointerUp/onPointerCancel after pointerId check

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    _isDragging = false; // Mark as not dragging
    _reachedEdge = false;
    _pointerId = null; // Release the pointer lock
    _stopPositionUpdates(); // Stop the periodic updates timer

    // --- Reset Logic ---
    // 1. Send the final zero value via callback
    if (widget.onPositionChanged != null) {
      _lastStablePosition = Offset.zero; // Ensure stable position is zero
      widget.onPositionChanged!(Offset.zero);
    }

    // 2. Animate knob back to center visually
    _animation = Tween<Offset>(begin: _position, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.reset();
    _animationController.forward();
    // The animation listener handles setState during the animation
  }


  @override
  Widget build(BuildContext context) {
    final radius = _size / 2;
    final maxKnobDistance = radius - _knobRadius; // Use the constant

    return Listener(
      onPointerDown: (details) {
        if (_pointerId != null) return; // Ignore if already tracking another pointer

        // Stop reset animation if it's running from a previous release
        if (_animationController.isAnimating) {
          _animationController.stop();
        }

        _pointerId = details.pointer; // Track this pointer
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        _isDragging = true; // Set dragging state

        // Calculate initial position based on touch location
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition = renderBox.globalToLocal(details.position) - center;

        // Clamp initial position within bounds
        final distance = localPosition.distance;
        if (distance > maxKnobDistance) {
          _position = localPosition * (maxKnobDistance / distance);
        } else {
          _position = localPosition;
        }

        // Update internal state based on initial position
        _calculateNormalizedPosition();
        _lastStablePosition = _normalizedPosition;

        // Start sending periodic updates
        _startPositionUpdates();

        // Update UI to show knob at initial press position
        setState(() {});
      },
      onPointerMove: (details) {
        // Only process moves for the tracked pointer and if dragging
        if (_pointerId != details.pointer || !_isDragging) return;

        // Calculate new position based on move event
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final center = Offset(radius, radius);
        final localPosition = renderBox.globalToLocal(details.position) - center;
        final distance = localPosition.distance;

        // Haptic feedback near the edge
        if (widget.enableHapticFeedback) {
           if (distance > maxKnobDistance * 0.95 && !_reachedEdge) {
             HapticFeedback.mediumImpact();
             _reachedEdge = true;
           } else if (distance <= maxKnobDistance * 0.9) {
             _reachedEdge = false;
           }
        }

        // Clamp position within bounds
        if (distance > maxKnobDistance) {
          _position = localPosition * (maxKnobDistance / distance);
        } else {
          _position = localPosition;
        }

        // Update internal state and visuals, but DO NOT send callback here
        _updatePositionAndVisuals();
      },
      onPointerUp: (details) {
        // Only handle up event for the tracked pointer
        if (_pointerId != details.pointer) return;
        _handlePointerEnd(); // Perform cleanup and reset
      },
      onPointerCancel: (details) {
        // Only handle cancel event for the tracked pointer
        if (_pointerId != details.pointer) return;
        _handlePointerEnd(); // Perform cleanup and reset
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
            // Background direction indicators
            Positioned.fill(child: buildDirectionIndicators()),
            // Arc indicator showing direction (only when dragging)
            if (_isDragging && _position != Offset.zero)
              Positioned.fill(child: ImageArc(angle: _arcAngle)),
            // The draggable knob
            Positioned(
              left: radius + _position.dx - _knobRadius, // Use constant
              top: radius + _position.dy - _knobRadius, // Use constant
              child: Image.asset(
                'assets/images/analog_stick/center.png',
                width: _knobSize, // Use constant
                height: _knobSize, // Use constant
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the static direction indicator arrows
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


// --- ImageArc Widget ---
// This seems fine, uses SoftArcPainter.
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


// --- SoftArcPainter ---
// This handles the custom painting of the arc. Looks reasonable.
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
    // Optimization: only repaint if angle or color or radius changes
    return oldDelegate.angle != angle || oldDelegate.color != color || oldDelegate.radius != radius;
  }

  // Helper to calculate points on the circle for the gradient
  Offset calculatePointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }
}
