import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

enum AdaptiveIconAlignment {
  left,
  right,
  top,
  bottom,
}

class AdaptiveButton extends StatelessWidget {
  final ImageProvider? icon;
  final String? label;
  final VoidCallback? onTap;
  final AdaptiveIconAlignment iconAlignment;
  final double fontSize;
  final double iconSize;
  final double spacing;
  final EdgeInsets padding;

  const AdaptiveButton({
    super.key,
    this.icon,
    this.label,
    this.onTap,
    this.iconAlignment = AdaptiveIconAlignment.left,
    this.fontSize = 12,
    this.iconSize = 24,
    this.spacing = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) : assert(icon != null || label != null,
            'At least icon or label is required');

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
        ? Image(image: icon!, width: iconSize, height: iconSize)
        : null;

    final labelWidget = label != null
        ? Text(label!, style: TextStyle(fontSize: fontSize))
        : null;

    switch (iconAlignment) {
      case AdaptiveIconAlignment.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) iconWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (labelWidget != null) labelWidget,
          ],
        );
      case AdaptiveIconAlignment.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelWidget != null) labelWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (iconWidget != null) iconWidget,
          ],
        );
      case AdaptiveIconAlignment.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) iconWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (labelWidget != null) labelWidget,
          ],
        );
      case AdaptiveIconAlignment.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelWidget != null) labelWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (iconWidget != null) iconWidget,
          ],
        );
    }
  }
}

class AdaptiveDivider extends StatelessWidget {
  final double height;
  final double width;

  const AdaptiveDivider({
    super.key,
    this.height = 24,
    this.width = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        width: width,
        thickness: 1,
        color: const Color(0xFFC7C7CB),
      ),
    );
  }
}

class AdaptiveScrollbar extends StatefulWidget {
  final List<Widget> children;

  const AdaptiveScrollbar({
    super.key,
    required this.children,
  });

  @override
  State<AdaptiveScrollbar> createState() => _AdaptiveScrollbarState();
}

class _AdaptiveScrollbarState extends State<AdaptiveScrollbar> {
  final ScrollController _scrollController = ScrollController();

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  double horizontalPadding = 12.0;
  double verticalPadding = 8.0;

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

  // 更新滚动指示器状态
  void _updateScrollIndicators() {
    if (!mounted) return;

    const double threshold = 1.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    final newCanScrollLeft = maxScroll > 0 && currentScroll > threshold;
    final newCanScrollRight =
        maxScroll > 0 && currentScroll < (maxScroll - threshold);

    debugPrint(
        'maxScroll: $maxScroll, currentScroll: $currentScroll, threshold: $threshold');
    debugPrint(
        'newCanScrollLeft: $newCanScrollLeft, newCanScrollRight: $newCanScrollRight');

    if (newCanScrollLeft != _canScrollLeft ||
        newCanScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = newCanScrollLeft;
        _canScrollRight = newCanScrollRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // height: 72,
            decoration: BoxDecoration(
              color: Color(0xFF38383A).withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final parentWidth = constraints.maxWidth;
                  debugPrint('Parent width from LayoutBuilder: $parentWidth');

                  final childrenWidth = _calculateChildrenWidth();
                  final availableWidth = constraints.maxWidth;
                  final needsScrolling =
                      childrenWidth > availableWidth + horizontalPadding * 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: needsScrolling
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.children,
                        ),
                      ),
                      if (needsScrolling)
                        Positioned(
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_canScrollLeft)
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF38383A).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/toolbar/arrow_left.png'),
                                      width: 16,
                                      height: 16),
                                )
                              else
                                SizedBox(width: 24),
                              if (_canScrollRight)
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF38383A).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/toolbar/arrow_right.png'),
                                      width: 16,
                                      height: 16),
                                )
                              else
                                SizedBox(width: 24),
                            ],
                          ),
                        )
                      else
                        SizedBox.shrink()
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateChildrenWidth() {
    if (!mounted) return 0;

    double totalWidth = horizontalPadding * 2;

    for (var child in widget.children) {
      if (child is AdaptiveButton) {
        double buttonWidth = 0;
        bool hasIcon = child.icon != null;
        bool hasLabel = child.label != null;

        if (hasLabel) {
          final textPainter = TextPainter(
            text: TextSpan(
                text: child.label, style: TextStyle(fontSize: child.fontSize)),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          final textWidth = (textPainter.width * 2).roundToDouble() / 2;

          switch (child.iconAlignment) {
            case AdaptiveIconAlignment.left:
            case AdaptiveIconAlignment.right:
              // 水平排列：图标+间距+文本
              buttonWidth = child.padding.horizontal +
                  textWidth +
                  (hasIcon ? (child.spacing + child.iconSize) : 0);
              break;
            case AdaptiveIconAlignment.top:
            case AdaptiveIconAlignment.bottom:
              // 垂直排列：取图标和文本的最大宽度
              buttonWidth = max(
                  child.padding.horizontal + (hasIcon ? child.iconSize : 0),
                  child.padding.horizontal + textWidth);
              break;
          }
        } else {
          buttonWidth = child.padding.horizontal + child.iconSize;
        }
        totalWidth += buttonWidth;
      } else if (child is AdaptiveDivider) {
        totalWidth += child.width;
      }
    }

    return totalWidth;
  }
}
