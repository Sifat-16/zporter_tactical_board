import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class ChoiceChipGridSelector<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T?> onChanged;
  final String Function(T item) itemAsString;
  final EdgeInsets? padding;
  final double spacing; // Spacing between chips in the main axis
  final double runSpacing; // Spacing between runs (rows) of chips
  final int
      maxChipsInCollapsedView; // Max elements in collapsed view (items + More chip)

  const ChoiceChipGridSelector({
    super.key,
    required this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
    required this.itemAsString,
    this.padding,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.maxChipsInCollapsedView =
        4, // Default to showing 3 items + 1 More chip, or 4 items if not enough to expand
  });

  @override
  _ChoiceChipGridSelectorState<T> createState() =>
      _ChoiceChipGridSelectorState<T>();
}

class _ChoiceChipGridSelectorState<T> extends State<ChoiceChipGridSelector<T>> {
  T? _selectedValue;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    // If there are fewer or equal items than maxChipsInCollapsedView, consider it expanded by default
    // as there's no "More" button to click.
    if (widget.items.length <= widget.maxChipsInCollapsedView) {
      _isExpanded = true;
    }
  }

  @override
  void didUpdateWidget(covariant ChoiceChipGridSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
    // Adjust _isExpanded state if items list changes significantly
    if (widget.items.length != oldWidget.items.length) {
      if (widget.items.length <= widget.maxChipsInCollapsedView) {
        _isExpanded = true; // Auto-expand if few items
      } else {
        // If it was expanded and now has more items than threshold,
        // it might be desirable to keep it expanded or collapse it.
        // For simplicity, let's keep current _isExpanded state unless it becomes <= threshold.
      }
    }
  }

  Widget _buildChip(T item, TextTheme textTheme, ChipThemeData chipTheme) {
    final bool isSelected = _selectedValue == item;
    return ChoiceChip(
      label: Text(widget.itemAsString(item)),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedValue = item;
          });
          widget.onChanged(_selectedValue);
        }
      },
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? chipTheme.secondaryLabelStyle?.color ?? ColorManager.white
            : chipTheme.labelStyle?.color ??
                ColorManager.white.withOpacity(0.8),
      ),
      selectedColor: chipTheme.selectedColor ?? ColorManager.yellow,
      backgroundColor: chipTheme.backgroundColor ?? ColorManager.black,
      shape: chipTheme.shape ??
          StadiumBorder(
              side: BorderSide(
                  color: isSelected
                      ? ColorManager.yellow
                      : ColorManager.white.withOpacity(0.5),
                  width: 1.0)),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: chipTheme.padding ??
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    );
  }

  Widget _buildExpansionChip(String label, VoidCallback onTap,
      TextTheme textTheme, ChipThemeData chipTheme) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: ColorManager.black,
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: ColorManager.white,
        fontWeight: FontWeight.bold,
      ),
      shape: chipTheme.shape ??
          StadiumBorder(
              side: BorderSide(color: ColorManager.black, width: 1.0)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: chipTheme.padding ??
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ChipThemeData chipTheme = theme.chipTheme;

    List<Widget> chipWidgets = [];
    final bool needsExpansionButton =
        widget.items.length > widget.maxChipsInCollapsedView;

    if (_isExpanded || !needsExpansionButton) {
      // Show all items
      chipWidgets = widget.items
          .map((item) => _buildChip(item, textTheme, chipTheme))
          .toList();
      if (needsExpansionButton && _isExpanded) {
        // Add "Less" button if expanded and it was expandable
        chipWidgets.add(_buildExpansionChip("Show Less", () {
          setState(() {
            _isExpanded = false;
          });
        }, textTheme, chipTheme));
      }
    } else {
      // Show collapsed view: (maxChipsInCollapsedView - 1) items + "More" button
      int itemsToTake = widget.maxChipsInCollapsedView - 1;
      if (itemsToTake < 0) itemsToTake = 0; // Ensure non-negative

      chipWidgets = widget.items
          .take(itemsToTake)
          .map((item) => _buildChip(item, textTheme, chipTheme))
          .toList();

      int remainingItems = widget.items.length - itemsToTake;
      chipWidgets.add(_buildExpansionChip("More ($remainingItems+)", () {
        setState(() {
          _isExpanded = true;
        });
      }, textTheme, chipTheme));
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.label,
            style: textTheme.labelLarge?.copyWith(
              color: ColorManager.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          if (widget.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No items available.',
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: ColorManager.white.withOpacity(0.7),
                ),
              ),
            )
          else
            Wrap(
              spacing: widget.spacing,
              runSpacing: widget.runSpacing,
              children: chipWidgets,
            ),
        ],
      ),
    );
  }
}
