import 'package:flutter/material.dart';

class TutorialStepOverlay extends StatelessWidget {
  /// The rectangle defining the area to highlight (in global coordinates).
  final Rect targetRect;

  /// The instructional message to display.
  final String message;

  /// Callback triggered when the "Next" or "Got it" button is pressed.
  final VoidCallback onNext;

  /// Padding around the targetRect to make the highlight area slightly larger.
  final EdgeInsets highlightPadding;

  /// The color of the overlay.
  final Color overlayColor;

  /// The style for the tutorial message text.
  final TextStyle messageStyle;

  /// The text for the button.
  final String buttonText;

  const TutorialStepOverlay({
    super.key,
    required this.targetRect,
    required this.message,
    required this.onNext,
    this.highlightPadding = const EdgeInsets.all(8.0), // Default padding
    this.overlayColor = Colors.black54, // Default overlay color
    this.messageStyle = const TextStyle(color: Colors.white, fontSize: 16.0),
    this.buttonText = "Got it!",
  });

  @override
  Widget build(BuildContext context) {
    // Adjust the targetRect with padding
    final Rect paddedRect = Rect.fromLTRB(
      targetRect.left - highlightPadding.left,
      targetRect.top - highlightPadding.top,
      targetRect.right + highlightPadding.right,
      targetRect.bottom + highlightPadding.bottom,
    );

    return Stack(
      children: [
        // Custom painter for the overlay with a hole
        Positioned.fill(
          child: CustomPaint(
            painter: _OverlayPainter(
              targetRect: paddedRect,
              overlayColor: overlayColor,
            ),
          ),
        ),
        // Positioned message bubble
        _buildMessageBubble(context, paddedRect),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, Rect actualHighlightRect) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Attempt to position the bubble intelligently:
    // Prefer below the target, if not enough space, try above.
    // If target is too wide, center the bubble.

    double bubbleTop;
    double bubbleBottom;
    double? bubbleLeft = 20; // Default horizontal padding
    double? bubbleRight = 20; // Default horizontal padding

    // Check if there's more space below or above the target
    bool preferBelow =
        (actualHighlightRect.bottom + 150) <
        screenHeight; // 150 is an estimated bubble height

    if (preferBelow) {
      bubbleTop = actualHighlightRect.bottom + 16.0; // 16px below the highlight
      bubbleBottom = double.infinity; // Not constrained from bottom
    } else {
      bubbleTop = double.infinity; // Not constrained from top
      bubbleBottom =
          screenHeight -
          actualHighlightRect.top +
          16.0; // 16px above the highlight
    }

    // Basic centering if the message bubble might be too wide for default padding
    // This is a simple heuristic. More complex logic might be needed for edge cases.
    if (actualHighlightRect.width > screenWidth - 40) {
      // If target is very wide
      bubbleLeft =
          (screenWidth - (screenWidth * 0.8)) / 2; // Center an 80% width bubble
      bubbleRight = bubbleLeft;
    } else if (actualHighlightRect.center.dx < screenWidth / 2) {
      // Target is on the left, anchor bubble left
      bubbleLeft = actualHighlightRect.left;
      bubbleRight = null; // Allow it to expand rightwards
      if (bubbleLeft + 300 > screenWidth - 20) {
        // If it would overflow
        bubbleRight = 20;
      }
    } else {
      // Target is on the right, anchor bubble right
      bubbleRight = screenWidth - actualHighlightRect.right;
      bubbleLeft = null; // Allow it to expand leftwards
      if (bubbleRight + 300 > screenWidth - 20) {
        // If it would overflow
        bubbleLeft = 20;
      }
    }
    // Ensure bubbleLeft and bubbleRight are not too small if one is null
    bubbleLeft ??= 20;
    bubbleRight ??= 20;

    return Positioned(
      top: preferBelow ? bubbleTop : null,
      bottom: !preferBelow ? bubbleBottom : null,
      left: bubbleLeft,
      right: bubbleRight,
      child: Material(
        color: Colors.transparent, // Material for elevation and shape
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.8,
          ), // Max width for the bubble
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: messageStyle, textAlign: TextAlign.left),
              const SizedBox(height: 12.0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect targetRect;
  final Color overlayColor;
  final double cornerRadius;

  _OverlayPainter({
    required this.targetRect,
    this.overlayColor = Colors.black54,
    this.cornerRadius = 8.0, // Radius for the corners of the highlighted hole
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    // Create a path for the entire screen
    final screenPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a rounded rectangle path for the target area (the "hole")
    final targetPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(targetRect, Radius.circular(cornerRadius)),
        );

    // Combine the paths to create a screen-sized path with a hole
    final path = Path.combine(PathOperation.difference, screenPath, targetPath);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
