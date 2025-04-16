import 'dart:ui';

import 'package:flutter/material.dart';

// 新增枚举类型
enum AdaptiveIconAlignment {
  left,
  right,
  top,
  bottom,
}

class AdaptiveIconButton extends StatelessWidget {
  final ImageProvider? icon;
  final String? label;
  final VoidCallback? onTap;
  final AdaptiveIconAlignment iconAlignment; // 改用新枚举类型
  final double spacing;
  final EdgeInsets padding;

  const AdaptiveIconButton({
    super.key,
    this.icon,
    this.label,
    this.onTap,
    this.iconAlignment = AdaptiveIconAlignment.left, // 默认左对齐
    this.spacing = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) : assert(icon != null || label != null, 'At least icon or label is required');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final iconWidget = icon != null
        ? Image(image: icon!, width: 24, height: 24)
        : null;

    final labelWidget = label != null
        ? Text(label!, style: const TextStyle(fontSize: 12))
        : null;

    switch (iconAlignment) {
      case AdaptiveIconAlignment.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) iconWidget!,
            if (labelWidget != null) ...[
              SizedBox(height: spacing),
              labelWidget!,
            ],
          ],
        );
      case AdaptiveIconAlignment.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelWidget != null) labelWidget!,
            if (iconWidget != null) ...[
              SizedBox(height: spacing),
              iconWidget!,
            ],
          ],
        );
      case AdaptiveIconAlignment.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) iconWidget!,
            if (labelWidget != null) ...[
              SizedBox(width: spacing),
              labelWidget!,
            ],
          ],
        );
      case AdaptiveIconAlignment.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelWidget != null) labelWidget!,
            if (iconWidget != null) ...[
              SizedBox(width: spacing),
              iconWidget!,
            ],
          ],
        );
    }
  }
}

class ToolbarDivider extends StatelessWidget {
  final double height;

  const ToolbarDivider({
    super.key,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const VerticalDivider(
        width: 16,
        thickness: 1,
        color: Color(0xFFC7C7CB),
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final bool showLeftIndicator;
  final bool showRightIndicator;

  const ScrollIndicator({
    super.key,
    this.showLeftIndicator = false,
    this.showRightIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLeftIndicator) ...[
          Image(image: AssetImage('assets/images/toolbar/arrow_left.png'), width: 16, height: 16),
          const SizedBox(width: 4),
        ],
        if (showRightIndicator) ...[
          const SizedBox(width: 4),
          Image(image: AssetImage('assets/images/toolbar/arrow_right.png'), width: 16, height: 16),
        ],
      ],
    );
  }
}

class AdaptiveWidthScrollBar extends StatefulWidget {
  final List<Widget> children;
  final int priority; // 优先级，数字越小优先级越高

  const AdaptiveWidthScrollBar({
    super.key,
    required this.children,
    this.priority = 1, // 默认优先级为1
  });

  @override
  State<AdaptiveWidthScrollBar> createState() => _AdaptiveWidthScrollBarState();
}

class _AdaptiveWidthScrollBarState extends State<AdaptiveWidthScrollBar> {
  // 是否处于滚动状态
  bool _isScrolling = false;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 滚动指示器状态
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  // 全局注册的所有工具栏，用于优先级管理
  static final List<_AdaptiveWidthScrollBarState> _allBars = [];

  @override
  void initState() {
    super.initState();
    _allBars.add(this);
    _scrollController.addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    _allBars.remove(this);
    super.dispose();
  }

  // 更新滚动指示器状态
  void _updateScrollIndicators() {
    if (!mounted) return;

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
    // 使用Align组件使工具栏居中显示，不使用FittedBox避免高度随宽度变化
    return Align(
      alignment: Alignment.center,
      child: _buildToolbar(),
    );
  }

  Widget _buildToolbar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
          alignment: Alignment.center,
          child: Container(
            // 设置固定高度，避免高度随宽度变化
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF38383A).withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 检查是否需要滚动
                  final childrenWidth = _calculateChildrenWidth();
                  final availableWidth = constraints.maxWidth;
                  final needsScrolling = childrenWidth > availableWidth;

                  // 根据优先级决定是否应该滚动
                  bool shouldScroll = _shouldScrollBasedOnPriority(needsScrolling, availableWidth, childrenWidth);

                  // 更新滚动状态（不在build中调用setState）
                  _isScrolling = shouldScroll;

                  if (shouldScroll) {
                    // 需要滚动时，使用Stack和SingleChildScrollView
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // 滚动内容
                        SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.children,
                          ),
                        ),

                        // 滚动指示器覆盖层
                        Positioned(
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 左侧滚动指示器
                              if (_canScrollLeft)
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF38383A).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image(image: AssetImage('assets/images/toolbar/arrow_left.png'), width: 16, height: 16),
                                )
                              else
                                SizedBox(width: 24),

                              // 右侧滚动指示器
                              if (_canScrollRight)
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF38383A).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image(image: AssetImage('assets/images/toolbar/arrow_right.png'), width: 16, height: 16),
                                )
                              else
                                SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // 不需要滚动时，使用AnimatedSwitcher
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: child,
                          ),
                        );
                      },
                      layoutBuilder: (currentChild, previousChildren) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: Row(
                        key: ValueKey(
                          widget.children.map((e) => e.key).toList().join('_'),
                        ),
                        mainAxisSize: MainAxisSize.min,
                        children: widget.children,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 计算所有子组件的总宽度
  double _calculateChildrenWidth() {
    // 这里使用一个估算值，实际应用中可能需要更精确的计算
    // 每个按钮大约占用80像素，每个分隔符大约占用16像素
    double totalWidth = 0;
    for (var child in widget.children) {
      if (child is AdaptiveIconButton) {
        totalWidth += 80; // 估算每个按钮的宽度
      } else if (child is ToolbarDivider) {
        totalWidth += 16; // 估算每个分隔符的宽度
      } else {
        totalWidth += 40; // 其他组件的估算宽度
      }
    }
    return totalWidth;
  }

  // 根据优先级决定是否应该滚动
  bool _shouldScrollBasedOnPriority(bool needsScrolling, double availableWidth, double childrenWidth) {
    if (!needsScrolling) {
      return false; // 如果不需要滚动，直接返回false
    }

    // 如果只有一个工具栏，或者当前工具栏优先级最高，则应该滚动
    if (_allBars.length <= 1) {
      return true;
    }

    // 按优先级排序所有工具栏（数字越小优先级越高）
    final sortedBars = List<_AdaptiveWidthScrollBarState>.from(_allBars)
      ..sort((a, b) => a.widget.priority.compareTo(b.widget.priority));

    // 计算总可用宽度和所有工具栏所需的总宽度
    double totalAvailableWidth = availableWidth;
    double totalRequiredWidth = 0;

    // 收集所有工具栏的宽度需求
    final widthRequirements = <_AdaptiveWidthScrollBarState, double>{};
    for (var bar in sortedBars) {
      final width = bar._calculateChildrenWidth();
      widthRequirements[bar] = width;
      totalRequiredWidth += width;
    }

    // 如果总宽度足够，所有工具栏都不需要滚动
    if (totalRequiredWidth <= totalAvailableWidth) {
      return false;
    }

    // 从优先级最高的工具栏开始分配空间
    double remainingWidth = totalAvailableWidth;
    for (var bar in sortedBars) {
      final requiredWidth = widthRequirements[bar] ?? 0;

      // 如果剩余空间足够当前工具栏，分配空间并继续
      if (requiredWidth <= remainingWidth) {
        remainingWidth -= requiredWidth;
      } else {
        // 空间不足，检查是否是当前工具栏
        return bar == this;
      }
    }

    // 默认情况下不滚动
    return false;
  }
}
