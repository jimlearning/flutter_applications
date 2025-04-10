import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

// ------------------ ENUM 定义 ------------------
enum SectionType { live, settle, execute }

enum LiveAction { audio, photo, video, speaker, more }
enum SettleAction { setPose, setTarget }
enum ExecuteAction { start, pause, resume, cancel }
enum ExecuteState { idle, executing, paused }

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
}

// ------------------ 按钮模型 ------------------
class ControlButtonConfig {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final AutoDisposeProvider<bool> visibleProvider;

  ControlButtonConfig({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.visibleProvider,
  });
}

// ------------------ 状态定义 ------------------
final executeStateProvider = StateProvider<ExecuteState>((ref) => ExecuteState.idle);

final liveSectionVisibleProvider = StateProvider<bool>((ref) => true);
final settleSectionVisibleProvider = StateProvider<bool>((ref) => true);

final sectionButtonsProvider = Provider.family<List<ControlButtonConfig>, SectionType>((ref, section) {
  switch (section) {
    case SectionType.live:
      if (!ref.watch(liveSectionVisibleProvider)) return [];
      return LiveAction.values.map((action) => _buildLiveButton(ref, action)).toList();
    case SectionType.settle:
      if (!ref.watch(settleSectionVisibleProvider)) return [];
      return SettleAction.values.map((action) => _buildSettleButton(ref, action)).toList();
    case SectionType.execute:
      final state = ref.watch(executeStateProvider);
      return _buildExecuteButtons(ref, state);
  }
});

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

  final buttons = <ExecuteAction, Future<void> Function()> {
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
      onTap: () => entry.value(),
      visibleProvider: Provider.autoDispose((_) => visibleMap[entry.key] ?? false),
    );
  }).toList();
}

// ------------------ Section Widget ------------------
class SectionWidget extends ConsumerWidget {
  final SectionType sectionType;

  const SectionWidget({super.key, required this.sectionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttons = ref.watch(sectionButtonsProvider(sectionType));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((btn) {
        final visible = ref.watch(btn.visibleProvider);
        return visible
            ? InkWell(
                key: ValueKey(btn.label),
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
              )
            : const SizedBox.shrink();
      }).toList(),
    );
  }
}

// ------------------ FloatingControlToolbar ------------------
class FloatingControlToolbar extends ConsumerWidget {
  const FloatingControlToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLive = ref.watch(liveSectionVisibleProvider);
    final showSettle = ref.watch(settleSectionVisibleProvider);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF38383A).withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildSectionsWithDividers(showLive, showSettle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionsWithDividers(bool showLive, bool showSettle) {
    final sections = <Widget>[];
    
    if (showLive) {
      sections.add(SectionWidget(sectionType: SectionType.live));
    }
    if (showSettle) {
      sections.add(SectionWidget(sectionType: SectionType.settle));
    }
    sections.add(SectionWidget(sectionType: SectionType.execute));

    final result = <Widget>[];
    for (int i = 0; i < sections.length; i++) {
      result.add(sections[i]);
      if (i < sections.length - 1) {
        result.add(_buildDivider());
      }
    }
    
    return result;
  }

  Widget _buildDivider() {
    return SizedBox(
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
}

// ------------------ 示例页面 ------------------
class DemoToolbarPage extends StatelessWidget {
  const DemoToolbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Floating Toolbar Demo'),
        actions: [
          Consumer(builder: (context, ref, _) {
            return IconButton(
              icon: Icon(
                ref.watch(liveSectionVisibleProvider) ? Icons.videocam : Icons.videocam_off,
                color: ref.watch(liveSectionVisibleProvider) ? Colors.white : Colors.white54,
              ),
              onPressed: () => ref.read(liveSectionVisibleProvider.notifier).state = 
                  !ref.read(liveSectionVisibleProvider),
            );
          }),
          Consumer(builder: (context, ref, _) {
            return IconButton(
              icon: Icon(
                ref.watch(settleSectionVisibleProvider) ? Icons.settings : Icons.settings_outlined,
                color: ref.watch(settleSectionVisibleProvider) ? Colors.white : Colors.white54,
              ),
              onPressed: () => ref.read(settleSectionVisibleProvider.notifier).state = 
                  !ref.read(settleSectionVisibleProvider),
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          Center(child: Text('内容区域')), // 可放地图、视频等控件
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: FittedBox(
                child: FloatingControlToolbar(),
              ),
            ),
          ),
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
