import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class TacticApp extends StatelessWidget {
  const TacticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zporter Board',
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          themeMode: ThemeMode.system,
          home: Scaffold(
            backgroundColor: ColorManager.black,
            body: TacticPage(userId: "DUMMY_USER_ID"),
          ),
          // home: GameScreen(),
        );
      },
    );
  }
}

class TacticPage extends StatefulWidget {
  const TacticPage({super.key, required this.userId, this.onFullScreenChanged});

  final String userId;
  final ValueChanged<bool>? onFullScreenChanged;

  @override
  State<TacticPage> createState() => _TacticPageState();
}

class _TacticPageState extends State<TacticPage> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final bp = ref.watch(boardProvider);
          WidgetsBinding.instance.addPostFrameCallback((t) {
            widget.onFullScreenChanged?.call(bp.showFullScreen);
          });
          return TacticboardScreen(userId: widget.userId);
        },
      ),
      // body: DrawingScreen(),
    );
  }
}

// class DrawingScreen extends StatefulWidget {
//   const DrawingScreen({super.key});
//
//   @override
//   State<DrawingScreen> createState() => _DrawingScreenState();
// }
//
// class _DrawingScreenState extends State<DrawingScreen> {
//   // State variables
//   final List<DrawingPoint?> _points = <DrawingPoint?>[]; // List to store points
//   Color _selectedColor = Colors.black; // Default drawing color
//   double _strokeWidth = 5.0; // Default stroke width
//   bool _isErasing = false; // Flag for eraser mode
//
//   // --- Helper Methods ---
//
//   Paint _getCurrentPaint() {
//     return Paint()
//       ..color =
//           _isErasing
//               ? Colors.white
//               : _selectedColor // White for eraser
//       ..strokeCap = StrokeCap.round
//       ..isAntiAlias = true
//       ..strokeWidth =
//           _isErasing ? 20.0 : _strokeWidth; // Wider stroke for eraser
//     // ..style = PaintingStyle.stroke; // Ensure we draw lines/strokes
//     // Note: Paint style defaults to fill, but drawLine implicitly uses stroke.
//     // For drawPoints, you might need style = PaintingStyle.stroke explicitly if using large strokeWidth.
//   }
//
//   void _addPoint(Offset? offset) {
//     // Add a DrawingPoint (or null for breaks) to the list and trigger rebuild
//     setState(() {
//       _points.add(DrawingPoint(offset: offset, paint: _getCurrentPaint()));
//     });
//   }
//
//   void _clearScreen() {
//     setState(() {
//       _points.clear();
//     });
//   }
//
//   // --- Build Method ---
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Ensure the Scaffold's background is white, matching the eraser
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // --- Drawing Area ---
//           GestureDetector(
//             onPanStart: (details) {
//               // Add the starting point of a new stroke
//               _addPoint(details.localPosition);
//             },
//             onPanUpdate: (details) {
//               // Add subsequent points as the user drags
//               _addPoint(details.localPosition);
//             },
//             onPanEnd: (details) {
//               // Add a null point to signify the end of the current stroke
//               // This prevents lines connecting across separate gestures
//               _addPoint(null);
//             },
//             child: CustomPaint(
//               painter: DrawingPainter(pointsList: _points),
//               // Ensure the CustomPaint covers the entire screen
//               size: Size.infinite,
//             ),
//           ),
//
//           // --- Control Buttons ---
//           Positioned(
//             top: 40.0, // Adjust position as needed
//             right: 10.0,
//             child: Column(
//               // Use Column for vertical arrangement
//               children: [
//                 // Pencil Button
//                 FloatingActionButton(
//                   mini: true, // Smaller button
//                   heroTag: "pencil_button", // Unique hero tag
//                   backgroundColor:
//                       _isErasing ? Colors.grey : Colors.blue, // Visual feedback
//                   onPressed: () {
//                     setState(() {
//                       _isErasing = false;
//                       _selectedColor = Colors.black; // Reset to default color
//                     });
//                   },
//                   child: const Icon(Icons.edit, color: Colors.white),
//                 ),
//                 const SizedBox(height: 10), // Spacing
//                 // Eraser Button
//                 FloatingActionButton(
//                   mini: true,
//                   heroTag: "eraser_button", // Unique hero tag
//                   backgroundColor:
//                       _isErasing ? Colors.blue : Colors.grey, // Visual feedback
//                   onPressed: () {
//                     setState(() {
//                       _isErasing = true;
//                     });
//                   },
//                   child: const Icon(
//                     Icons.cleaning_services_rounded,
//                     color: Colors.white,
//                   ), // Eraser icon
//                 ),
//                 const SizedBox(height: 10), // Spacing
//                 // Optional: Clear Button
//                 FloatingActionButton(
//                   mini: true,
//                   heroTag: "clear_button", // Unique hero tag
//                   backgroundColor: Colors.redAccent,
//                   onPressed: _clearScreen, // Call the clear function
//                   child: const Icon(Icons.clear, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DrawingPainter extends CustomPainter {
//   final List<DrawingPoint?> pointsList; // List can contain nulls to break lines
//
//   DrawingPainter({required this.pointsList});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < pointsList.length - 1; i++) {
//       final currentPoint = pointsList[i];
//       final nextPoint = pointsList[i + 1];
//
//       // Only draw a line if both points are non-null
//       if (currentPoint?.offset != null && nextPoint?.offset != null) {
//         // Use the paint object associated with the *current* point for the line segment
//         canvas.drawLine(
//           currentPoint!.offset!,
//           nextPoint!.offset!,
//           currentPoint.paint,
//         );
//       }
//       // If the current point is not null but the next one is null, it represents a single dot
//       // Or the end of a line segment. We can draw a point, though drawLine handles most cases.
//       else if (currentPoint?.offset != null && nextPoint?.offset == null) {
//         // Optionally draw a point for the last point of a stroke
//         // canvas.drawPoints(PointMode.points, [currentPoint!.offset!], currentPoint.paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // Repaint whenever the points list changes
//     return true;
//   }
// }
//
// class DrawingPoint {
//   Offset? offset; // Nullable Offset to indicate breaks in the line
//   Paint paint;
//
//   DrawingPoint({required this.offset, required this.paint});
// }
