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
      title: 'AdaptiveScrollbar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AdaptiveScrollbarDemo(),
    );
  }
}

class AdaptiveScrollbarDemo extends StatefulWidget {
  const AdaptiveScrollbarDemo({super.key});

  @override
  State<AdaptiveScrollbarDemo> createState() => _AdaptiveScrollbarDemoState();
}

class _AdaptiveScrollbarDemoState extends State<AdaptiveScrollbarDemo> {
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
      // backgroundColor: Colors.black.withAlpha(20),
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAllTools = !_showAllTools;
                    });
                  },
                  child: Text(_showAllTools ? '工具栏 1' : '工具栏 2'),
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
        child: AdaptiveScrollbar(
          children: _buildToolbarItems(),
        ),
      ),
    );
  }

  List<Widget> _buildToolbarItems() {
    final basicTools = [
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/audio.png'),
        label: '音频',
        iconAlignment: AdaptiveIconAlignment.top,
        onTap: () => _showSnackBar('音频'),
      ),
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/video.png'),
        label: '视频',
        iconAlignment: AdaptiveIconAlignment.bottom,
        onTap: () => _showSnackBar('视频'),
      ),
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/photo.png'),
        label: '照片',
        iconAlignment: AdaptiveIconAlignment.left,
        padding: const EdgeInsets.all(20),
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
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/set_pose.png'),
        label: 'Set Pose',
        iconAlignment: AdaptiveIconAlignment.top,
        onTap: () => _showSnackBar('Set Pose'),
      ),
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/start.png'),
        label: '开始',
        iconAlignment: AdaptiveIconAlignment.right,
        onTap: () => _showSnackBar('开始'),
      ),
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/pause.png'),
        label: '暂停',
        iconAlignment: AdaptiveIconAlignment.bottom,
        onTap: () => _showSnackBar('暂停'),
      ),
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/resume.png'),
        label: '继续',
        iconAlignment: AdaptiveIconAlignment.bottom,
        onTap: () => _showSnackBar('继续'),
      ),
      const AdaptiveDivider(),
      AdaptiveButton(
        icon: const AssetImage('assets/images/adaptive_scrollbar/more.png'),
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

  Widget _buildBackgroundImage() {
    return Image.asset(
      'assets/images/live_screenshot_default.jpg', // Corrected image path
      fit: BoxFit.cover, // Cover the entire stack area
      width: double.infinity, // Ensure it takes full width
      height: double.infinity, // Ensure it takes full height
    );
  }
}

