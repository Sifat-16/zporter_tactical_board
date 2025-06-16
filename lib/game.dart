// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame/game.dart';
// import 'package:flutter/material.dart';
//
// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});
//
//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen> {
//   // Game instance remains the same
//   final DrawingGame _myGame = DrawingGame();
//   // Keep UI state separate
//   DrawMode _selectedMode = DrawMode.draw;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flame Drawing Component'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             tooltip: 'Draw',
//             color: _selectedMode == DrawMode.draw ? Colors.blue : Colors.grey,
//             onPressed: () {
//               // Access component via game instance
//               _myGame.drawingBoard.setMode(DrawMode.draw);
//               setState(() {
//                 _selectedMode = DrawMode.draw;
//               });
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.cleaning_services),
//             tooltip: 'Erase',
//             color: _selectedMode == DrawMode.erase ? Colors.blue : Colors.grey,
//             onPressed: () {
//               // Access component via game instance
//               _myGame.drawingBoard.setMode(DrawMode.erase);
//               setState(() {
//                 _selectedMode = DrawMode.erase;
//               });
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_forever),
//             tooltip: 'Clear All',
//             onPressed: () {
//               // Access component via game instance
//               _myGame.drawingBoard.clearBoard();
//               // Game render loop will update, no setState needed here for game view
//             },
//           ),
//         ],
//       ),
//       body: GameWidget(
//         game: _myGame,
//         // No padding needed here if game background is distinct
//         // and component is positioned correctly within the game.
//       ),
//     );
//   }
// }
//
// // Enum to manage drawing modes
// enum DrawMode { draw, erase }
//
// // Use HasDraggablesBridge to allow components to receive drag events
// class DrawingGame extends FlameGame {
//   late DrawingBoardComponent drawingBoard;
//
//   final Color gameBackgroundColor =
//       Colors.grey.shade800; // Background of the game area itself
//
//   @override
//   Color backgroundColor() => gameBackgroundColor; // Set game background
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//
//     // Define the size and position of the drawing board within the game area
//     // Example: Centered board with some padding
//     const double padding = 20.0;
//     final Vector2 boardSize = Vector2(
//       size.x - padding * 2, // Use game size (available in onLoad)
//       size.y - padding * 2,
//     );
//     final Vector2 boardPosition = Vector2(padding, padding);
//
//     drawingBoard = DrawingBoardComponent(
//       position: boardPosition,
//       size: boardSize,
//       boardColor: Colors.grey.shade200, // Pass configuration
//       borderColor: Colors.black,
//       borderWidth: 5.0,
//       drawingColor: Colors.redAccent, // Changed color for demo
//       drawingStrokeWidth: 4.0,
//       eraserColor: Colors.grey.shade200, // Match board color for erasing
//       eraserStrokeWidth: 20.0,
//     );
//
//     // Add the component to the game tree
//     add(drawingBoard);
//   }
//
//   // No need for render or input methods here anymore,
//   // unless the game itself needs other interactions.
// }
//
// // class DrawingBoardComponent extends PositionComponent with DragCallbacks {
// //   // ----- Component Settings -----
// //   // Made these final and passable via constructor for reusability
// //   final Color boardColor;
// //   final Color borderColor;
// //   final double borderWidth;
// //   final Color drawingColor;
// //   final double drawingStrokeWidth;
// //   final Color eraserColor; // Usually same as boardColor
// //   final double eraserStrokeWidth;
// //
// //   // ----- State -----
// //   DrawMode currentMode = DrawMode.draw;
// //   List<List<Offset>> _drawnLines = [];
// //   List<List<Offset>> _erasedLines = [];
// //   List<Offset>? _currentLine;
// //
// //   // ----- Internal -----
// //   late final Paint _borderPaint;
// //   late final Paint _drawingPaint;
// //   late final Paint _eraserPaint;
// //   late final Paint _backgroundPaint; // Paint for board background
// //   late Rect
// //   _boardRect; // The rectangle defining the drawable area inside borders
// //
// //   DrawingBoardComponent({
// //     this.boardColor = Colors.white, // Default background
// //     this.borderColor = Colors.black,
// //     this.borderWidth = 5.0,
// //     this.drawingColor = Colors.blue,
// //     this.drawingStrokeWidth = 3.0,
// //     this.eraserColor =
// //         Colors.white, // Default eraser color (same as background)
// //     this.eraserStrokeWidth = 15.0,
// //     Vector2? position,
// //     Vector2? size,
// //   }) : super(position: position, size: size);
// //
// //   @override
// //   Future<void> onLoad() async {
// //     super.onLoad();
// //     // Ensure size is set (required for drawing)
// //     assert(size.x > 0 && size.y > 0, 'DrawingBoardComponent must have a size.');
// //
// //     // Use the component's size
// //     _boardRect = Rect.fromLTWH(
// //       borderWidth / 2,
// //       borderWidth / 2,
// //       size.x - borderWidth,
// //       size.y - borderWidth,
// //     );
// //
// //     // Initialize paints
// //     _backgroundPaint = Paint()..color = boardColor;
// //
// //     _borderPaint =
// //         Paint()
// //           ..color = borderColor
// //           ..style = PaintingStyle.stroke
// //           ..strokeWidth = borderWidth;
// //
// //     _drawingPaint =
// //         Paint()
// //           ..color = drawingColor
// //           ..style = PaintingStyle.stroke
// //           ..strokeWidth = drawingStrokeWidth
// //           ..strokeCap = StrokeCap.round
// //           ..isAntiAlias = true;
// //
// //     _eraserPaint =
// //         Paint()
// //           ..color =
// //               eraserColor // Use the specified eraser color
// //           ..style = PaintingStyle.stroke
// //           ..strokeWidth = eraserStrokeWidth
// //           ..strokeCap = StrokeCap.round
// //           ..isAntiAlias = true;
// //   }
// //
// //   @override
// //   void render(Canvas canvas) {
// //     super.render(canvas); // For potential children in the future
// //
// //     // Important: Coordinates are relative to the component's position (0,0 is top-left)
// //
// //     // 1. Draw the background color for the component's area
// //     canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _backgroundPaint);
// //
// //     // Clip drawing to the board area (optional, but prevents drawing over borders)
// //     // canvas.save();
// //     // canvas.clipRect(_boardRect); // Uncomment if you want strict clipping
// //
// //     // 2. Draw completed "drawn" lines
// //     _drawPathList(canvas, _drawnLines, _drawingPaint);
// //
// //     // 3. Draw completed "erased" lines
// //     _drawPathList(canvas, _erasedLines, _eraserPaint);
// //
// //     // 4. Draw the current line in progress
// //     if (_currentLine != null && _currentLine!.length > 1) {
// //       final currentPaint =
// //           (currentMode == DrawMode.draw) ? _drawingPaint : _eraserPaint;
// //       _drawPath(canvas, _currentLine!, currentPaint);
// //     }
// //
// //     // canvas.restore(); // Uncomment if you used canvas.clipRect
// //
// //     // 5. Draw the border on top
// //     canvas.drawRect(_boardRect, _borderPaint);
// //   }
// //
// //   // Helper to draw a list of paths
// //   void _drawPathList(Canvas canvas, List<List<Offset>> lines, Paint paint) {
// //     for (final line in lines) {
// //       if (line.length > 1) {
// //         _drawPath(canvas, line, paint);
// //       }
// //     }
// //   }
// //
// //   // Helper to draw a single path
// //   void _drawPath(Canvas canvas, List<Offset> line, Paint paint) {
// //     final path = Path()..moveTo(line.first.dx, line.first.dy);
// //     for (int i = 1; i < line.length; i++) {
// //       path.lineTo(line[i].dx, line[i].dy);
// //     }
// //     canvas.drawPath(path, paint);
// //   }
// //
// //   // --- DragDetector Methods ---
// //   // These receive coordinates relative to the component's origin
// //
// //   @override
// //   void onDragStart(DragStartEvent event) {
// //     super.onDragStart(event);
// //     if (_boardRect.contains(event.localPosition.toOffset())) {
// //       // Only start draw if inside board
// //       _currentLine = [event.localPosition.toOffset()];
// //     } else {
// //       _currentLine = null; // Don't start drawing if click is outside
// //     }
// //   }
// //
// //   @override
// //   void onDragUpdate(DragUpdateEvent event) {
// //     super.onDragUpdate(event);
// //     // Add point even if it goes slightly outside, line ends when releasing outside
// //     if (_currentLine != null) {
// //       _currentLine!.add(event.localPosition.toOffset());
// //     }
// //   }
// //
// //   @override
// //   void onDragEnd(DragEndEvent event) {
// //     super.onDragEnd(event);
// //     if (_currentLine != null && _currentLine!.isNotEmpty) {
// //       // Clip the line to the boundaries before saving (optional refinement)
// //       // List<Offset> clippedLine = _clipLineToRect(_currentLine!, _boardRect);
// //
// //       // Only add if the line has substance
// //       if (_currentLine!.length > 1) {
// //         if (currentMode == DrawMode.draw) {
// //           _drawnLines.add(List<Offset>.from(_currentLine!));
// //         } else if (currentMode == DrawMode.erase) {
// //           _erasedLines.add(List<Offset>.from(_currentLine!));
// //         }
// //       }
// //     }
// //     _currentLine = null; // Finish the current line
// //   }
// //
// //   @override
// //   void onDragCancel(DragCancelEvent event) {
// //     super.onDragCancel(event);
// //     _currentLine = null; // Cancel the current line
// //   }
// //
// //   // --- Public Methods for Control ---
// //
// //   void setMode(DrawMode mode) {
// //     currentMode = mode;
// //   }
// //
// //   void clearBoard() {
// //     _drawnLines.clear();
// //     _erasedLines.clear();
// //     _currentLine = null; // Ensure current line is also cleared
// //   }
// //
// //   // Optional: A method to get the drawing as an image
// //   // Future<ui.Image> renderToImage() { ... }
// // }
