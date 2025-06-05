import 'dart:async'; // For Future.delayed

import 'package:flutter/material.dart';

class ButtonWithTapOverlay extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String overlayText;
  final Duration overlayDuration;

  const ButtonWithTapOverlay({
    super.key,
    this.onPressed,
    required this.child,
    this.overlayText = "Tapped!", // Default overlay text
    this.overlayDuration = const Duration(seconds: 2), // Default duration
  });

  @override
  State<ButtonWithTapOverlay> createState() => _ButtonWithTapOverlayState();
}

class _ButtonWithTapOverlayState extends State<ButtonWithTapOverlay> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Timer? _overlayTimer;

  void _showOverlay() {
    // Remove any existing overlay and cancel its timer
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          // These anchors will try to center the follower (overlay)
          // on the target (button).
          followerAnchor: Alignment.center,
          targetAnchor: Alignment.center,
          // You can add an offset if you want to adjust the position slightly
          // e.g., offset: const Offset(0, -50), // Moves overlay 50px above button's center
          child: Material(
            // Material widget is important for text styling and to prevent visual glitches.
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.overlayText,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      },
    );

    // Insert the overlay entry into the overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Set a timer to remove the overlay automatically
    _overlayTimer = Timer(widget.overlayDuration, _removeOverlay);
  }

  void _removeOverlay() {
    _overlayTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    // Ensure the overlay is removed when the widget is disposed
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          _showOverlay();
          // Also call the original onPressed if provided
          widget.onPressed?.call();
        },
        child:
            widget.child, // Use the child widget passed to ButtonWithTapOverlay
      ),
    );
  }
}
