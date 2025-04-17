import 'package:flutter/material.dart';
import 'adaptive_scrollbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dual Scrollbar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DualScrollbarDemo(),
    );
  }
}

class DualScrollbarDemo extends StatefulWidget {
  const DualScrollbarDemo({super.key});

  @override
  State<DualScrollbarDemo> createState() => _DualScrollbarDemoState();
}

class _DualScrollbarDemoState extends State<DualScrollbarDemo> {
  bool _showSingleBar = true;
  bool _primaryHasPriority = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSingleBar = !_showSingleBar;
                    });
                  },
                  child: Text(_showSingleBar ? '显示双工具栏' : '显示单工具栏'),
                ),
                if (!_showSingleBar) ...[
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _primaryHasPriority = !_primaryHasPriority;
                      });
                    },
                    child: Text(_primaryHasPriority ? '主工具栏优先' : '次工具栏优先'),
                  ),
                ],
              ],
            ),
          ),

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPrimaryToolbar(),

                  if (!_showSingleBar) ...[
                    const SizedBox(width: 20),
                    _buildSecondaryToolbar(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryToolbar() {
    return AdaptiveScrollbar(
      children: [
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/audio.png'),
          label: '音频',
          iconAlignment: AdaptiveIconAlignment.top,
          onTap: () => _showSnackBar('音频'),
        ),
        const AdaptiveDivider(),
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/video.png'),
          label: '视频',
          iconAlignment: AdaptiveIconAlignment.bottom,
          onTap: () => _showSnackBar('视频'),
        ),
        const AdaptiveDivider(),
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/photo.png'),
          label: '照片',
          iconAlignment: AdaptiveIconAlignment.left,
          onTap: () => _showSnackBar('照片'),
        ),
        const AdaptiveDivider(),
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/start.png'),
          label: '开始',
          iconAlignment: AdaptiveIconAlignment.right,
          onTap: () => _showSnackBar('开始'),
        ),
        const AdaptiveDivider(),
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/pause.png'),
          label: '暂停',
          iconAlignment: AdaptiveIconAlignment.bottom,
          onTap: () => _showSnackBar('暂停'),
        ),
      ],
    );
  }

  Widget _buildSecondaryToolbar() {
    return AdaptiveScrollbar(
      children: [
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/resume.png'),
          label: '继续',
          iconAlignment: AdaptiveIconAlignment.bottom,
          onTap: () => _showSnackBar('继续'),
        ),
        const AdaptiveDivider(),
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/more.png'),
          label: '更多',
          iconAlignment: AdaptiveIconAlignment.right,
          onTap: () => _showSnackBar('更多'),
        ),
        const AdaptiveDivider(),
        AdaptiveButton(
          icon: const AssetImage('assets/images/toolbar/audio.png'),
          label: '设置',
          iconAlignment: AdaptiveIconAlignment.top,
          onTap: () => _showSnackBar('设置'),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('点击了: $message')),
    );
  }
}