import 'package:flutter/material.dart';

/// Flutter code sample for [AnimatedSwitcher].

void main() => runApp(const AnimatedSwitcherExampleApp());

class AnimatedSwitcherExampleApp extends StatelessWidget {
  const AnimatedSwitcherExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AnimatedSwitcherExample());
  }
}

class AnimatedSwitcherExample extends StatefulWidget {
  const AnimatedSwitcherExample({super.key});

  @override
  State<AnimatedSwitcherExample> createState() =>
      _AnimatedSwitcherExampleState();
}

class _AnimatedSwitcherExampleState extends State<AnimatedSwitcherExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // // 修改这部分，让它自适应内容宽度并有动画效果
          // Center(
          //   child: AnimatedChildrenContainer(
          //     children: [
          //       for (var i = 0; i < _count; i++)
          //         Text(
          //           '$i',
          //           key: ValueKey<int>(i),
          //           style: Theme.of(context).textTheme.headlineMedium,
          //         ),
          //     ],
          //   ),
          // ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child:
                    // child,
                    SizeTransition(
                      axis: Axis.horizontal,
                  sizeFactor: animation,
                  axisAlignment: 0.0,
                  child: child,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: Colors.red,
              key: ValueKey<int>(_count),
              child: AnimatedChildrenContainer(
                children: [
                  for (var i = 0; i < _count; i++)
                    Text(
                      '$i',
                      key: ValueKey<int>(i),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('Increment'),
            onPressed: () {
              setState(() {
                _count += 1;
              });
            },
          ),
        ],
      ),
    );
  }
}

// 修改 AnimatedChildrenContainer 类
class AnimatedChildrenContainer extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const AnimatedChildrenContainer({
    Key? key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: 0.0,
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        key: ValueKey<String>(children.hashCode.toString()),
        color: Colors.blue,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
