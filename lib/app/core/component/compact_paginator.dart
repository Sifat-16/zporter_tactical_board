import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';

const Color _defaultActiveColor = ColorManager.yellow;
const Color _defaultInactiveColor = ColorManager.grey;
const double _defaultNavIconSize =
    AppSize.s24; // Using s24 as a more common default icon size
const double _defaultPageNumberFontSize = AppSize.s18; // Using s18 as a default
const FontWeight _defaultPageNumberFontWeight = FontWeight.bold;
const double _defaultUnderlineHeight = 3.0;
const double _defaultUnderlineWidth = 20.0;
const EdgeInsets _defaultNavButtonPadding = EdgeInsets.symmetric(
  horizontal: 4.0,
  vertical: 8.0,
);
const EdgeInsets _defaultPageNumberPadding = EdgeInsets.symmetric(
  horizontal: 8.0,
  vertical: 4.0,
);

class CompactPaginatorUiConfig {
  /// Color for the active page number and its underline.
  final Color? activeColor;

  /// Color for inactive page numbers and enabled navigation icons.
  final Color? inactiveColor;

  /// Size for the navigation icons (previous/next).
  final double? navIconSize;

  /// Opacity applied to the navigation icon color when disabled. Defaults to 0.3.
  final double disabledOpacity;

  /// Padding around the navigation icons.
  final EdgeInsets? navButtonPadding;

  /// Font size for the page numbers.
  final double? pageNumberFontSize;

  /// Font weight for the page numbers.
  final FontWeight? pageNumberFontWeight;

  /// Padding around each page number item (includes text and underline).
  final EdgeInsets? pageNumberPadding;

  /// Height of the underline shown below the active page number.
  final double? underlineHeight;

  /// Width of the underline shown below the active page number.
  final double? underlineWidth;

  const CompactPaginatorUiConfig({
    this.activeColor,
    this.inactiveColor,
    this.navIconSize,
    this.disabledOpacity = 0.3, // Default disabled opacity
    this.navButtonPadding,
    this.pageNumberFontSize,
    this.pageNumberFontWeight,
    this.pageNumberPadding,
    this.underlineHeight,
    this.underlineWidth,
  });
}

class CompactPaginator extends StatefulWidget {
  final int totalPages;
  final int initialPage; // 0-based index
  final Function(int newPageIndex) onPageChanged;
  final int maxPagesToShow; // How many page numbers to show at most
  final CompactPaginatorUiConfig? config; // Optional UI Configuration

  const CompactPaginator({
    super.key,
    required this.totalPages,
    required this.onPageChanged,
    this.initialPage = 0,
    this.maxPagesToShow = 3,
    this.config, // Accept the config
  }) : assert(totalPages >= 0),
       assert(initialPage >= 0),
       assert(maxPagesToShow > 0);

  @override
  State<CompactPaginator> createState() => _CompactPaginatorState();
}

class _CompactPaginatorState extends State<CompactPaginator> {
  late int _currentPage;

  // Helper getter for easier access to config with defaults
  CompactPaginatorUiConfig get _config =>
      widget.config ?? const CompactPaginatorUiConfig();

  @override
  void initState() {
    super.initState();
    _currentPage = math.min(
      widget.initialPage,
      widget.totalPages > 0 ? widget.totalPages - 1 : 0,
    );
    if (widget.totalPages == 0) _currentPage = 0;
  }

  @override
  void didUpdateWidget(CompactPaginator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage ||
        widget.totalPages != oldWidget.totalPages) {
      int maxValidPage = widget.totalPages > 0 ? widget.totalPages - 1 : 0;
      if (_currentPage > maxValidPage ||
          widget.initialPage != oldWidget.initialPage) {
        setState(() {
          _currentPage = math.min(widget.initialPage, maxValidPage);
          if (widget.totalPages == 0) _currentPage = 0;
        });
      }
    }
  }

  void _changePage(int newPage) {
    if (newPage >= 0 && newPage < widget.totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      widget.onPageChanged(newPage);
    }
  }

  List<int> _getVisiblePages() {
    if (widget.totalPages <= 0) return [];
    if (widget.totalPages <= widget.maxPagesToShow) {
      return List.generate(widget.totalPages, (index) => index);
    }
    int half = widget.maxPagesToShow ~/ 2;
    int startPage = _currentPage - half;
    int endPage = _currentPage + (widget.maxPagesToShow - half - 1);
    if (startPage < 0) {
      endPage -= startPage;
      startPage = 0;
    }
    if (endPage >= widget.totalPages) {
      startPage -= (endPage - (widget.totalPages - 1));
      endPage = widget.totalPages - 1;
    }
    startPage = math.max(0, startPage);
    // Ensure we don't exceed maxPagesToShow if totalPages is large and startPage got clamped
    endPage = math.min(endPage, startPage + widget.maxPagesToShow - 1);

    return List.generate(
      math.max(0, endPage - startPage + 1),
      (index) => startPage + index,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canGoBack = _currentPage > 0;
    bool canGoForward =
        _currentPage < (widget.totalPages > 0 ? widget.totalPages - 1 : 0);
    List<int> visiblePages = _getVisiblePages();

    // Handle case where there are no pages to show elegantly
    if (widget.totalPages <= 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildNavButton(
          icon: Icons.chevron_left,
          enabled: canGoBack,
          onTap: () => _changePage(_currentPage - 1),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children:
              visiblePages
                  .map(
                    (pageIndex) => _buildPageNumber(
                      pageIndex: pageIndex,
                      isActive: pageIndex == _currentPage,
                      onTap: () => _changePage(pageIndex),
                    ),
                  )
                  .toList(),
        ),
        _buildNavButton(
          icon: Icons.chevron_right,
          enabled: canGoForward,
          onTap: () => _changePage(_currentPage + 1),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    // Use config values with fallbacks to defaults
    final Color effectiveInactiveColor =
        _config.inactiveColor ?? _defaultInactiveColor;
    final double disabledOpacity =
        _config.disabledOpacity; // Uses default from config class if null
    final Color iconColor =
        enabled
            ? effectiveInactiveColor
            : effectiveInactiveColor.withOpacity(disabledOpacity);
    final double iconSize = _config.navIconSize ?? _defaultNavIconSize;
    final EdgeInsets padding =
        _config.navButtonPadding ?? _defaultNavButtonPadding;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: padding,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }

  Widget _buildPageNumber({
    required int pageIndex,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    String pageText = (pageIndex + 1).toString();

    // Use config values with fallbacks to defaults
    final Color activeColor = _config.activeColor ?? _defaultActiveColor;
    final Color inactiveColor = _config.inactiveColor ?? _defaultInactiveColor;
    final Color textColor = isActive ? activeColor : inactiveColor;
    final double fontSize =
        _config.pageNumberFontSize ?? _defaultPageNumberFontSize;
    final FontWeight fontWeight =
        _config.pageNumberFontWeight ?? _defaultPageNumberFontWeight;
    final double underlineHeight =
        _config.underlineHeight ?? _defaultUnderlineHeight;
    final double underlineWidth =
        _config.underlineWidth ?? _defaultUnderlineWidth;
    final Color underlineColor =
        activeColor; // Underline always uses active color
    final EdgeInsets padding =
        _config.pageNumberPadding ?? _defaultPageNumberPadding;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              pageText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),

            Container(
              height: underlineHeight,
              width: underlineWidth,
              color: isActive ? underlineColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
