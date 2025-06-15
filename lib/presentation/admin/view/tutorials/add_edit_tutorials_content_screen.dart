import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

// Adjust these imports to match your project's file structure
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

class TutorialEditorScreen extends ConsumerStatefulWidget {
  final Tutorial tutorial;

  const TutorialEditorScreen({
    super.key,
    required this.tutorial,
  });

  @override
  ConsumerState<TutorialEditorScreen> createState() =>
      _TutorialEditorScreenState();
}

class _TutorialEditorScreenState extends ConsumerState<TutorialEditorScreen> {
  late final QuillController _quillController;

  @override
  void initState() {
    super.initState();
    Document document;

    // Safely decode the JSON content, providing a fallback for empty/invalid data.
    try {
      if (widget.tutorial.contentJson.isNotEmpty) {
        final decodedContent = jsonDecode(widget.tutorial.contentJson);
        document = Document.fromJson(decodedContent);
      } else {
        // If there's no content, start with a blank document.
        document = Document();
      }
    } catch (e) {
      // If JSON is malformed, show an error message in the editor.
      document = Document()..insert(0, 'Error loading content: $e');
    }

    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed.
    _quillController.dispose();
    super.dispose();
  }

  /// Saves the editor's current content to Firestore via the controller.
  void _onSave() {
    // Get the rich text content as a JSON string.
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    // Create an updated tutorial model with the new content.
    final updatedTutorial = widget.tutorial.copyWith(contentJson: contentJson);

    // Call the controller to save the data.
    ref.read(tutorialsProvider.notifier).updateTutorial(updatedTutorial);

    // Show a confirmation message to the user.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutorial saved successfully!'),
          backgroundColor: ColorManager.green,
        ),
      );
    }
  }

  /// This callback is triggered when the user selects a video from the toolbar.
  /// It handles the upload process.
  /// NEW (CORRECTED) CALLBACK FOR VIDEO PICKING AND UPLOADING
  /// This function now handles picking the file and uploading it.
  Future<String?> _onRequestPickVideo(BuildContext context) async {
    final picker = ImagePicker();
    // 1. Pick the video file
    final XFile? videoFile =
        await picker.pickVideo(source: ImageSource.gallery);

    if (videoFile == null) {
      // User cancelled the picker
      return null;
    }

    // 2. Call the controller to handle the upload and get the URL
    try {
      final url = await ref
          .read(tutorialsProvider.notifier)
          .uploadVideoForTutorial(File(videoFile.path), widget.tutorial.id);

      // 3. Return the public URL to the editor
      return url;
    } catch (e) {
      zlog(data: "Error while trying to upload ${e}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the status from the provider to react to state changes (e.g., uploading).
    final status = ref.watch(tutorialsProvider.select((state) => state.status));
    final isUploading = status == TutorialStatus.uploading;

    return AbsorbPointer(
      // Disable user interaction while a video is uploading.
      absorbing: isUploading,
      child: Scaffold(
        // backgroundColor: ColorManager.black,
        appBar: AppBar(
          title: Text(
            widget.tutorial.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ColorManager.black),
          ),
          backgroundColor: ColorManager.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorManager.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save Content',
              onPressed: _onSave,
            ),
          ],
        ),
        // Stack allows us to overlay the loading indicator on top of the editor.
        body: Stack(
          children: [
            Column(
              children: [
                // The editor's toolbar
                QuillSimpleToolbar(
                  config: QuillSimpleToolbarConfig(
                    embedButtons: FlutterQuillEmbeds.toolbarButtons(
                      videoButtonOptions: QuillToolbarVideoButtonOptions(
                        videoConfig: QuillToolbarVideoConfig(
                          onRequestPickVideo: _onRequestPickVideo,
                        ),
                      ),
                      // You can add options for image uploads here too if needed
                    ),
                  ),
                  controller: _quillController,
                ),
                const Divider(
                    height: 1, thickness: 1, color: ColorManager.dark2),
                // The editor itself
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QuillEditor.basic(
                      config: QuillEditorConfig(
                        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      ),
                      controller: _quillController,
                    ),
                  ),
                ),
              ],
            ),

            // Conditionally show the loading overlay
            if (isUploading)
              Container(
                // Semi-transparent background to dim the UI
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: ColorManager.yellow),
                      SizedBox(height: 20),
                      Text(
                        'Uploading Video...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
