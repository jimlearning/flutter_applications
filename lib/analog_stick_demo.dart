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
  Map<String, dynamic> controlData = {};

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
                  Text(
                    controlData.entries
                        .map((entry) => '${entry.key}: \n${entry.value is Map ?
                            entry.value.entries.map((e) => '${e.key}: ${e.value}').join('\n') :
                            entry.value}')
                        .join('\n\n'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          DualAnalogStick(onControlChanged: (controlData) {
            setState(() {
              this.controlData = controlData;
            });
            debugPrint('controlData: $controlData');
          }),
        ],
      ),
      ),
    );
  }
}