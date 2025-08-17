import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

// Adjust these imports to match your project's file structure
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/rich_text_tutorial_viewer_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

// The YoutubeVideoEmbedBuilder for the rich text body remains the same.
class YoutubeVideoEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'video';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final videoUrl = embedContext.node.value.data as String;
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) return const SizedBox.shrink();
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: YoutubePlayer(controller: controller),
    );
  }
}

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
  late List<String> _mediaUrls;

  @override
  void initState() {
    super.initState();
    _mediaUrls = List<String>.from(widget.tutorial.mediaUrls ?? []);

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

  Future<void> _onSave() async {
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    final updatedTutorial = widget.tutorial.copyWith(
      contentJson: contentJson,
      mediaUrls: _mediaUrls,
    );

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

  void _showPreview() {
    final currentContentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    final previewTutorial = widget.tutorial
        .copyWith(contentJson: currentContentJson, mediaUrls: _mediaUrls);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RichTextTutorialViewerScreen(tutorial: previewTutorial),
    ));
  }

  Future<void> _onAddMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorManager.dark2,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: ColorManager.white),
                title: const Text('Add Image(s)',
                    style: TextStyle(color: ColorManager.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImages();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.video_library, color: ColorManager.white),
                title: const Text('Add Video File',
                    style: TextStyle(color: ColorManager.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadVideo();
                },
              ),
              ListTile(
                leading:
                    const FaIcon(FontAwesomeIcons.youtube, color: Colors.red),
                title: const Text('Add YouTube URL',
                    style: TextStyle(color: ColorManager.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _addYoutubeUrl();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles =
        await picker.pickMultiImage(imageQuality: 70);

    if (pickedFiles.isNotEmpty && mounted) {
      final newUrls = await ref
          .read(tutorialsProvider.notifier)
          .uploadMultipleMediaForTutorial(
            pickedFiles.map((f) => File(f.path)).toList(),
            widget.tutorial.id,
          );
      setState(() {
        _mediaUrls.addAll(newUrls);
      });
    }
  }

  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      final newUrl = await ref
          .read(tutorialsProvider.notifier)
          .uploadVideoForTutorial(File(pickedFile.path), widget.tutorial.id);
      if (newUrl.isNotEmpty) {
        setState(() {
          _mediaUrls.add(newUrl);
        });
      }
    }
  }

  void _addYoutubeUrl() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: const Text(
            'Add YouTube URL',
            style: TextStyle(color: ColorManager.white),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: const TextStyle(color: ColorManager.white),
            decoration: const InputDecoration(
              labelText: 'Paste YouTube URL here',
              labelStyle: TextStyle(color: ColorManager.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.yellow),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: ColorManager.white)),
            ),
            TextButton(
              onPressed: () {
                final url = textController.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    _mediaUrls.add(url);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add',
                  style: TextStyle(color: ColorManager.yellow)),
            ),
          ],
        );
      },
    );
  }

  void _onDeleteMedia(String urlToDelete) {
    if (!urlToDelete.contains('youtube.com') &&
        !urlToDelete.contains('youtu.be')) {
      ref
          .read(tutorialsProvider.notifier)
          .deleteMediaFromTutorial(widget.tutorial.id, urlToDelete);
    }
    setState(() {
      _mediaUrls.remove(urlToDelete);
    });
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
          title: Text('Edit: ${widget.tutorial.name}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ColorManager.white)),
          backgroundColor: ColorManager.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorManager.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'Preview Tutorial',
              onPressed: _showPreview,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 350,
                  child: _buildMediaGallery(),
                ),
                const VerticalDivider(
                    width: 1, thickness: 1, color: ColorManager.dark2),
                Expanded(
                  child: Column(
                    children: [
                      _buildQuillToolbar(),
                      const Divider(
                          height: 1, thickness: 1, color: ColorManager.dark2),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: QuillEditor.basic(
                            controller: _quillController,
                            config: QuillEditorConfig(
                              customStyles: DefaultStyles(
                                paragraph: DefaultTextBlockStyle(
                                  const TextStyle(
                                    color: ColorManager.white,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  const HorizontalSpacing(0, 0),
                                  const VerticalSpacing(0, 0),
                                  const VerticalSpacing(0, 0),
                                  null,
                                ),
                              ),
                              embedBuilders: [
                                ...FlutterQuillEmbeds.editorBuilders(),
                                YoutubeVideoEmbedBuilder(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildMediaGallery() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: ColorManager.dark1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Media Gallery',
                style: TextStyle(
                    color: ColorManager.white, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                label: const Text('Add Media'),
                onPressed: _onAddMedia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blue,
                  foregroundColor: ColorManager.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Drag and drop to reorder media.',
            style: TextStyle(color: ColorManager.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _mediaUrls.isEmpty
                ? Center(
                    child: Text('No media added. Click "Add Media" to start.',
                        style: TextStyle(color: ColorManager.grey)))
                : ReorderableListView.builder(
                    itemCount: _mediaUrls.length,
                    itemBuilder: (context, index) {
                      final url = _mediaUrls[index];
                      // ** THIS IS THE NEW, ROBUST THUMBNAIL WIDGET **
                      return Card(
                        key: ValueKey(url),
                        color: ColorManager.dark2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: _SmartMediaThumbnail(
                            url: url,
                            tutorialThumbnail: widget.tutorial.thumbnailUrl,
                          ),
                          title: Text(
                            _isYoutubeUrl(url)
                                ? 'YouTube Video'
                                : 'Media Item ${index + 1}',
                            style: const TextStyle(
                                color: ColorManager.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: ColorManager.red),
                            onPressed: () => _onDeleteMedia(url),
                          ),
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _mediaUrls.removeAt(oldIndex);
                        _mediaUrls.insert(newIndex, item);
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isYoutubeUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    if (lowercasedUrl.contains('youtube.com') ||
        lowercasedUrl.contains('youtu.be')) return true;
    return false;
  }

  Widget _buildQuillToolbar() {
    final iconTheme = QuillIconTheme(
      iconButtonSelectedData: IconButtonData(color: Colors.yellow),
      iconButtonUnselectedData: IconButtonData(color: Colors.white),
    );

    return QuillSimpleToolbar(
      controller: _quillController,
      config: QuillSimpleToolbarConfig(
        buttonOptions: QuillSimpleToolbarButtonOptions(
          base: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          bold: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          italic: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          underLine: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          strikeThrough:
              QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          inlineCode:
              QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          listBullets:
              QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          listNumbers:
              QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          codeBlock: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          quote: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          direction: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          superscript:
              QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          subscript: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          small: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          fontSize: QuillToolbarFontSizeButtonOptions(
              style: TextStyle(color: Colors.white)),
          fontFamily: QuillToolbarFontFamilyButtonOptions(
              style: TextStyle(color: Colors.white)),
          undoHistory: QuillToolbarHistoryButtonOptions(iconTheme: iconTheme),
          redoHistory: QuillToolbarHistoryButtonOptions(iconTheme: iconTheme),
          clearFormat:
              QuillToolbarClearFormatButtonOptions(iconTheme: iconTheme),
          color: QuillToolbarColorButtonOptions(iconTheme: iconTheme),
          backgroundColor: QuillToolbarColorButtonOptions(iconTheme: iconTheme),
          linkStyle: QuillToolbarLinkStyleButtonOptions(iconTheme: iconTheme),
          linkStyle2: QuillToolbarLinkStyleButton2Options(iconTheme: iconTheme),
          search: QuillToolbarSearchButtonOptions(iconTheme: iconTheme),
          selectAlignmentButtons:
              QuillToolbarSelectAlignmentButtonOptions(iconTheme: iconTheme),
          indentIncrease: QuillToolbarIndentButtonOptions(iconTheme: iconTheme),
          indentDecrease: QuillToolbarIndentButtonOptions(iconTheme: iconTheme),
          clipboardCut:
              QuillToolbarClipboardButtonOptions(iconTheme: iconTheme),
          selectHeaderStyleButtons:
              QuillToolbarSelectHeaderStyleButtonsOptions(iconTheme: iconTheme),
          selectHeaderStyleDropdownButton:
              QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                  iconTheme: iconTheme),
          selectLineHeightStyleDropdownButton:
              QuillToolbarSelectLineHeightStyleDropdownButtonOptions(
                  iconTheme: iconTheme),
        ),
      ),
    );
  }
}

// =========================================================================
// == NEW WIDGET: A "SMART" THUMBNAIL THAT HANDLES IMAGES AND VIDEOS ==
// =========================================================================
class _SmartMediaThumbnail extends StatelessWidget {
  final String url;
  final String? tutorialThumbnail;
  const _SmartMediaThumbnail({required this.url, this.tutorialThumbnail});

  bool get isYoutube {
    final lowercasedUrl = url.toLowerCase();
    return lowercasedUrl.contains('youtube.com') ||
        lowercasedUrl.contains('youtu.be');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // The main thumbnail image
            CachedNetworkImage(
              imageUrl: isYoutube
                  ? YoutubePlayer.getThumbnail(
                      videoId: YoutubePlayer.convertUrlToId(url) ?? '')
                  : url,
              fit: BoxFit.cover,
              // THIS IS THE FIX: The errorWidget is our fallback to detect videos
              errorWidget: (context, url, error) {
                // If it fails, we assume it's a video file and show a placeholder
                return Container(
                  color: ColorManager.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (tutorialThumbnail != null)
                        CachedNetworkImage(
                            imageUrl: tutorialThumbnail!, fit: BoxFit.cover),
                      const Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 24),
                    ],
                  ),
                );
              },
            ),
            // Overlay an icon if it's a YouTube video
            if (isYoutube)
              const Icon(FontAwesomeIcons.youtube, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }
}
