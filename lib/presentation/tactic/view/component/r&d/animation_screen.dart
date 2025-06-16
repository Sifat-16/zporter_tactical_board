// import 'package:flame_riverpod/flame_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';
//
// GlobalKey<RiverpodAwareGameWidgetState> animationWidgetKey =
//     GlobalKey<RiverpodAwareGameWidgetState>();
//
// // Custom SliderThumbShape to display text inside the thumb
// class PaceSliderThumbShape extends SliderComponentShape {
//   final double enabledThumbRadius;
//   final String currentPaceText; // Changed: Now takes the text directly
//   final Color textColor;
//   final double fontSize;
//
//   const PaceSliderThumbShape({
//     required this.enabledThumbRadius,
//     required this.currentPaceText, // Pass the formatted text here
//     this.textColor = Colors.black,
//     this.fontSize = 10.0,
//   });
//
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) {
//     return Size.fromRadius(enabledThumbRadius);
//   }
//
//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     required Animation<double> activationAnimation,
//     required Animation<double> enableAnimation,
//     required bool isDiscrete,
//     required TextPainter labelPainter,
//     required RenderBox parentBox,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required double
//         value, // This 'value' (slider's index) is now ignored for text display
//     required double textScaleFactor,
//     required Size sizeWithOverflow,
//   }) {
//     final Canvas canvas = context.canvas;
//
//     // Draw the thumb circle
//     final Paint paint = Paint()
//       ..color = sliderTheme.thumbColor ?? Colors.blue
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(center, enabledThumbRadius, paint);
//
//     // Use the currentPaceText directly passed in constructor
//     TextSpan span = TextSpan(
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),
//       text: this.currentPaceText, // Use the member variable
//     );
//     TextPainter tp = TextPainter(
//       text: span,
//       textAlign: TextAlign.center,
//       textDirection: textDirection,
//     );
//     tp.layout();
//     Offset textCenter = Offset(
//       center.dx - (tp.width / 2),
//       center.dy - (tp.height / 2),
//     );
//     tp.paint(canvas, textCenter);
//   }
// }
//
// class AnimationScreen extends ConsumerStatefulWidget {
//   const AnimationScreen({
//     super.key,
//     required this.animationModel,
//     required this.heroTag,
//   });
//
//   final AnimationModel animationModel;
//   final Object heroTag;
//
//   @override
//   ConsumerState<AnimationScreen> createState() => _AnimationScreenState();
// }
//
// class _AnimationScreenState extends ConsumerState<AnimationScreen> {
//   late TacticBoardGameAnimation tacticBoardGame;
//
//   bool _isCurrentlyPlaying = true;
//
//   final List<double> _paceValues = [0.5, 1.0, 2.0, 4.0, 8.0];
//   double _currentUiPaceFactor = 1.0;
//
//   @override
//   void initState() {
//     super.initState();
//     zlog(
//       data:
//           "AnimationScreen initState: Creating TacticBoardGameAnimation instance.",
//     );
//
//     tacticBoardGame = TacticBoardGameAnimation(
//       animationModel: widget.animationModel,
//       autoPlay: true,
//     );
//     tacticBoardGame.setAnimationPace(_currentUiPaceFactor);
//   }
//
//   final closeButtonColor = Colors.grey[300];
//   final closeButtonBackgroundColor = Colors.black.withOpacity(0.4);
//   final controlButtonColor = Colors.white; // This will be the thumb color
//   final controlButtonBackgroundColor = Colors.black.withOpacity(0.6);
//
//   void _togglePlayPause() async {
//     if (!mounted) return;
//
//     if (_isCurrentlyPlaying) {
//       tacticBoardGame.pauseAnimation();
//       zlog(data: "UI: Pause button pressed.");
//     } else {
//       await tacticBoardGame.playAnimation();
//       zlog(data: "UI: Play button pressed.");
//     }
//     if (mounted) {
//       setState(() {
//         _isCurrentlyPlaying = !_isCurrentlyPlaying;
//       });
//     }
//   }
//
//   void _handleHardReset() {
//     zlog(data: "UI: Hard Reset button pressed. Calling game.resetAnimation()");
//     tacticBoardGame.pauseAnimation();
//
//     if (mounted) {
//       setState(() {
//         animationWidgetKey = GlobalKey<RiverpodAwareGameWidgetState>();
//         tacticBoardGame = TacticBoardGameAnimation(
//           animationModel: widget.animationModel,
//           autoPlay: false,
//         );
//         _isCurrentlyPlaying = false;
//         _currentUiPaceFactor = 1.0;
//         tacticBoardGame.setAnimationPace(_currentUiPaceFactor);
//       });
//     }
//   }
//
//   void _increaseSpeed() {
//     if (!mounted) return;
//     int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
//     if (currentIndex < _paceValues.length - 1) {
//       _setNewPace(_paceValues[currentIndex + 1]);
//     }
//   }
//
//   void _decreaseSpeed() {
//     if (!mounted) return;
//     int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
//     if (currentIndex > 0) {
//       _setNewPace(_paceValues[currentIndex - 1]);
//     }
//   }
//
//   void _setNewPace(double newPace) {
//     if (!_paceValues.contains(newPace)) {
//       zlog(data: "UI: Attempted to set invalid pace $newPace. Ignoring.");
//       return;
//     }
//     if (_currentUiPaceFactor == newPace) return;
//     if (!mounted) return;
//
//     tacticBoardGame.setAnimationPace(newPace);
//     if (mounted) {
//       setState(() {
//         _currentUiPaceFactor = newPace;
//       });
//     }
//     zlog(data: "UI: Pace factor set to $_currentUiPaceFactor");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     zlog(
//       data:
//           "AnimationScreen: build method called. _isCurrentlyPlaying: $_isCurrentlyPlaying, Pace: $_currentUiPaceFactor",
//     );
//
//     // Format the current pace factor string here to pass to the thumb shape
//     String formattedPaceText =
//         "${_currentUiPaceFactor.toStringAsFixed(_currentUiPaceFactor % 1 == 0 ? 0 : 1)}x";
//
//     return Scaffold(
//       backgroundColor: ColorManager.black,
//       body: SafeArea(
//         child: Center(
//           child: Hero(
//             tag: widget.heroTag,
//             child: Stack(
//               children: [
//                 Center(
//                   child: RiverpodAwareGameWidget(
//                     game: tacticBoardGame,
//                     key: animationWidgetKey,
//                   ),
//                 ),
//                 Positioned(
//                   top: 10.0,
//                   right: 10.0,
//                   child: Material(
//                     color: Colors.transparent,
//                     shape: const CircleBorder(),
//                     clipBehavior: Clip.antiAlias,
//                     child: InkWell(
//                       splashColor: Colors.white12,
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: closeButtonBackgroundColor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.close,
//                           color: closeButtonColor,
//                           size: 26.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0.0,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6.0,
//                         vertical: 3.0,
//                       ),
//                       decoration: BoxDecoration(
//                         color: controlButtonBackgroundColor,
//                         borderRadius: BorderRadius.circular(30.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         spacing: 16,
//                         children: [
//                           Material(
//                             color: Colors.transparent,
//                             shape: const CircleBorder(),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: _togglePlayPause,
//                               splashColor: Colors.white24,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(10.0),
//                                 child: Icon(
//                                   _isCurrentlyPlaying
//                                       ? Icons.pause_rounded
//                                       : Icons.play_arrow_rounded,
//                                   color: controlButtonColor,
//                                   size: 28.0,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Material(
//                             color: Colors.transparent,
//                             shape: const CircleBorder(),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: _decreaseSpeed,
//                               splashColor: Colors.white24,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Icon(
//                                   Icons.remove_circle_outline_rounded,
//                                   color: controlButtonColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 150.0,
//                             child: SliderTheme(
//                               data: SliderTheme.of(context).copyWith(
//                                 activeTrackColor: controlButtonColor,
//                                 inactiveTrackColor:
//                                     controlButtonColor.withOpacity(0.3),
//                                 trackHeight: 2.0,
//                                 thumbColor: controlButtonColor,
//                                 thumbShape: PaceSliderThumbShape(
//                                   // Use the updated shape
//                                   enabledThumbRadius: 14.0,
//                                   currentPaceText:
//                                       formattedPaceText, // Pass the text
//                                   textColor: ColorManager.black,
//                                   fontSize: 10.0,
//                                 ),
//                                 overlayColor: controlButtonColor.withAlpha(
//                                   0x29,
//                                 ),
//                                 overlayShape: const RoundSliderOverlayShape(
//                                   overlayRadius: 20.0,
//                                 ),
//                                 valueIndicatorColor: Colors.black.withOpacity(
//                                   0.8,
//                                 ),
//                                 valueIndicatorTextStyle: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12.0,
//                                 ),
//                               ),
//                               child: Slider(
//                                 value: _paceValues
//                                     .indexOf(_currentUiPaceFactor)
//                                     .toDouble(),
//                                 min: 0,
//                                 max: (_paceValues.length - 1).toDouble(),
//                                 divisions: _paceValues.length - 1,
//                                 label:
//                                     formattedPaceText, // Standard label also uses this
//                                 onChanged: (double value) {
//                                   int newIndex = value.round();
//                                   if (newIndex >= 0 &&
//                                       newIndex < _paceValues.length) {
//                                     _setNewPace(_paceValues[newIndex]);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                           Material(
//                             color: Colors.transparent,
//                             shape: const CircleBorder(),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: _increaseSpeed,
//                               splashColor: Colors.white24,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Icon(
//                                   Icons.add_circle_outline_rounded,
//                                   color: controlButtonColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Material(
//                             color: Colors.transparent,
//                             shape: const CircleBorder(),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: _handleHardReset,
//                               splashColor: Colors.white24,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Icon(
//                                   Icons.replay_rounded,
//                                   color: controlButtonColor,
//                                   size: 26.0,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
