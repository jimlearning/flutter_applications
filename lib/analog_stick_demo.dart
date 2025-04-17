import 'dart:math';

import 'package:flutter/material.dart';
import 'analog_stick.dart';

void main() => runApp(const AnalogStickDemoApp());

class AnalogStickDemoApp extends StatelessWidget {
  const AnalogStickDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
      backgroundColor: Colors.black,
      body: SafeArea(
        // --- Use a Column instead of Stack for vertical arrangement ---
        child: Column(
          children: [
            // --- Use Expanded to allow the text area to fill available space ---
            Expanded(
              child: Center(
                child: SingleChildScrollView( // Add ScrollView in case text overflows
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Add some padding
                    child: Text(
                      controlData.isEmpty
                          ? "Move the sticks..." // Show placeholder if no data
                          : controlData.entries
                              .map((entry) =>
                                  '${entry.key}: \n${entry.value is Map ? entry.value.entries.map((e) => '  ${e.key}: ${e.value}').join('\n') : entry.value}')
                              .join('\n\n'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, // Adjusted font size slightly
                        color: Colors.white, // Use white for better contrast on black
                        // Using random color on every build can be distracting
                        // color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withAlpha(255)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // --- Keep the DualAnalogStick at the bottom ---
            // No need for SizedBox wrapper if it's directly in Column
            DualAnalogStick(onControlChanged: (newData) { // Renamed param for clarity
              setState(() {
                controlData = newData;
              });
              debugPrint('controlData: $newData');
            }),
            // Optional: Add some padding below the sticks if needed
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}