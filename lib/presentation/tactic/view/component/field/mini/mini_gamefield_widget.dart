// import 'package:flame/extensions.dart'; // For Vector2
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
// // Import models
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart'; // Adjust import path
//
// // Import painter
// import 'mini_game_field_painter.dart'; // Adjust import path
//
// class MiniGameFieldWidget extends StatelessWidget {
//   final double aspectRatio;
//   final Color fieldColor;
//   final Color borderColor;
//   // --- NEW PROPERTIES ---
//   /// The list of items (players, equipment, forms) to display.
//   final List<FieldItemModel> items;
//
//   /// The logical "world" size of the main tactical board these items relate to.
//   final Vector2 logicalFieldSize;
//
//   static const double defaultAspectRatio = 105 / 68; // Example default
//
//   const MiniGameFieldWidget({
//     super.key,
//     this.aspectRatio = defaultAspectRatio,
//     this.fieldColor =
//         ColorManager.grey, // Ensure ColorManager is defined/imported
//     this.borderColor =
//         ColorManager.black, // Ensure ColorManager is defined/imported
//     required this.items, // Items are required
//     required this.logicalFieldSize, // Reference size is required
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Calculate actual dimensions based on constraints and aspect ratio
//         double actualWidth;
//         double actualHeight;
//
//         // Prioritize using parent's width if available and bounded
//         if (constraints.hasBoundedWidth && !constraints.maxWidth.isInfinite) {
//           actualWidth = constraints.maxWidth;
//           actualHeight = actualWidth / aspectRatio;
//           // Adjust if height becomes too large for parent's height constraint
//           if (constraints.hasBoundedHeight &&
//               actualHeight > constraints.maxHeight) {
//             actualHeight = constraints.maxHeight;
//             actualWidth = actualHeight * aspectRatio;
//           }
//         }
//         // Else if parent's height is bounded, calculate width from height
//         else if (constraints.hasBoundedHeight &&
//             !constraints.maxHeight.isInfinite) {
//           actualHeight = constraints.maxHeight;
//           actualWidth = actualHeight * aspectRatio;
//         }
//         // Fallback if both width and height are unconstrained
//         else {
//           print(
//             "Warning: MiniGameFieldWidget parent has unconstrained dimensions. Using fallback width 100.",
//           );
//           actualWidth = 100.0;
//           actualHeight = actualWidth / aspectRatio;
//         }
//
//         // Use SizedBox to enforce the calculated size for the CustomPaint
//         return SizedBox(
//           width: actualWidth,
//           height: actualHeight,
//           child: CustomPaint(
//             // Pass all necessary data to the painter
//             painter: MiniGameFieldPainter(
//               fieldColor: fieldColor,
//               borderColor: borderColor,
//               items: items, // Pass the items
//               logicalFieldSize: Vector2(
//                 actualWidth,
//                 actualHeight,
//               ), // Pass the reference size
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'dart:ui'
    as ui; // For ui.Image, Path, Rect, RRect, Radius, Offset, Codec

import 'package:flame/extensions.dart'; // For Vector2 extensions
import 'package:flutter/foundation.dart'; // For listEquals
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// Import your models
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

import 'mini_game_field_painter.dart';
// Assuming FormModel and its sub-models might be used later
// import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

// --- Helper function to load ui.Image from asset ---
Future<ui.Image> loadUiImage(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}
// --- End Helper ---

// ---------- MiniGameFieldWidget (Now StatefulWidget) ----------
class MiniGameFieldWidget extends StatefulWidget {
  final double aspectRatio;
  final Color fieldColor;
  final Color borderColor;
  final List<FieldItemModel> items;
  final Vector2 logicalFieldSize;
  final BoardBackground boardBackground;

  static const double defaultAspectRatio = 105 / 68;

  const MiniGameFieldWidget({
    super.key,
    this.aspectRatio = defaultAspectRatio,
    this.fieldColor = ColorManager.grey,
    this.borderColor = ColorManager.black,
    required this.items,
    required this.logicalFieldSize,
    required this.boardBackground,
  });

  @override
  State<MiniGameFieldWidget> createState() => _MiniGameFieldWidgetState();
}

class _MiniGameFieldWidgetState extends State<MiniGameFieldWidget> {
  Map<String, ui.Image> _loadedImages = {};
  bool _areImagesReady = false; // Flag to indicate if images are loaded

  @override
  void initState() {
    super.initState();
    _processAndLoadImages();
  }

  @override
  void didUpdateWidget(covariant MiniGameFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If items list identity changes or logicalFieldSize changes (which affects scaling),
    // we might need to re-process images if new ones appear or if scaling strategy depends on it.
    // For simplicity, if items change, we re-initiate the image loading process.
    if (!listEquals(widget.items, oldWidget.items)) {
      _processAndLoadImages();
    }
  }

  Future<void> _processAndLoadImages() async {
    if (!mounted) return;
    setState(() {
      _areImagesReady = false; // Set to false while loading new set of images
    });

    final Map<String, ui.Image> newImageMap = {};
    final Set<String> imagePathsToLoad = {};

    // Collect all unique image paths from equipment items
    for (final item in widget.items) {
      if (item is EquipmentModel &&
          item.imagePath != null &&
          item.imagePath!.isNotEmpty) {
        imagePathsToLoad.add("assets/images/${item.imagePath!}");
      }
    }

    // Load all unique images
    for (final assetPath in imagePathsToLoad) {
      try {
        // Only load if not already in our new map for this batch
        if (!newImageMap.containsKey(assetPath)) {
          final ui.Image loadedImage = await loadUiImage(assetPath);
          newImageMap[assetPath] = loadedImage;
        }
      } catch (e) {
        // Optionally, handle the error, e.g., by using a default placeholder image
        // or just letting it be null so the painter draws a placeholder.
      }
    }

    if (mounted) {
      setState(() {
        _loadedImages = newImageMap;
        _areImagesReady = true; // Images are now ready (or loading failed)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate actual dimensions (same as your original MiniGameFieldWidget)
    return LayoutBuilder(
      builder: (context, constraints) {
        double actualWidth;
        double actualHeight;

        if (constraints.hasBoundedWidth && !constraints.maxWidth.isInfinite) {
          actualWidth = constraints.maxWidth;
          actualHeight = actualWidth / widget.aspectRatio;
          if (constraints.hasBoundedHeight &&
              actualHeight > constraints.maxHeight) {
            actualHeight = constraints.maxHeight;
            actualWidth = actualHeight * widget.aspectRatio;
          }
        } else if (constraints.hasBoundedHeight &&
            !constraints.maxHeight.isInfinite) {
          actualHeight = constraints.maxHeight;
          actualWidth = actualHeight * widget.aspectRatio;
        } else {
          actualWidth = 100.0;
          actualHeight = actualWidth / widget.aspectRatio;
        }

        // Optionally, show a loading indicator while images are being prepared
        if (!_areImagesReady &&
            widget.items.any(
              (item) =>
                  item is EquipmentModel &&
                  item.imagePath != null &&
                  item.imagePath!.isNotEmpty,
            )) {
          // return SizedBox(width: actualWidth, height: actualHeight, child: const Center(child: CircularProgressIndicator()));
        }

        return SizedBox(
          width: actualWidth,
          height: actualHeight,
          child: CustomPaint(
            painter: MiniGameFieldPainter(
              fieldColor: widget.fieldColor,
              borderColor: widget.borderColor,
              items: widget.items,
              logicalFieldSize: widget.logicalFieldSize,
              loadedImages: _loadedImages, // Pass the map of loaded images
              boardBackground: widget.boardBackground,
            ),
          ),
        );
      },
    );
  }
}
