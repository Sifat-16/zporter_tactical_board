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
      backgroundColor: ColorManager.black,
      insetPadding: EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: ColorManager.yellowLight.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                24, 56, 24, 24), // Add top padding for title & close button
            child: QuillEditor.basic(
              config: QuillEditorConfig(
                // ** THIS IS THE FIX **
                // Apply a dark theme style to the viewer
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    const TextStyle(
                      color: ColorManager.white, // Ensure default text is white
                      fontSize: 16,
                      height: 1.5,
                    ),
                    const HorizontalSpacing(16, 0),
                    const VerticalSpacing(16, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  h1: DefaultTextBlockStyle(
                    const TextStyle(
                      color: ColorManager.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    const HorizontalSpacing(16, 0),
                    const VerticalSpacing(16, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  link: const TextStyle(
                    color: ColorManager.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                  // You can add more styles for h2, h3, etc. if needed
                ),
                // ---
                showCursor: false,
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              ),
              controller: _quillController,
            ),
          ),
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
