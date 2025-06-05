// animation_sharer.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img; // Import with prefix
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zporter_tactical_board/app/core/picker/save_file_to_user_picked_directory.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

class AnimationSharer {
  static Future<String?> captureWidgetAsPng(
    GlobalKey boundaryKey, {
    String fileName = "tactic_scene",
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      zlog(data: "Error capturing widget: Boundary key has no context.");
      return null;
    }

    final widgetType = boundaryKey.currentWidget.runtimeType;
    zlog(
      data:
          "captureWidgetAsPng: Key is associated with widget type: $widgetType",
    );

    RenderObject? renderObject = context.findRenderObject();
    zlog(
      data:
          "captureWidgetAsPng: Found RenderObject of type: ${renderObject.runtimeType}",
    );

    if (renderObject is RenderRepaintBoundary) {
      ui.Image image = await renderObject.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();

      if (byteData == null) {
        zlog(data: "Error capturing widget: ByteData is null after toImage.");
        return null;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final file = File.fromRawPath(pngBytes);
        return file.path;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);
      zlog(data: "Image captured and saved to: ${file.path}");
      return file.path;
    } else {
      zlog(
        data:
            "Error capturing widget: Expected RenderRepaintBoundary, but found ${renderObject.runtimeType}. "
            "Ensure the GlobalKey is correctly attached to a RepaintBoundary widget that is part of the currently rendered tree.",
      );
      return null;
    }
    try {} catch (e, s) {
      zlog(data: "Error capturing widget as image: $e\nStackTrace: $s");
      return null;
    }
  }

  static Future<XFile?> captureWidgetAsPngWeb(
    GlobalKey boundaryKey, {
    String fileName = "tactic_scene",
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      zlog(data: "Error capturing widget: Boundary key has no context.");
      return null;
    }

    final widgetType = boundaryKey.currentWidget.runtimeType;
    zlog(
      data:
          "captureWidgetAsPng: Key is associated with widget type: $widgetType",
    );

    RenderObject? renderObject = context.findRenderObject();
    zlog(
      data:
          "captureWidgetAsPng: Found RenderObject of type: ${renderObject.runtimeType}",
    );

    if (renderObject is RenderRepaintBoundary) {
      ui.Image image = await renderObject.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();

      if (byteData == null) {
        zlog(data: "Error capturing widget: ByteData is null after toImage.");
        return null;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final file = XFile.fromData(pngBytes);
      return file;
    } else {
      zlog(
        data:
            "Error capturing widget: Expected RenderRepaintBoundary, but found ${renderObject.runtimeType}. "
            "Ensure the GlobalKey is correctly attached to a RepaintBoundary widget that is part of the currently rendered tree.",
      );
      return null;
    }
    try {} catch (e, s) {
      zlog(data: "Error capturing widget as image: $e\nStackTrace: $s");
      return null;
    }
  }

  static Future<Uint8List?> captureWidgetAsPngImage(
    GlobalKey boundaryKey, {
    String fileName = "tactic_scene",
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      zlog(data: "Error capturing widget: Boundary key has no context.");
      return null;
    }

    final widgetType = boundaryKey.currentWidget.runtimeType;
    zlog(
      data:
          "captureWidgetAsPng: Key is associated with widget type: $widgetType",
    );

    RenderObject? renderObject = context.findRenderObject();
    zlog(
      data:
          "captureWidgetAsPng: Found RenderObject of type: ${renderObject.runtimeType}",
    );

    if (renderObject is RenderRepaintBoundary) {
      ui.Image image = await renderObject.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();

      if (byteData == null) {
        zlog(data: "Error capturing widget: ByteData is null after toImage.");
        return null;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      return pngBytes;
    } else {
      zlog(
        data:
            "Error capturing widget: Expected RenderRepaintBoundary, but found ${renderObject.runtimeType}. "
            "Ensure the GlobalKey is correctly attached to a RepaintBoundary widget that is part of the currently rendered tree.",
      );
      return null;
    }
  }

  static Future<void> captureAndShare(GlobalKey boundaryKey,
      {String fileName = "tactic_scene", required BuildContext context}) async {
    if (kIsWeb) {
      final XFile? imageFile = await captureWidgetAsPngWeb(
        boundaryKey,
        fileName: fileName,
      );
      if (imageFile != null) {
        await SharePlus.instance.share(ShareParams(
          text: "Zporter Football Pad Image",
          subject: "Check out this from my Zporter Football Pad",
          files: [imageFile],
          sharePositionOrigin: Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height / 2),
        ));
      }
    } else {
      final String? imagePath = await captureWidgetAsPng(
        boundaryKey,
        fileName: fileName,
      );
      if (imagePath != null) {
        await shareImageFile(imagePath,
            text: "Zporter Football Pad Image",
            subject: "Check out this from my Zporter Football Pad",
            context: context);
      }
    }
  }

  static Future<void> shareImageFile(String filePath,
      {String? text, String? subject, required BuildContext context}) async {
    try {
      final xFile = XFile(filePath);
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: text,
          subject: subject,
          sharePositionOrigin: Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height / 2),
        ),
      );
      zlog(data: "File shared: $filePath");
    } catch (e) {
      zlog(data: "Error sharing file: $e");
    }
  }

  Future<String?> createAndShareAnimationAsGif(/* ... */) async {
    // ... (GIF placeholder remains the same) ...
    zlog(data: "GIF creation requested (not fully implemented).");
    return null;
  }

  static Future<Uint8List?> captureWidgetAsPngBytes(
    GlobalKey boundaryKey,
  ) async {
    try {
      final context = boundaryKey.currentContext;
      if (context == null) {
        zlog(
          data:
              "AnimationSharer: Error - Boundary key has no context during capture.",
        );
        return null;
      }
      RenderObject? renderObject = context.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        ui.Image image = await renderObject.toImage(
          pixelRatio: 1.5,
        ); // Adjusted pixel ratio for GIF
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image.dispose();
        return byteData?.buffer.asUint8List();
      } else {
        zlog(
          data:
              "AnimationSharer: Error - Expected RenderRepaintBoundary, but found ${renderObject.runtimeType}.",
        );
      }
    } catch (e, s) {
      zlog(
        data:
            "AnimationSharer: Error capturing widget as PNG bytes: $e\nStackTrace: $s",
      );
    }
    return null;
  }

  static Future<void> createGifAndShare(Uint8List pngFrameBytesList,
      {String fileName = "tactic_scene", required BuildContext context}) async {
    final String? imagePath = await createAnimationGifFromFrames(
      pngFrameBytesList,
      fileName: "tactic_scene_capture",
    );
    if (imagePath != null) {
      await shareImageFile(imagePath,
          text: "Check out this tactic from my board!",
          subject: "Tactic Scene",
          context: context);
    }
  }

  static Future<String?> createAnimationGifFromFrames(
    Uint8List pngFrameBytesList, {
    String fileName = "tactic_scene",
  }) async {
    if (pngFrameBytesList.isEmpty) {
      zlog(data: "AnimationSharer: No frames provided for GIF creation.");
      return null;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName.gif');
    await file.writeAsBytes(pngFrameBytesList);
    zlog(data: "Gif captured and saved to: ${file.path}");
    return file.path;
  }

  static Future<Uint8List> convertToGif(
    List<Uint8List> imageBytesList, {
    int delayMs = 100,
  }) async {
    final gifEncoder = img.GifEncoder(delay: delayMs ~/ 10);

    for (final bytes in imageBytesList) {
      final image = img.decodeImage(bytes);
      if (image != null) {
        gifEncoder.addFrame(image);
      }
    }

    final gif = gifEncoder.finish();
    return Uint8List.fromList(gif!);
  }
}

class AnimationDownloader {
  static Future<String?> captureWidgetAsPng(
    GlobalKey boundaryKey, {
    String fileName = "tactic_scene",
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      zlog(data: "Error capturing widget: Boundary key has no context.");
      return null;
    }

    final widgetType = boundaryKey.currentWidget.runtimeType;
    zlog(
      data:
          "captureWidgetAsPng: Key is associated with widget type: $widgetType",
    );

    RenderObject? renderObject = context.findRenderObject();
    zlog(
      data:
          "captureWidgetAsPng: Found RenderObject of type: ${renderObject.runtimeType}",
    );

    if (renderObject is RenderRepaintBoundary) {
      ui.Image image = await renderObject.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();

      if (byteData == null) {
        zlog(data: "Error capturing widget: ByteData is null after toImage.");
        return null;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final file = File.fromRawPath(pngBytes);
        return file.path;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);
      zlog(data: "Image captured and saved to: ${file.path}");
      return file.path;
    } else {
      zlog(
        data:
            "Error capturing widget: Expected RenderRepaintBoundary, but found ${renderObject.runtimeType}. "
            "Ensure the GlobalKey is correctly attached to a RepaintBoundary widget that is part of the currently rendered tree.",
      );
      return null;
    }
    try {} catch (e, s) {
      zlog(data: "Error capturing widget as image: $e\nStackTrace: $s");
      return null;
    }
  }

  static Future<void> captureAndDownload(
    GlobalKey boundaryKey, {
    String fileName = "tactic_scene",
  }) async {
    final String? imagePath = await captureWidgetAsPng(
      boundaryKey,
      fileName: fileName,
    );
    if (imagePath != null) {
      await saveAppFileToUserSelectedLocation(
        sourceFilePath: imagePath,
        suggestedFileName: '${fileName}.png',
      );
    }
  }

  static void downloadFile(String s, {required String text}) async {
    await saveAppFileToUserSelectedLocation(
      sourceFilePath: s,
      suggestedFileName: text,
    );
  }
}
