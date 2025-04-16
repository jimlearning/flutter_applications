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
      title: 'AdaptiveWidthScrollBar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AdaptiveWidthScrollBarDemo(),
    );
  }
}

class AdaptiveWidthScrollBarDemo extends StatefulWidget {
  const AdaptiveWidthScrollBarDemo({super.key});

  @override
  State<AdaptiveWidthScrollBarDemo> createState() => _AdaptiveWidthScrollBarDemoState();
}

class _AdaptiveWidthScrollBarDemoState extends State<AdaptiveWidthScrollBarDemo> {
  bool _showAllTools = false;

  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    final newCanScrollLeft = _scrollController.position.pixels > 0;
    final newCanScrollRight = _scrollController.position.pixels <
        _scrollController.position.maxScrollExtent;

    if (newCanScrollLeft != _canScrollLeft || newCanScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = newCanScrollLeft;
        _canScrollRight = newCanScrollRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自适应宽度滚动工具栏 Demo'),
      ),
      body: Stack(
        children: [
          // 背景内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('点击下方工具栏中的按钮', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAllTools = !_showAllTools;
                    });
                  },
                  child: Text(_showAllTools ? '显示精简工具栏' : '显示完整工具栏'),
                ),
              ],
            ),
          ),

          // 自适应宽度滚动工具栏
          _buildScrollableToolbar(),
        ],
      ),
    );
  }

  Widget _buildScrollableToolbar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 100,
      child: Center(
        child: AdaptiveWidthScrollBar(
          children: _buildToolbarItems(),
        ),
      ),
    );
  }

  List<Widget> _buildToolbarItems() {
    final basicTools = [
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
    ];

    if (!_showAllTools) {
      return [
        ...basicTools,
      ];
    }

    return [
      ...basicTools,
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
      const ToolbarDivider(),
      AdaptiveIconButton(
        icon: const AssetImage('assets/images/toolbar/resume.png'),
        label: '继续',
        iconAlignment: AdaptiveIconAlignment.bottom,
        onTap: () => _showSnackBar('继续'),
      ),
      const ToolbarDivider(),
      AdaptiveIconButton(
        icon: const AssetImage('assets/images/toolbar/more.png'),
        iconAlignment: AdaptiveIconAlignment.right,
        onTap: () => _showSnackBar('更多'),
      ),
    ];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('点击了: $message')),
    );
  }
}

