import 'dart:ui';

import 'package:flutter/material.dart';

class EmbodyColor {
  static const Color primary = Color.fromRGBO(64, 156, 255, 1.0);
  static const Color background = Color.fromRGBO(56, 56, 58, 1.0);
  static const Color gray3 = Color.fromRGBO(199, 199, 204, 1.0);
}

enum AdaptiveIconAlignment { left, right, top, bottom }

class AdaptiveButton extends StatelessWidget {
  final ImageProvider? icon;
  final String? label;
  final VoidCallback? onTap;
  final AdaptiveIconAlignment iconAlignment;
  final double iconSize;
  final double fontSize;
  final Color textColor;
  final double spacing;
  final EdgeInsets padding;

  const AdaptiveButton({
    super.key,
    this.icon,
    this.label,
    this.onTap,
    this.iconAlignment = AdaptiveIconAlignment.left,
    this.iconSize = 24,
    this.fontSize = 12,
    this.textColor = Colors.white,
    this.spacing = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) : assert(
          icon != null || label != null,
          'At least icon or label is required',
        );

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon != null
        ? Image(image: icon!, width: iconSize, height: iconSize)
        : null;
    final labelWidget = label != null
        ? Text(
            label!,
            style: TextStyle(fontSize: fontSize, color: textColor),
          )
        : null;

    Widget content;
    switch (iconAlignment) {
      case AdaptiveIconAlignment.top:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) iconWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (labelWidget != null) labelWidget,
          ],
        );
        break;
      case AdaptiveIconAlignment.bottom:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelWidget != null) labelWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (iconWidget != null) iconWidget,
          ],
        );
        break;
      case AdaptiveIconAlignment.left:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) iconWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (labelWidget != null) labelWidget,
          ],
        );
        break;
      case AdaptiveIconAlignment.right:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelWidget != null) labelWidget,
            if (labelWidget != null && iconWidget != null)
              SizedBox(width: spacing),
            if (iconWidget != null) iconWidget,
          ],
        );
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(padding: padding, child: content),
    );
  }
}

class AdaptiveDivider extends StatelessWidget {
  final double height;
  final double width;

  const AdaptiveDivider({super.key, this.height = 24, this.width = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        width: width,
        thickness: 1,
        color: EmbodyColor.gray3,
      ),
    );
  }
}

class AdaptiveScrollbar extends StatefulWidget {
  final List<Widget> children;

  const AdaptiveScrollbar({super.key, required this.children});

  @override
  State<AdaptiveScrollbar> createState() => _AdaptiveScrollbarState();
}

class _AdaptiveScrollbarState extends State<AdaptiveScrollbar> {
  final ScrollController _scrollController = ScrollController();

  bool _isScrollable = false;
  bool _canScrollForward = false;
  bool _canScrollBackward = false;

  double _lastKnownWidth = -1.0;

  final double _horizontalPadding = 12.0;
  final double _verticalPadding = 8.0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  @override
  void didUpdateWidget(covariant AdaptiveScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.children.length != oldWidget.children.length ||
        widget.children != oldWidget.children) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollIndicators();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final newIsScrollable = position.maxScrollExtent > position.minScrollExtent;
    final newCanScrollForward = position.pixels < position.maxScrollExtent;
    final newCanScrollBackward = position.pixels > position.minScrollExtent;

    if (newIsScrollable != _isScrollable ||
        newCanScrollForward != _canScrollForward ||
        newCanScrollBackward != _canScrollBackward) {
      setState(() {
        _isScrollable = newIsScrollable;
        _canScrollForward = newCanScrollForward;
        _canScrollBackward = newCanScrollBackward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildArrowIndicator(
        {required bool isVisible, required bool isLeftArrow}) {
      if (!isVisible) {
        return SizedBox(width: 16 + 4 * 2);
      }
      return Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: EmbodyColor.background.withAlpha(180),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 2,
                offset: Offset(0, 1),
              )
            ]),
        child: Image(
          image: AssetImage(
            isLeftArrow
                ? 'assets/images/adaptive_scrollbar/arrow_left.png'
                : 'assets/images/adaptive_scrollbar/arrow_right.png',
          ),
          width: 16,
          height: 16,
        ),
      );
    }

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
              color: EmbodyColor.background.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: _verticalPadding,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                final currentWidth = constraints.maxWidth;
                if ((currentWidth - _lastKnownWidth).abs() > 0.1) {
                  _lastKnownWidth = currentWidth;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateScrollIndicators();
                  });
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: _isScrollable
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.children,
                      ),
                    ),
                    if (_isScrollable)
                      Positioned(
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildArrowIndicator(
                                isVisible: _canScrollBackward,
                                isLeftArrow: true,
                              ),
                              buildArrowIndicator(
                                isVisible: _canScrollForward,
                                isLeftArrow: false,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox.shrink(),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
