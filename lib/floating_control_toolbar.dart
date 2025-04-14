// ================= IMPORTS =================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

// ================= CONSTANTS =================
const _kToolbarPadding = EdgeInsets.all(12.0);
const _kAnimationDuration = Duration(milliseconds: 300);
final _kToolbarBorderRadius = BorderRadius.circular(16);

// ================= ENUMS =================
enum SectionType { live, settle, execute }
enum LiveAction { audio, photo, video, speaker, more }
enum SettleAction { setPose, setTarget }
enum ExecuteAction { start, pause, resume, cancel }
enum ExecuteState { idle, executing, paused }

// ================= EXTENSIONS =================
extension LiveActionExtension on LiveAction {
  String get displayName {
    switch (this) {
      case LiveAction.audio:
        return 'Audio';
      case LiveAction.photo:
        return 'Photo';
      case LiveAction.video:
        return 'Video';
      case LiveAction.speaker:
        return 'Speaker';
      case LiveAction.more:
        return 'More';
    }
  }
  String get key {
    return displayName;
  }
}

extension SettleActionExtension on SettleAction {
  String get displayName {
    switch (this) {
      case SettleAction.setPose:
        return 'Set Pose';
      case SettleAction.setTarget:
        return 'Set Target';
    }
  }
  String get key {
    return displayName;
  }
}

extension ExecuteActionExtension on ExecuteAction {
  String get displayName {
    switch (this) {
      case ExecuteAction.start:
        return 'Start';
      case ExecuteAction.pause:
        return 'Pause';
      case ExecuteAction.resume:
        return 'Resume';
      case ExecuteAction.cancel:
        return 'Cancel';
    }
  }
  String get key {
    switch (this) {
      case ExecuteAction.start:
      case ExecuteAction.cancel:
        return 'Start';
      case ExecuteAction.pause:
      case ExecuteAction.resume:
        return 'Pause';
    }
  }
}

// ================= PROVIDERS =================
final executeStateProvider =
    StateProvider<ExecuteState>((ref) => ExecuteState.idle);

final liveSectionVisibleProvider = StateProvider<bool>((ref) => true);
final settleSectionVisibleProvider = StateProvider<bool>((ref) => true);

final sectionButtonsProvider =
    Provider.family<List<ControlButtonConfig>, SectionType>((ref, section) {
  switch (section) {
    case SectionType.live:
      if (!ref.watch(liveSectionVisibleProvider)) return [];
      return LiveAction.values
          .map((action) => _buildLiveButton(ref, action))
          .toList();
    case SectionType.settle:
      if (!ref.watch(settleSectionVisibleProvider)) return [];
      return SettleAction.values
          .map((action) => _buildSettleButton(ref, action))
          .toList();
    case SectionType.execute:
      final state = ref.watch(executeStateProvider);
      return _buildExecuteButtons(ref, state);
  }
});

// ================= MODELS =================
class ControlButtonConfig {
  final IconData icon;
  final String label;
  final String key;
  final VoidCallback onTap;
  final AutoDisposeProvider<bool> visibleProvider;

  ControlButtonConfig({
    required this.icon,
    required this.label,
    required this.key,
    required this.onTap,
    required this.visibleProvider,
  });
}

// ================= WIDGETS =================

// 浮动布局包装器
class FloatingToolbar extends StatelessWidget {
  final double bottomOffset;
  
  const FloatingToolbar({
    super.key,
    this.bottomOffset = 32,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: Center(
        child: FittedBox(
          child: ControlToolbar(),
        ),
      ),
    );
  }
}

// 核心工具栏组件
class ControlToolbar extends ConsumerWidget { 
  const ControlToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLive = ref.watch(liveSectionVisibleProvider);
    final showSettle = ref.watch(settleSectionVisibleProvider);

    return ClipRRect(
      borderRadius: _kToolbarBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF38383A).withAlpha(25),
            borderRadius: _kToolbarBorderRadius,
          ),
          child: Padding(
            padding: _kToolbarPadding,
            child: AnimatedSize(
              duration: _kAnimationDuration,
              curve: Curves.linear,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildSectionsWithDividers({
                  SectionType.live: showLive,
                  SectionType.settle: showSettle,
                  SectionType.execute: true
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionsWithDividers(Map<SectionType, bool> visibilityMap) {
    final sections = visibilityMap.entries.toList();
    final widgets = <Widget>[];
    
    for (int i = 0; i < sections.length; i++) {
      final entry = sections[i];
      widgets.add(
        AnimatedSwitcher(
          duration: _kAnimationDuration,
          transitionBuilder: _buildFadeSizeTransition,
          child: entry.value
              ? SectionWidget(
                  key: ValueKey('${entry.key}_section'),
                  sectionType: entry.key,
                )
              : SizedBox.shrink(key: ValueKey('${entry.key}_section_hidden')),
        )
      );
      
      // 添加分割线逻辑
      if (i < sections.length - 1) {
        // 查找下一个可见section的索引
        int nextVisibleIndex = i + 1;
        while (nextVisibleIndex < sections.length && !sections[nextVisibleIndex].value) {
          nextVisibleIndex++;
        }
        
        // 如果当前section可见且找到下一个可见section
        if (entry.value && nextVisibleIndex < sections.length) {
          widgets.add(_buildDivider(key: ValueKey('divider_${i}_to_$nextVisibleIndex')));
        }
      }
    }
    
    return widgets;
  }

  Widget _buildDivider({Key? key}) {
    return SizedBox(
      key: key, // Assign the key here
      height: 24,
      child: Center(
        child: VerticalDivider(
          width: 10,
          thickness: 1,
          color: Color(0xFFC7C7CB),
        ),
      ),
    );
  }

  Widget _buildFadeSizeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axis: Axis.horizontal,
        child: child,
      ),
    );
  }
}

// ================= PRIVATE WIDGETS =================
// 内部使用的子组件
class SectionWidget extends ConsumerWidget {
  final SectionType sectionType;
  
  const SectionWidget({
    super.key,
    required this.sectionType,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttons = ref.watch(sectionButtonsProvider(sectionType));

    // 1. 过滤出当前可见的按钮
    final visibleButtons = buttons.where((btn) {
      // 注意：这里用 read 而不是 watch，避免 AnimatedSwitcher 内部不必要的重绘
      // visibleProvider 变化会触发 SectionWidget 重建，从而重新计算 visibleButtons
      return ref.read(btn.visibleProvider);
    }).toList();

    // 2. 基于可见按钮生成 Row 的 Key
    final rowKey = ValueKey(visibleButtons.map((btn) => btn.key).join(','));

    // 3. 构建只包含可见按钮的 Row
    final rowChild = Row(
      key: rowKey, // 使用动态 Key
      mainAxisSize: MainAxisSize.min,
      children: visibleButtons.map((btn) {
        // 直接构建 InkWell，不再需要内部 AnimatedSwitcher
        return InkWell(
          key: ValueKey(btn.key), // 仍然需要 Key
          onTap: btn.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 46),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(btn.icon, size: 24),
                  Text(btn.label, style: TextStyle(fontSize: 12))
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );

    // 4. AnimatedSize 包裹 AnimatedSwitcher，AnimatedSwitcher 包裹 Row
    return AnimatedSwitcher(
        duration: _kAnimationDuration, // 匹配 AnimatedSize
        transitionBuilder: (child, animation) => ControlToolbar()._buildFadeSizeTransition(child, animation),
        child: rowChild, // 切换的是整个 Row
      );
  }
}

// ================= BUTTON BUILDERS =================
ControlButtonConfig _buildLiveButton(Ref ref, LiveAction action) {
  final icon = switch (action) {
    LiveAction.audio => Icons.mic,
    LiveAction.photo => Icons.camera_alt,
    LiveAction.video => Icons.videocam,
    LiveAction.speaker => Icons.volume_up,
    LiveAction.more => Icons.more_horiz,
  };

  return ControlButtonConfig(
    icon: icon,
    label: action.displayName,
    key: action.key,
    onTap: () => debugPrint('Live action tapped: ${action.displayName}'),
    visibleProvider: Provider.autoDispose((_) => true),
  );
}

ControlButtonConfig _buildSettleButton(Ref ref, SettleAction action) {
  final icon = switch (action) {
    SettleAction.setPose => Icons.accessibility,
    SettleAction.setTarget => Icons.gps_fixed,
  };

  return ControlButtonConfig(
    icon: icon,
    label: action.displayName,
    key: action.key,
    onTap: () {},
    visibleProvider: Provider.autoDispose((_) => true),
  );
}

List<ControlButtonConfig> _buildExecuteButtons(Ref ref, ExecuteState state) {
  final notifier = ref.read(executeStateProvider.notifier);

  Future<void> startAction() async {
    await Future.delayed(Duration(milliseconds: 300));
    notifier.state = ExecuteState.executing;
  }

  Future<void> pauseAction() async {
    await Future.delayed(Duration(milliseconds: 300));
    notifier.state = ExecuteState.paused;
  }

  Future<void> cancelAction() async {
    await Future.delayed(Duration(milliseconds: 300));
    notifier.state = ExecuteState.idle;
  }

  Future<void> resumeAction() async {
    await Future.delayed(Duration(milliseconds: 300));
    notifier.state = ExecuteState.executing;
  }

  final buttons = <ExecuteAction, Future<void> Function()>{
    ExecuteAction.start: startAction,
    ExecuteAction.pause: pauseAction,
    ExecuteAction.resume: resumeAction,
    ExecuteAction.cancel: cancelAction,
  };

  final visibleMap = <ExecuteAction, bool>{
    ExecuteAction.start: state == ExecuteState.idle,
    ExecuteAction.pause: state == ExecuteState.executing,
    ExecuteAction.resume: state == ExecuteState.paused,
    ExecuteAction.cancel: state != ExecuteState.idle,
  };

  return buttons.entries.map((entry) {
    final icon = switch (entry.key) {
      ExecuteAction.start => Icons.play_arrow,
      ExecuteAction.pause => Icons.pause,
      ExecuteAction.resume => Icons.play_circle_fill,
      ExecuteAction.cancel => Icons.stop,
    };

    return ControlButtonConfig(
      icon: icon,
      label: entry.key.displayName,
      key: entry.key.key,
      onTap: () => entry.value(),
      visibleProvider:
          Provider.autoDispose((_) => visibleMap[entry.key] ?? false),
    );
  }).toList();
}

// ================= DEMO PAGE =================
class DemoToolbarPage extends StatelessWidget {
  const DemoToolbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Floating Control Toolbar Demo'),
        actions: [
          Consumer(builder: (context, ref, _) {
            return IconButton(
              icon: Icon(
                ref.watch(liveSectionVisibleProvider)
                    ? Icons.videocam
                    : Icons.videocam_off,
                color: ref.watch(liveSectionVisibleProvider)
                    ? Colors.black // Changed color for better visibility
                    : Colors.black54,
              ),
              onPressed: () => ref
                  .read(liveSectionVisibleProvider.notifier)
                  .state = !ref.read(liveSectionVisibleProvider),
            );
          }),
          Consumer(builder: (context, ref, _) {
            return IconButton(
              icon: Icon(
                ref.watch(settleSectionVisibleProvider)
                    ? Icons.settings
                    : Icons.settings_outlined,
                color: ref.watch(settleSectionVisibleProvider)
                    ? Colors.black // Changed color for better visibility
                    : Colors.black54,
              ),
              onPressed: () => ref
                  .read(settleSectionVisibleProvider.notifier)
                  .state = !ref.read(settleSectionVisibleProvider),
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          Center(child: Text('内容区域')), // 可放地图、视频等控件
          const FloatingToolbar(),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(home: DemoToolbarPage()),
    ),
  );
}
