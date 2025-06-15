// file: presentation/user/widgets/tutorial_viewer_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

// Adjust these imports to match your project's file structure
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';

class TutorialViewerDialog extends StatefulWidget {
  final Tutorial tutorial;
  const TutorialViewerDialog({super.key, required this.tutorial});

  @override
  State<TutorialViewerDialog> createState() => _TutorialViewerDialogState();
}

class _TutorialViewerDialogState extends State<TutorialViewerDialog> {
  late final QuillController _quillController;

  @override
  void initState() {
    super.initState();
    Document document;
    try {
      if (widget.tutorial.contentJson.isNotEmpty) {
        document = Document.fromJson(jsonDecode(widget.tutorial.contentJson));
      } else {
        document = Document()..insert(0, 'This tutorial has no content.');
      }
    } catch (e) {
      document = Document()..insert(0, 'Error displaying content.');
    }

    _quillController = QuillController(
      document: document,
      readOnly: true,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.dark1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      // We use a Stack to overlay the close button on top of the content.
      child: Stack(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: QuillEditor.basic(
              config: QuillEditorConfig(
                showCursor: false,
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              ),
              controller: _quillController,
            ),
          ),
          // Close Button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon:
                  const Icon(Icons.close, color: ColorManager.white, size: 30),
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
