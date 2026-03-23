import 'package:flutter/material.dart';

/// Pulsing red deletion zone on the left edge of the board.
///
/// Shown when an element is being dragged on the board. Dragging an
/// element past this zone's boundary removes it from the board.
///
/// Matches V1's [DropZoneComponent] visual behavior:
/// - Red gradient from left (opaque) to right (transparent)
/// - Pulsing opacity animation (0.4–0.8)
/// - Trash icon indicator
class DeleteDropZoneV2 extends StatefulWidget {
  /// Total height of the board.
  final double height;

  /// Width of the delete zone.
  final double width;

  const DeleteDropZoneV2({
    super.key,
    required this.height,
    this.width = 60,
  });

  @override
  State<DeleteDropZoneV2> createState() => _DeleteDropZoneV2State();
}

class _DeleteDropZoneV2State extends State<DeleteDropZoneV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: widget.width,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final opacity = 0.4 + (_controller.value * 0.4); // 0.4–0.8
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.red.withValues(alpha: opacity),
                    Colors.red.withValues(alpha: 0.0),
                  ],
                ),
                border: Border(
                  right: BorderSide(
                    color: Colors.red.withValues(alpha: opacity),
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white.withValues(alpha: opacity),
                  size: 28,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
