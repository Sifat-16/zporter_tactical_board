import 'package:flutter/material.dart';

void showFullScreenOverlay(BuildContext context, {required Widget child}) {
  // Declare the OverlayEntry variable
  OverlayEntry? overlayEntry;

  // Define the function that will remove this specific overlay entry
  void hideOverlay() {
    // Check if entry exists and is mounted before removing
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null; // Clear the reference
    }
  }

  // Create the OverlayEntry using the wrapper widget
  overlayEntry = OverlayEntry(
    builder: (context) {
      // Pass the user's child and the hide function to the container
      return _FullScreenOverlayContainer(
        onClose: hideOverlay, // Provide the way to close it
        child: child, // The content to show
      );
    },
  );

  // Get the OverlayState and insert the entry
  final overlay = Overlay.of(context);
  overlay.insert(overlayEntry!);
}

/// Internal widget defining the structure and appearance of the full-screen overlay.
class _FullScreenOverlayContainer extends StatelessWidget {
  /// The content widget provided by the user.
  final Widget child;

  /// The function to call when the close button is tapped.
  final VoidCallback onClose;

  const _FullScreenOverlayContainer({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Define Dark Theme Colors (or get from theme for more flexibility)
    final darkBackgroundColor = const Color(
      0xFF2A2A2A,
    ); // Slightly different dark grey
    final closeButtonColor = Colors.grey[300]; // Lighter grey for icon
    final closeButtonBackgroundColor = Colors.black.withOpacity(0.4);

    return Material(
      // Full screen semi-transparent barrier
      color: Colors.black.withOpacity(0.65),
      child: Center(
        // Size constraint container
        child: FractionallySizedBox(
          widthFactor: 0.98,
          heightFactor: 0.98,
          child: Container(
            clipBehavior:
                Clip.antiAlias, // Ensures content respects border radius
            decoration: BoxDecoration(
              color: darkBackgroundColor,
              borderRadius: BorderRadius.circular(16.0), // Soft rounded corners
              boxShadow: const [
                // Subtle shadow
                BoxShadow(color: Colors.black26, blurRadius: 12.0),
              ],
            ),
            child: Stack(
              // Stack for content + close button
              children: [
                // --- User's Content Area ---
                // Positioned.fill ensures the child tries to fill the space
                // Add Padding so content doesn't go under the close button
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      50,
                      20,
                      20,
                    ), // More top padding
                    child: child, // Display the user-provided widget
                  ),
                ),
                // --- End User's Content ---

                // --- Close Button ---
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Material(
                    // Use Material for ink splash on tap
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // InkWell provides splash
                      splashColor: Colors.white12,
                      onTap: onClose, // Call the close callback
                      child: Container(
                        padding: const EdgeInsets.all(
                          4,
                        ), // Padding around the icon
                        decoration: BoxDecoration(
                          color: closeButtonBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: closeButtonColor,
                          size: 26.0,
                        ),
                      ),
                    ),
                  ),
                ),
                // --- End Close Button ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}
