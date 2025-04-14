import 'package:flutter/material.dart';
import 'analog_stick.dart';

void main() => runApp(const AnalogStickDemoApp());

class AnalogStickDemoApp extends StatelessWidget {
  const AnalogStickDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // title: '双摇杆演示',
      home: AnalogStickDemo(),
    );
  }
}

class AnalogStickDemo extends StatefulWidget {
  const AnalogStickDemo({super.key});

  @override
  State<AnalogStickDemo> createState() => _AnalogStickDemoState();
}

class _AnalogStickDemoState extends State<AnalogStickDemo> {
  Offset _leftStickPosition = Offset.zero;
  Offset _rightStickPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Text(
                  //   '摇杆位置信息',
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  // ),
                  const SizedBox(height: 20),
                  Text(
                    '左摇杆: (${_leftStickPosition.dx.toStringAsFixed(2)}, ${_leftStickPosition.dy.toStringAsFixed(2)})',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '右摇杆: (${_rightStickPosition.dx.toStringAsFixed(2)}, ${_rightStickPosition.dy.toStringAsFixed(2)})',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200.withAlpha(0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      painter: PositionIndicatorPainter(
                        leftPosition: _leftStickPosition,
                        rightPosition: _rightStickPosition,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DualAnalogStickController(
            onLeftStickChanged: (position) {
              setState(() {
                _leftStickPosition = position;
              });
            },
            onRightStickChanged: (position) {
              setState(() {
                _rightStickPosition = position;
              });
            },
          ),
        ],
      ),
      ),
    );
  }
}

class PositionIndicatorPainter extends CustomPainter {
  final Offset leftPosition;
  final Offset rightPosition;

  PositionIndicatorPainter({
    required this.leftPosition,
    required this.rightPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const dotRadius = 8.0; // 圆点的半径

    // 绘制背景圆
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // // 绘制十字线
    // final linePaint = Paint()
    //   ..color = Colors.grey
    //   ..strokeWidth = 1;
    // canvas.drawLine(
    //   Offset(center.dx, center.dy - radius),
    //   Offset(center.dx, center.dy + radius),
    //   linePaint,
    // );
    // canvas.drawLine(
    //   Offset(center.dx - radius, center.dy),
    //   Offset(center.dx + radius, center.dy),
    //   linePaint,
    // );
    // 计算可用半径（考虑圆点自身的大小）
    final availableRadius = radius - dotRadius;

    // 绘制左摇杆位置
    final leftPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        center.dx + leftPosition.dx * availableRadius,
        center.dy + leftPosition.dy * availableRadius,
      ),
      dotRadius,
      leftPaint,
    );

    // 绘制右摇杆位置
    final rightPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        center.dx + rightPosition.dx * availableRadius,
        center.dy + rightPosition.dy * availableRadius,
      ),
      dotRadius,
      rightPaint,
    );
  }

  @override
  bool shouldRepaint(PositionIndicatorPainter oldDelegate) {
    return oldDelegate.leftPosition != leftPosition ||
        oldDelegate.rightPosition != rightPosition;
  }
}