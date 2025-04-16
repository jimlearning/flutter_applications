import 'package:flutter/material.dart';
import 'adaptive_width_scroll_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dual ScrollBar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DualScrollBarDemo(),
    );
  }
}

class DualScrollBarDemo extends StatefulWidget {
  const DualScrollBarDemo({super.key});

  @override
  State<DualScrollBarDemo> createState() => _DualScrollBarDemoState();
}

class _DualScrollBarDemoState extends State<DualScrollBarDemo> {
  bool _showSingleBar = true;
  bool _primaryHasPriority = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('双工具栏优先级 Demo'),
      ),
      body: Stack(
        children: [
          // 背景内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('工具栏优先级演示', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
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

          // 工具栏容器
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 主工具栏
                  _buildPrimaryToolbar(),

                  // 次工具栏 (仅在显示双工具栏时显示)
                  if (!_showSingleBar) ...[
                    const SizedBox(width: 20), // 两个工具栏之间的间距
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
    return AdaptiveWidthScrollBar(
      bottomOffset: 0, // 不需要底部偏移，由外层Positioned控制
      priority: _primaryHasPriority ? 1 : 2, // 优先级设置
      children: [
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/audio.png'),
          label: '音频',
          iconAlignment: AdaptiveIconAlignment.top,
          onTap: () => _showSnackBar('音频'),
        ),
        const ToolbarDivider(),
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/video.png'),
          label: '视频',
          iconAlignment: AdaptiveIconAlignment.bottom,
          onTap: () => _showSnackBar('视频'),
        ),
        const ToolbarDivider(),
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/photo.png'),
          label: '照片',
          iconAlignment: AdaptiveIconAlignment.left,
          onTap: () => _showSnackBar('照片'),
        ),
        const ToolbarDivider(),
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/start.png'),
          label: '开始',
          iconAlignment: AdaptiveIconAlignment.right,
          onTap: () => _showSnackBar('开始'),
        ),
        const ToolbarDivider(),
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/pause.png'),
          label: '暂停',
          iconAlignment: AdaptiveIconAlignment.bottom,
          onTap: () => _showSnackBar('暂停'),
        ),
      ],
    );
  }

  Widget _buildSecondaryToolbar() {
    return AdaptiveWidthScrollBar(
      bottomOffset: 0, // 不需要底部偏移，由外层Positioned控制
      priority: _primaryHasPriority ? 2 : 1, // 优先级设置
      children: [
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/resume.png'),
          label: '继续',
          iconAlignment: AdaptiveIconAlignment.bottom,
          onTap: () => _showSnackBar('继续'),
        ),
        const ToolbarDivider(),
        AdaptiveIconButton(
          icon: const AssetImage('assets/images/toolbar/more.png'),
          label: '更多',
          iconAlignment: AdaptiveIconAlignment.right,
          onTap: () => _showSnackBar('更多'),
        ),
        const ToolbarDivider(),
        AdaptiveIconButton(
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