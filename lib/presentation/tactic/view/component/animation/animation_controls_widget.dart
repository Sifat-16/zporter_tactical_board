import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming this path
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this path
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

class PaceSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final String currentPaceText;
  final Color textColor;
  final double fontSize;

  const PaceSliderThumbShape({
    required this.enabledThumbRadius,
    required this.currentPaceText,
    this.textColor = Colors.black,
    this.fontSize = 10.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, paint);

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      text: currentPaceText,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    tp.layout();
    Offset textCenter = Offset(
      center.dx - (tp.width / 2),
      center.dy - (tp.height / 2),
    );
    tp.paint(canvas, textCenter);
  }
}

// New Reusable Animation Controls Widget
class AnimationControlsWidget extends StatefulWidget {
  final AnimationModel animationModel;
  final TacticBoard game;
  final bool initialIsPlaying;
  final double initialPaceFactor;
  // final List<double> paceValues; // Removed: paceValues will be internal
  // final VoidCallback onHardResetRequested;

  const AnimationControlsWidget({
    super.key,
    required this.game,
    required this.animationModel,
    required this.initialIsPlaying,
    required this.initialPaceFactor,
    // required this.paceValues, // Removed
    // required this.onHardResetRequested,
  });

  @override
  State<AnimationControlsWidget> createState() =>
      _AnimationControlsWidgetState();
}

class _AnimationControlsWidgetState extends State<AnimationControlsWidget> {
  late bool _isCurrentlyPlaying;
  late double _currentUiPaceFactor;

  // Define colors here or pass them as parameters if they need to be more dynamic
  final Color controlButtonColor = Colors.white;
  final Color controlButtonBackgroundColor = Colors.black.withOpacity(0.6);

  // Define paceValues internally
  final List<double> _paceValues = [0.5, 1.0, 2.0, 4.0, 8.0];

  @override
  void initState() {
    super.initState();
    _isCurrentlyPlaying = widget.initialIsPlaying;
    // Ensure initialPaceFactor is valid with internal _paceValues
    if (_paceValues.contains(widget.initialPaceFactor)) {
      _currentUiPaceFactor = widget.initialPaceFactor;
    } else {
      _currentUiPaceFactor = _paceValues.contains(1.0)
          ? 1.0
          : _paceValues.first; // Default to 1.0 or first available
      zlog(
          data:
              "ControlsWidget initState: initialPaceFactor ${widget.initialPaceFactor} is not in _paceValues. Defaulting to $_currentUiPaceFactor");
    }
    widget.game.setAnimationPace(_currentUiPaceFactor);
    _startAnimation();
  }

  _startAnimation() {
    widget.game.startAnimation(
        am: widget.animationModel,
        ap: _isCurrentlyPlaying,
        isForE: false,
        onExportP: (d) {});
  }

  @override
  void didUpdateWidget(covariant AnimationControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.game != oldWidget.game ||
        widget.initialIsPlaying != _isCurrentlyPlaying ||
        widget.initialPaceFactor != _currentUiPaceFactor) {
      _isCurrentlyPlaying = widget.initialIsPlaying;
      // Ensure initialPaceFactor is valid with internal _paceValues when widget updates
      if (_paceValues.contains(widget.initialPaceFactor)) {
        _currentUiPaceFactor = widget.initialPaceFactor;
      } else {
        // If the new initialPaceFactor is invalid, retain current or default.
        // This case might need more specific handling based on desired behavior.
        // For now, let's log and potentially keep the current valid pace or reset to default.
        zlog(
            data:
                "ControlsWidget didUpdateWidget: new initialPaceFactor ${widget.initialPaceFactor} is not in _paceValues. Current is $_currentUiPaceFactor");
        // Option: reset to a default if current _currentUiPaceFactor is also somehow invalid or if strict reset is needed
        _currentUiPaceFactor =
            _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
      }
      widget.game.setAnimationPace(_currentUiPaceFactor);
    }
  }

  void _togglePlayPause() async {
    if (!mounted) return;

    if (_isCurrentlyPlaying) {
      widget.game.pauseAnimation();
      zlog(data: "ControlsWidget: Pause button pressed.");
    } else {
      await widget.game.playAnimation();
      zlog(data: "ControlsWidget: Play button pressed.");
    }
    if (mounted) {
      setState(() {
        _isCurrentlyPlaying = !_isCurrentlyPlaying;
        zlog(
            data: "Came here to change the state toggle ${_isCurrentlyPlaying}",
            show: true);
      });
    }
  }

  void _handleHardReset() {
    zlog(data: "ControlsWidget: Hard Reset button pressed.");
    widget.game.pauseAnimation();

    if (mounted) {
      setState(() {
        _isCurrentlyPlaying = false;
        _currentUiPaceFactor =
            _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
      });
    }
    widget.game.resetAnimation();
    // widget.onHardResetRequested();
  }

  void _increaseSpeed() {
    if (!mounted) return;
    int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
    if (currentIndex < _paceValues.length - 1) {
      _setNewPace(_paceValues[currentIndex + 1]);
    }
  }

  void _decreaseSpeed() {
    if (!mounted) return;
    int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
    if (currentIndex > 0) {
      _setNewPace(_paceValues[currentIndex - 1]);
    }
  }

  void _setNewPace(double newPace) {
    // _paceValues is now internal, so no need for widget.paceValues.contains
    if (!_paceValues.contains(newPace)) {
      zlog(
          data:
              "ControlsWidget: Attempted to set invalid pace $newPace. Ignoring.");
      return;
    }
    if (_currentUiPaceFactor == newPace) return;
    if (!mounted) return;

    widget.game.setAnimationPace(newPace);
    if (mounted) {
      setState(() {
        _currentUiPaceFactor = newPace;
      });
    }
    zlog(data: "ControlsWidget: Pace factor set to $_currentUiPaceFactor");
  }

  @override
  Widget build(BuildContext context) {
    String formattedPaceText =
        "${_currentUiPaceFactor.toStringAsFixed(_currentUiPaceFactor % 1 == 0 ? 0 : 1)}x";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: controlButtonBackgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _togglePlayPause,
              splashColor: Colors.white24,
              child: Icon(
                _isCurrentlyPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: controlButtonColor,
                size: 28.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _decreaseSpeed,
              splashColor: Colors.white24,
              child: Icon(
                Icons.remove_circle_outline_rounded,
                color: controlButtonColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 150.0,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: controlButtonColor,
                inactiveTrackColor: controlButtonColor.withOpacity(0.3),
                trackHeight: 2.0,
                thumbColor: controlButtonColor,
                thumbShape: PaceSliderThumbShape(
                  enabledThumbRadius: 14.0,
                  currentPaceText: formattedPaceText,
                  textColor: ColorManager.black,
                  fontSize: 10.0,
                ),
                overlayColor: controlButtonColor.withAlpha(0x29),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 20.0),
                valueIndicatorColor: Colors.black.withOpacity(0.8),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
              child: Slider(
                value: _paceValues.indexOf(_currentUiPaceFactor).toDouble(),
                min: 0,
                max: (_paceValues.length - 1).toDouble(),
                divisions: _paceValues.length - 1,
                label: formattedPaceText,
                onChanged: (double value) {
                  int newIndex = value.round();
                  if (newIndex >= 0 && newIndex < _paceValues.length) {
                    _setNewPace(_paceValues[newIndex]);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _increaseSpeed,
              splashColor: Colors.white24,
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: controlButtonColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleHardReset,
              splashColor: Colors.white24,
              child: Icon(
                Icons.replay_rounded,
                color: controlButtonColor,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
