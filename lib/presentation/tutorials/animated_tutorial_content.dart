// lib/app/widgets/animated_tutorial_content.dart
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path if needed

class AnimatedTutorialContent extends StatefulWidget {
  final String title;
  final String message;
  final bool showFingerDragAnimation;

  /// Alignment of the finger icon at the START of its animation,
  /// relative to this AnimatedTutorialContent widget's bounds.
  final Alignment fingerAnimationStartAlign;

  /// The vector by which the finger should slide from its starting aligned position
  /// (in logical pixels). This needs to be calculated by the caller to point
  /// from the player towards the field.
  final Offset fingerDragVector;

  const AnimatedTutorialContent({
    super.key,
    required this.title,
    required this.message,
    this.showFingerDragAnimation = false,
    this.fingerAnimationStartAlign =
        Alignment.center, // Default, should be customized by caller
    this.fingerDragVector = const Offset(
      70,
      -35,
    ), // Default, MUST be customized by caller
  });

  @override
  State<AnimatedTutorialContent> createState() =>
      _AnimatedTutorialContentState();
}

class _AnimatedTutorialContentState extends State<AnimatedTutorialContent>
    with TickerProviderStateMixin {
  late AnimationController _slideFadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  AnimationController? _fingerController;
  Animation<Offset>?
  _fingerSlideAnimation; // This will use widget.fingerDragVector
  Animation<double>? _fingerOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for the main content bubble's slide and fade animation
    _slideFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Animation for the bubble sliding in (e.g., from bottom)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3), // Start slightly below its final position
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideFadeController, curve: Curves.easeOutCubic),
    );
    // Animation for the bubble fading in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideFadeController, curve: Curves.easeInOut),
    );
    _slideFadeController.forward(); // Start the bubble's entrance animation

    // Setup for finger drag animation if enabled
    if (widget.showFingerDragAnimation) {
      _fingerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800), // Duration for one loop
      );

      // Finger slide animation:
      // It starts at Offset.zero (which is relative to its initial position defined by fingerAnimationStartAlign)
      // and moves by the amount specified in widget.fingerDragVector.
      _fingerSlideAnimation = Tween<Offset>(
        begin: Offset.zero, // Start at the aligned position
        end: widget.fingerDragVector, // Slide by this vector
      ).animate(
        CurvedAnimation(
          parent: _fingerController!,
          curve: Curves.easeInOutSine, // A smooth curve for the slide
        ),
      );

      // Finger icon opacity animation: fade in, stay, fade out during its slide
      _fingerOpacityAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0),
          weight: 15,
        ), // Fade in part
        TweenSequenceItem(
          tween: ConstantTween(1.0),
          weight: 60,
        ), // Visible part
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0),
          weight: 25,
        ), // Fade out part
      ]).animate(
        CurvedAnimation(parent: _fingerController!, curve: Curves.linear),
      );

      // REVERTED: Added back the Future.delayed for the finger animation controller
      // to prevent it from appearing too abruptly if the bubble itself is also animating in.
      Future.delayed(const Duration(milliseconds: 500), () {
        // You can adjust this delay
        if (mounted && _fingerController != null) {
          _fingerController!.repeat(); // Start repeating the animation
        }
      });
    }
  }

  @override
  void dispose() {
    _slideFadeController.dispose();
    _fingerController
        ?.dispose(); // Dispose finger controller if it was initialized
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main text bubble content
    Widget textContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color:
            ColorManager.blueAccent ??
            Colors.blue.shade800, // Use your app's theme color
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorManager.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.message,
            style: TextStyle(
              color: ColorManager.white.withOpacity(0.95),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    Widget finalContent = textContent;

    // If finger animation is enabled, wrap the text content in a Stack
    // to overlay the animated finger icon.
    if (widget.showFingerDragAnimation &&
        _fingerController != null &&
        _fingerSlideAnimation != null &&
        _fingerOpacityAnimation != null) {
      finalContent = Stack(
        clipBehavior:
            Clip.none, // Allows finger to animate outside the bubble's painted bounds if necessary
        alignment: Alignment.center, // Base alignment for the Stack itself
        children: [
          textContent, // The text bubble
          // Positioned.fill makes the Align widget take up the same space as the textContent bubble.
          // The finger icon's animation (SlideTransition) will then be relative to this space,
          // starting at the point defined by widget.fingerAnimationStartAlign.
          Positioned.fill(
            child: Align(
              alignment:
                  widget
                      .fingerAnimationStartAlign, // Initial position of the finger icon
              child: SlideTransition(
                position:
                    _fingerSlideAnimation!, // Animates the finger from its start by fingerDragVector
                child: FadeTransition(
                  opacity: _fingerOpacityAnimation!,
                  child: Icon(
                    Icons.touch_app_outlined, // A standard touch/drag icon
                    color: ColorManager.yellow, // Bright color for visibility
                    size: 40, // Adjust size as needed
                    shadows: [
                      // Optional: add a shadow for better visibility
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Apply the overall slide and fade animation for the entire content (bubble + optional finger)
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: finalContent),
    );
  }
}
