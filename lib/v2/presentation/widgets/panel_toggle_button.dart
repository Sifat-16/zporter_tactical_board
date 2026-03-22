import 'package:flutter/material.dart';

/// Side of the panel (determines chevron direction).
enum PanelSide { left, right }

/// Chevron toggle button for opening/closing sliding toolbar panels.
///
/// Matches V1's inline toggle button styling: semi-transparent background,
/// rounded corners on the exposed side.
class PanelToggleButton extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final PanelSide side;

  const PanelToggleButton({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    if (side == PanelSide.left) {
      icon = isOpen ? Icons.chevron_left : Icons.chevron_right;
    } else {
      icon = isOpen ? Icons.chevron_right : Icons.chevron_left;
    }

    final borderRadius = side == PanelSide.left
        ? const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          );

    return Material(
      color: Colors.black54,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onToggle,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
