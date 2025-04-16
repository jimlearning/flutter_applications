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
  final double bottomOffset;
  final List<Widget> children;

  const AdaptiveWidthScrollBar({
    super.key,
    this.bottomOffset = 160,
    required this.children,
  });

  @override
  State<AdaptiveWidthScrollBar> createState() => _AdaptiveWidthScrollBarState();
}

class _AdaptiveWidthScrollBarState extends State<AdaptiveWidthScrollBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottomOffset,
      left: 0,
      right: 0,
      child: Center(child: FittedBox(child: _buildToolbar())),
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
            decoration: BoxDecoration(
              color: Color(0xFF38383A).withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: AnimatedSwitcher(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
