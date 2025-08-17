// import 'dart:convert';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// // Adjust these imports to match your project's file structure
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
// import 'package:zporter_tactical_board/presentation/admin/view/tutorials/video_viewer_dialog.dart';
//
// // The YoutubeVideoEmbedBuilder for the rich text body remains the same.
// class YoutubeVideoEmbedBuilder extends EmbedBuilder {
//   @override
//   String get key => 'video';
//
//   @override
//   Widget build(
//     BuildContext context,
//     EmbedContext embedContext,
//   ) {
//     final videoUrl = embedContext.node.value.data as String;
//     final videoId = YoutubePlayer.convertUrlToId(videoUrl);
//     if (videoId == null) return const SizedBox.shrink();
//     final controller = YoutubePlayerController(
//       initialVideoId: videoId,
//       flags: const YoutubePlayerFlags(autoPlay: false),
//     );
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: YoutubePlayer(controller: controller),
//     );
//   }
// }
//
// class RichTextTutorialViewerScreen extends StatefulWidget {
//   final Tutorial tutorial;
//
//   const RichTextTutorialViewerScreen({super.key, required this.tutorial});
//
//   @override
//   State<RichTextTutorialViewerScreen> createState() =>
//       _RichTextTutorialViewerScreenState();
// }
//
// class _RichTextTutorialViewerScreenState
//     extends State<RichTextTutorialViewerScreen> {
//   late final QuillController _quillController;
//   late final PageController _pageController;
//   late final List<String> _mediaUrls;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//
//     _mediaUrls = List<String>.from(widget.tutorial.mediaUrls ?? []);
//     if (widget.tutorial.thumbnailUrl != null &&
//         widget.tutorial.thumbnailUrl!.isNotEmpty) {
//       _mediaUrls.remove(widget.tutorial.thumbnailUrl!);
//       _mediaUrls.add(widget.tutorial.thumbnailUrl!);
//     }
//
//     Document document;
//     try {
//       if (widget.tutorial.contentJson.isNotEmpty) {
//         document = Document.fromJson(jsonDecode(widget.tutorial.contentJson));
//       } else {
//         document = Document()..insert(0, 'This tutorial has no content.');
//       }
//     } catch (e) {
//       document = Document()..insert(0, 'Error displaying content.');
//     }
//
//     _quillController = QuillController(
//       document: document,
//       readOnly: true,
//       selection: const TextSelection.collapsed(offset: 0),
//     );
//   }
//
//   @override
//   void dispose() {
//     _quillController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final hasMedia = _mediaUrls.isNotEmpty;
//     final mediaHeight = MediaQuery.of(context).size.width * (9 / 16);
//
//     return Scaffold(
//       backgroundColor: ColorManager.black,
//       body: Stack(
//         children: [
//           CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     SizedBox(
//                       height: mediaHeight,
//                       width: double.infinity,
//                       child: hasMedia
//                           ? PageView.builder(
//                               controller: _pageController,
//                               itemCount: _mediaUrls.length,
//                               itemBuilder: (context, index) {
//                                 return _SmartMediaItem(
//                                   url: _mediaUrls[index],
//                                   tutorialThumbnailUrl:
//                                       widget.tutorial.thumbnailUrl,
//                                 );
//                               },
//                             )
//                           : Container(
//                               color: ColorManager.dark2,
//                               child: const Center(
//                                 child: Icon(Icons.image_not_supported,
//                                     color: ColorManager.grey, size: 50),
//                               ),
//                             ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.transparent,
//                               Colors.black.withOpacity(0.8)
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                         child: Text(
//                           widget.tutorial.name,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     if (hasMedia && _mediaUrls.length > 1)
//                       Positioned(
//                         bottom: 8,
//                         child: SmoothPageIndicator(
//                           controller: _pageController,
//                           count: _mediaUrls.length,
//                           effect: const WormEffect(
//                             dotHeight: 8,
//                             dotWidth: 8,
//                             activeDotColor: Colors.white,
//                             dotColor: Colors.white54,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: QuillEditor.basic(
//                     controller: _quillController,
//                     config: QuillEditorConfig(
//                       customStyles: DefaultStyles(
//                         paragraph: DefaultTextBlockStyle(
//                           const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 16,
//                             height: 1.5,
//                           ),
//                           const HorizontalSpacing(0, 0),
//                           const VerticalSpacing(16, 8),
//                           const VerticalSpacing(0, 0),
//                           null,
//                         ),
//                         h1: DefaultTextBlockStyle(
//                           const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           const HorizontalSpacing(0, 0),
//                           const VerticalSpacing(24, 12),
//                           const VerticalSpacing(0, 0),
//                           null,
//                         ),
//                         lists: DefaultListBlockStyle(
//                           const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 16,
//                             height: 1.5,
//                           ),
//                           const HorizontalSpacing(0, 0),
//                           const VerticalSpacing(8, 0),
//                           const VerticalSpacing(0, 0),
//                           null,
//                           null,
//                         ),
//                         link: const TextStyle(
//                           color: ColorManager.blueAccent,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                       embedBuilders: [
//                         ...FlutterQuillEmbeds.editorBuilders(),
//                         YoutubeVideoEmbedBuilder(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 40,
//             left: 16,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.4),
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // =========================================================================
// // == NEW "SMART" WIDGET THAT RELIABLY DETECTS MEDIA TYPE ==
// // =========================================================================
// // =========================================================================
// // == NEW "SMART" WIDGET THAT USES THE MAIN THUMBNAIL FOR VIDEOS ==
// // =========================================================================
// enum _MediaType { unknown, image, video }
//
// class _SmartMediaItem extends StatefulWidget {
//   final String url;
//   final String? tutorialThumbnailUrl; // The new parameter
//   const _SmartMediaItem({required this.url, this.tutorialThumbnailUrl});
//
//   @override
//   State<_SmartMediaItem> createState() => _SmartMediaItemState();
// }
//
// class _SmartMediaItemState extends State<_SmartMediaItem> {
//   _MediaType _mediaType = _MediaType.unknown;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.url.contains('youtube.com') || widget.url.contains('youtu.be')) {
//       _mediaType = _MediaType.video;
//     }
//   }
//
//   void _onTap() {
//     if (_mediaType == _MediaType.video) {
//       showDialog(
//         context: context,
//         builder: (_) => VideoViewerDialog(videoUrl: widget.url),
//       );
//     } else if (_mediaType == _MediaType.image) {
//       showDialog(
//         context: context,
//         builder: (_) => _FullScreenImageViewer(imageUrl: widget.url),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_mediaType == _MediaType.video) {
//       return _buildVideoThumbnail();
//     }
//
//     return CachedNetworkImage(
//       imageUrl: widget.url,
//       fit: BoxFit.cover,
//       imageBuilder: (context, imageProvider) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() {
//               _mediaType = _MediaType.image;
//             });
//           }
//         });
//         return GestureDetector(
//           onTap: _onTap,
//           child: Image(image: imageProvider, fit: BoxFit.cover),
//         );
//       },
//       placeholder: (context, url) => const Center(
//           child: CircularProgressIndicator(color: ColorManager.yellow)),
//       errorWidget: (context, url, error) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() {
//               _mediaType = _MediaType.video;
//             });
//           }
//         });
//         return _buildVideoThumbnail();
//       },
//     );
//   }
//
//   Widget _buildVideoThumbnail() {
//     final isYoutube =
//         widget.url.contains('youtube.com') || widget.url.contains('youtu.be');
//
//     // THIS IS THE CORE LOGIC CHANGE
//     Widget thumbnailBackground;
//     if (isYoutube) {
//       thumbnailBackground = CachedNetworkImage(
//         imageUrl: YoutubePlayer.getThumbnail(
//             videoId: YoutubePlayer.convertUrlToId(widget.url) ?? ''),
//         fit: BoxFit.cover,
//         errorWidget: (c, u, e) => Container(color: Colors.black),
//       );
//     } else {
//       // For non-YouTube videos, use the main tutorial thumbnail if it exists.
//       thumbnailBackground = widget.tutorialThumbnailUrl != null
//           ? CachedNetworkImage(
//               imageUrl: widget.tutorialThumbnailUrl!, fit: BoxFit.cover)
//           : Container(color: Colors.black);
//     }
//
//     return GestureDetector(
//       onTap: _onTap,
//       child: Stack(
//         alignment: Alignment.center,
//         fit: StackFit.expand,
//         children: [
//           thumbnailBackground,
//           Center(
//             child: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.4),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isYoutube ? FontAwesomeIcons.youtube : Icons.play_arrow_rounded,
//                 color: isYoutube ? Colors.red : Colors.white,
//                 size: isYoutube ? 40 : 60,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _FullScreenImageViewer extends StatelessWidget {
//   final String imageUrl;
//   const _FullScreenImageViewer({required this.imageUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.black,
//       insetPadding: EdgeInsets.zero,
//       child: Stack(
//         children: [
//           PhotoView(
//             imageProvider: CachedNetworkImageProvider(imageUrl),
//             minScale: PhotoViewComputedScale.contained,
//             maxScale: PhotoViewComputedScale.covered * 2,
//             heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
//           ),
//           Positioned(
//             top: 40,
//             right: 20,
//             child: IconButton(
//               icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Adjust these imports to match your project's file structure
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/video_viewer_dialog.dart';

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

class RichTextTutorialViewerScreen extends StatefulWidget {
  final Tutorial tutorial;

  const RichTextTutorialViewerScreen({super.key, required this.tutorial});

  @override
  State<RichTextTutorialViewerScreen> createState() =>
      _RichTextTutorialViewerScreenState();
}

class _RichTextTutorialViewerScreenState
    extends State<RichTextTutorialViewerScreen> {
  late final QuillController _quillController;
  late final PageController _pageController;
  late final List<String> _mediaUrls;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _mediaUrls = List<String>.from(widget.tutorial.mediaUrls ?? []);
    if (widget.tutorial.thumbnailUrl != null &&
        widget.tutorial.thumbnailUrl!.isNotEmpty) {
      _mediaUrls.remove(widget.tutorial.thumbnailUrl!);
      _mediaUrls.add(widget.tutorial.thumbnailUrl!);
    }

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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = _mediaUrls.isNotEmpty;
    // ** FIX 1: UPDATED MEDIA HEIGHT CALCULATION **
    // This now matches the immersive style of your notification screen.
    final mediaHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      backgroundColor: ColorManager.black,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  // --- MEDIA SECTION ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: mediaHeight,
                        width: double.infinity,
                        child: hasMedia
                            ? PageView.builder(
                                controller: _pageController,
                                itemCount: _mediaUrls.length,
                                itemBuilder: (context, index) {
                                  return _SmartMediaItem(
                                    url: _mediaUrls[index],
                                    tutorialThumbnailUrl:
                                        widget.tutorial.thumbnailUrl,
                                  );
                                },
                              )
                            : Container(
                                color: ColorManager.dark2,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: ColorManager.grey, size: 50),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Text(
                            widget.tutorial.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (hasMedia && _mediaUrls.length > 1)
                        Positioned(
                          bottom: 8,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: _mediaUrls.length,
                            effect: const WormEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.white,
                              dotColor: Colors.white54,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // --- CONTENT SECTION ---
                  // ** FIX 2: UPDATED CONTENT LAYOUT **
                  // This now wraps the editor in the same structure as your notification screen.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: const BoxDecoration(
                          color: ColorManager.black,
                        ),
                        child: QuillEditor.basic(
                          controller: _quillController,
                          config: QuillEditorConfig(
                            customStyles: DefaultStyles(
                              paragraph: DefaultTextBlockStyle(
                                const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(16, 8),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                              h1: DefaultTextBlockStyle(
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(24, 12),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                              lists: DefaultListBlockStyle(
                                const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(8, 0),
                                const VerticalSpacing(0, 0),
                                null,
                                null,
                              ),
                              link: const TextStyle(
                                color: ColorManager.blueAccent,
                                decoration: TextDecoration.underline,
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
                  ),
                ]),
              ),
            ],
          ),
          // --- FLOATING BACK BUTTON ---
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// The _SmartMediaItem and _FullScreenImageViewer widgets below do not need any changes.
// They are included here to make the file complete.
enum _MediaType { unknown, image, video }

class _SmartMediaItem extends StatefulWidget {
  final String url;
  final String? tutorialThumbnailUrl;
  const _SmartMediaItem({required this.url, this.tutorialThumbnailUrl});

  @override
  State<_SmartMediaItem> createState() => _SmartMediaItemState();
}

class _SmartMediaItemState extends State<_SmartMediaItem> {
  _MediaType _mediaType = _MediaType.unknown;

  @override
  void initState() {
    super.initState();
    if (widget.url.contains('youtube.com') || widget.url.contains('youtu.be')) {
      _mediaType = _MediaType.video;
    }
  }

  void _onTap() {
    if (_mediaType == _MediaType.video) {
      showDialog(
        context: context,
        builder: (_) => VideoViewerDialog(videoUrl: widget.url),
      );
    } else if (_mediaType == _MediaType.image) {
      showDialog(
        context: context,
        builder: (_) => _FullScreenImageViewer(imageUrl: widget.url),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaType == _MediaType.video) {
      return _buildVideoThumbnail();
    }

    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _mediaType = _MediaType.image;
            });
          }
        });
        return GestureDetector(
          onTap: _onTap,
          child: Image(image: imageProvider, fit: BoxFit.cover),
        );
      },
      placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: ColorManager.yellow)),
      errorWidget: (context, url, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _mediaType = _MediaType.video;
            });
          }
        });
        return _buildVideoThumbnail();
      },
    );
  }

  Widget _buildVideoThumbnail() {
    final isYoutube =
        widget.url.contains('youtube.com') || widget.url.contains('youtu.be');

    Widget thumbnailBackground;
    if (isYoutube) {
      thumbnailBackground = CachedNetworkImage(
        imageUrl: YoutubePlayer.getThumbnail(
            videoId: YoutubePlayer.convertUrlToId(widget.url) ?? ''),
        fit: BoxFit.cover,
        errorWidget: (c, u, e) => Container(color: Colors.black),
      );
    } else {
      thumbnailBackground = widget.tutorialThumbnailUrl != null
          ? CachedNetworkImage(
              imageUrl: widget.tutorialThumbnailUrl!, fit: BoxFit.cover)
          : Container(color: Colors.black);
    }

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          thumbnailBackground,
          Center(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isYoutube ? FontAwesomeIcons.youtube : Icons.play_arrow_rounded,
                color: isYoutube ? Colors.red : Colors.white,
                size: isYoutube ? 40 : 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
