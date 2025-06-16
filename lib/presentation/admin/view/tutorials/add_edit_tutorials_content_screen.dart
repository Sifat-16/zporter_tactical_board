// file: presentation/admin/view/tutorials/tutorial_editor_screen.dart

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
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_viewer_screen.dart';
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
    try {
      if (widget.tutorial.contentJson.isNotEmpty) {
        document = Document.fromJson(jsonDecode(widget.tutorial.contentJson));
      } else {
        document = Document();
      }
    } catch (e) {
      document = Document()..insert(0, 'Error loading content: $e');
    }
    _quillController = QuillController(
      document: document,
      keepStyleOnNewLine: true,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  void _onSave() {
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    final updatedTutorial = widget.tutorial.copyWith(contentJson: contentJson);
    ref.read(tutorialsProvider.notifier).updateTutorial(updatedTutorial);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutorial saved successfully!'),
          backgroundColor: ColorManager.green,
        ),
      );
    }
  }

  /// **NEW**: Shows a preview of the current editor content.
  void _showPreviewDialog() {
    // Get the current, unsaved content from the editor.
    final currentContentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    // Create a temporary tutorial object for the preview.
    final previewTutorial =
        widget.tutorial.copyWith(contentJson: currentContentJson);

    // Show the viewer dialog with the temporary tutorial data.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialViewerDialog(tutorial: previewTutorial),
    );
  }

  Future<String?> _onRequestPickVideo(BuildContext context) async {
    final picker = ImagePicker();

    final XFile? videoFile =
        await picker.pickVideo(source: ImageSource.gallery);
    if (videoFile == null) return null;
    try {
      return await ref
          .read(tutorialsProvider.notifier)
          .uploadVideoForTutorial(File(videoFile.path), widget.tutorial.id);
    } catch (e) {
      zlog(data: "Error while trying to upload $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
      return null;
    }
  }

  Future<String?> _onRequestPickImage(BuildContext context) async {
    final picker = ImagePicker();

    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return null;
    try {
      return await ref
          .read(tutorialsProvider.notifier)
          .uploadVideoForTutorial(File(imageFile.path), widget.tutorial.id);
    } catch (e) {
      zlog(data: "Error while trying to upload $e");
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
    final status = ref.watch(tutorialsProvider.select((state) => state.status));
    final isUploading = status == TutorialStatus.uploading;

    return AbsorbPointer(
      absorbing: isUploading,
      child: Scaffold(
        backgroundColor: ColorManager.black,
        appBar: AppBar(
          title: Text(widget.tutorial.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ColorManager.white)),
          backgroundColor: ColorManager.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorManager.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'Preview Tutorial',
              onPressed: _showPreviewDialog,
            ),
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save Content',
              onPressed: _onSave,
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                QuillSimpleToolbar(
                  config: QuillSimpleToolbarConfig(
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                      base: QuillToolbarToggleStyleButtonOptions(
                        iconTheme: QuillIconTheme(
                            iconButtonSelectedData:
                                IconButtonData(color: Colors.yellow),
                            iconButtonUnselectedData:
                                IconButtonData(color: Colors.white)),
                      ),
                      fontSize: QuillToolbarFontSizeButtonOptions(
                        style: TextStyle(color: Colors.white),
                      ),
                      fontFamily: QuillToolbarFontFamilyButtonOptions(
                        style: TextStyle(color: Colors.white),
                      ),
                      bold: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      italic: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      undoHistory: QuillToolbarHistoryButtonOptions(
                          iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      redoHistory: QuillToolbarHistoryButtonOptions(
                          iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      underLine: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      strikeThrough: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      inlineCode: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      listBullets: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      listNumbers: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      codeBlock: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      quote: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      direction: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      selectHeaderStyleButtons:
                          QuillToolbarSelectHeaderStyleButtonsOptions(
                              iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      selectHeaderStyleDropdownButton:
                          QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                              iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      superscript: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      subscript: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      small: QuillToolbarToggleStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      clearFormat: QuillToolbarClearFormatButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      selectLineHeightStyleDropdownButton:
                          QuillToolbarSelectLineHeightStyleDropdownButtonOptions(
                              iconTheme: QuillIconTheme(
                                  iconButtonSelectedData:
                                      IconButtonData(color: Colors.yellow),
                                  iconButtonUnselectedData:
                                      IconButtonData(color: Colors.white))),
                      color: QuillToolbarColorButtonOptions(
                          iconTheme: QuillIconTheme(
                        iconButtonSelectedData:
                            IconButtonData(color: Colors.yellow),
                        iconButtonUnselectedData:
                            IconButtonData(color: Colors.white),
                      )),
                      backgroundColor: QuillToolbarColorButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      linkStyle: QuillToolbarLinkStyleButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      linkStyle2: QuillToolbarLinkStyleButton2Options(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      search: QuillToolbarSearchButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      selectAlignmentButtons:
                          QuillToolbarSelectAlignmentButtonOptions(
                              iconTheme: QuillIconTheme(
                                  iconButtonSelectedData:
                                      IconButtonData(color: Colors.yellow),
                                  iconButtonUnselectedData:
                                      IconButtonData(color: Colors.white))),
                      indentIncrease: QuillToolbarIndentButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      indentDecrease: QuillToolbarIndentButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      customButtons: QuillToolbarCustomButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                      clipboardCut: QuillToolbarClipboardButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white))),
                    ),
                    embedButtons: FlutterQuillEmbeds.toolbarButtons(
                      imageButtonOptions: QuillToolbarImageButtonOptions(
                          iconTheme: QuillIconTheme(
                              iconButtonSelectedData:
                                  IconButtonData(color: Colors.yellow),
                              iconButtonUnselectedData:
                                  IconButtonData(color: Colors.white)),
                          imageButtonConfig: QuillToolbarImageConfig(
                              onRequestPickImage: _onRequestPickImage)),
                      videoButtonOptions: QuillToolbarVideoButtonOptions(
                        iconTheme: QuillIconTheme(
                            iconButtonSelectedData:
                                IconButtonData(color: Colors.yellow),
                            iconButtonUnselectedData:
                                IconButtonData(color: Colors.white)),
                        videoConfig: QuillToolbarVideoConfig(
                          onRequestPickVideo: _onRequestPickVideo,
                        ),
                      ),
                    ),
                  ),
                  controller: _quillController,
                ),
                const Divider(
                    height: 1, thickness: 1, color: ColorManager.dark2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QuillEditor.basic(
                      config: QuillEditorConfig(
                        customStyles: DefaultStyles(
                          // ** THIS IS THE CORRECTED PART **
                          // Using VerticalSpacing as required by the constructor.
                          paragraph: DefaultTextBlockStyle(
                              const TextStyle(
                                color: ColorManager.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              const HorizontalSpacing(16, 0),
                              const VerticalSpacing(16, 0), // Before the block
                              const VerticalSpacing(0, 0), // After the block
                              null),
                          h1: DefaultTextBlockStyle(
                              const TextStyle(
                                  color: ColorManager.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                              const HorizontalSpacing(16, 0),
                              const VerticalSpacing(16, 0),
                              const VerticalSpacing(0, 0),
                              null),
                          link: const TextStyle(
                            color: ColorManager.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      ),
                      controller: _quillController,
                    ),
                  ),
                ),
              ],
            ),
            if (isUploading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: ColorManager.yellow),
                      SizedBox(height: 20),
                      Text('Uploading File...',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
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
