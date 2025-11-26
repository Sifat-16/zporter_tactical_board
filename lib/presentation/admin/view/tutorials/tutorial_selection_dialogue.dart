// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
// import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_viewer_screen.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';
// import 'package:zporter_tactical_board/presentation/admin/view/tutorials/video_viewer_dialog.dart';
//
// class TutorialSelectionDialog extends ConsumerStatefulWidget {
//   const TutorialSelectionDialog({super.key});
//
//   @override
//   ConsumerState<TutorialSelectionDialog> createState() =>
//       _TutorialSelectionDialogState();
// }
//
// class _TutorialSelectionDialogState
//     extends ConsumerState<TutorialSelectionDialog> {
//   late final ScrollController _scrollController;
//   bool _showLeftArrow = false;
//   bool _showRightArrow = true;
//
//   Set<int> selectedIndexes = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _scrollController.addListener(_updateArrowVisibility);
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => _updateArrowVisibility());
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_updateArrowVisibility);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void updateSelectedIndex(int index) {
//     setState(() {
//       selectedIndexes.add(index);
//     });
//   }
//
//   void _updateArrowVisibility() {
//     if (!mounted || !_scrollController.hasClients) return;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.offset;
//     final shouldShowLeft = currentScroll > 5.0;
//     final shouldShowRight = currentScroll < (maxScroll - 5.0);
//
//     if (shouldShowLeft != _showLeftArrow ||
//         shouldShowRight != _showRightArrow) {
//       setState(() {
//         _showLeftArrow = shouldShowLeft;
//         _showRightArrow = shouldShowRight;
//       });
//     }
//   }
//
//   void _showTutorial(BuildContext context, Tutorial tutorial) {
//     if (tutorial.tutorialType == TutorialType.video &&
//         tutorial.videoUrl != null) {
//       showDialog(
//         context: context,
//         builder: (context) => VideoViewerDialog(videoUrl: tutorial.videoUrl!),
//       );
//     } else {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return TutorialViewerDialog(tutorial: tutorial);
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(tutorialsProvider);
//     final tutorials = state.tutorials;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double itemWidth = (screenWidth / 3) - 48;
//     final double itemHeight = (itemWidth * (9 / 16)) + 60;
//
//     return Dialog(
//       backgroundColor: Colors.black.withOpacity(0.1),
//       insetPadding: EdgeInsets.zero,
//       child: SizedBox(
//         width: screenWidth,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Select Tutorial',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   height: itemHeight,
//                   child: Builder(builder: (context) {
//                     if (state.status == TutorialStatus.loading &&
//                         tutorials.isEmpty) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (state.status == TutorialStatus.error) {
//                       return Center(
//                           child: Text('Error: ${state.errorMessage}'));
//                     }
//                     if (tutorials.isEmpty) {
//                       return const Center(
//                           child: Text('No tutorials available.',
//                               style: TextStyle(color: Colors.grey)));
//                     }
//                     return ListView.builder(
//                       controller: _scrollController,
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 60.0),
//                       itemCount: tutorials.length,
//                       itemBuilder: (context, index) {
//                         final tutorial = tutorials[index];
//                         return Container(
//                           width: itemWidth,
//                           margin: const EdgeInsets.symmetric(horizontal: 12.0),
//                           child: TutorialCard(
//                             tutorial: tutorial,
//                             isSelected: selectedIndexes.contains(index),
//                             onTap: () {
//                               updateSelectedIndex(index);
//                               _showTutorial(context, tutorial);
//                             },
//                           ),
//                         );
//                       },
//                     );
//                   }),
//                 ),
//               ],
//             ),
//             if (_showLeftArrow)
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back_ios,
//                       color: Colors.white, size: 30),
//                   onPressed: () => _scrollController.animateTo(
//                     _scrollController.offset - (itemWidth * 1.5),
//                     duration: const Duration(milliseconds: 400),
//                     curve: Curves.easeInOut,
//                   ),
//                 ),
//               ),
//             if (_showRightArrow)
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_forward_ios,
//                       color: Colors.white, size: 30),
//                   onPressed: () => _scrollController.animateTo(
//                     _scrollController.offset + (itemWidth * 1.5),
//                     duration: const Duration(milliseconds: 400),
//                     curve: Curves.easeInOut,
//                   ),
//                 ),
//               ),
//             Positioned(
//               top: 20,
//               right: 20,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 35),
//                 tooltip: 'Close',
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class TutorialCard extends StatelessWidget {
//   final Tutorial tutorial;
//   final VoidCallback onTap;
//   final bool isSelected;
//   const TutorialCard(
//       {required this.tutorial, required this.onTap, required this.isSelected});
//
//   // --- NEW: Helper widget to get the correct play icon ---
//   Widget _getPlayIcon() {
//     if (tutorial.tutorialType != TutorialType.video) {
//       return const SizedBox.shrink(); // Return empty space if not a video
//     }
//
//     bool isYoutube = tutorial.videoUrl?.contains('youtube.com') ?? false;
//
//     final icon = isYoutube
//         ? const FaIcon(FontAwesomeIcons.youtube, color: Colors.white, size: 35)
//         : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50);
//
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: isYoutube ? Colors.red : Colors.black.withOpacity(0.4),
//         shape: BoxShape.circle,
//       ),
//       child: icon,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final hasThumbnail =
//         tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty;
//
//     return Container(
//       decoration: BoxDecoration(
//           border: Border.all(
//               color: isSelected
//                   ? Colors.orange.withValues(alpha: 0.5)
//                   : ColorManager.grey.withOpacity(0.5)),
//           borderRadius: BorderRadius.circular(8)),
//       child: InkWell(
//         onTap: onTap,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8.0),
//           child: AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Positioned.fill(
//                   child: hasThumbnail
//                       ? Image.network(
//                           tutorial.thumbnailUrl!,
//                           alignment: Alignment.center,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => _buildPlaceholder(),
//                         )
//                       : _buildPlaceholder(),
//                 ),
//                 // Gradient for text readability
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     height: context.heightPercent(80),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.black.withOpacity(0.8),
//                           Colors.transparent
//                         ],
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Tutorial Name
//                 Align(
//                   alignment: Alignment.bottomLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Text(
//                       tutorial.name,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         shadows: [
//                           Shadow(blurRadius: 2.0, color: Colors.black54)
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // --- UPDATED: Use the helper to show the correct icon ---
//                 _getPlayIcon(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholder() {
//     return Container(
//       color: ColorManager.dark1,
//       child: const Center(
//         child: Icon(
//           Icons.image_search,
//           color: ColorManager.grey,
//           size: 40,
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
// ** 1. IMPORT THE NEW SCREEN **
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/rich_text_tutorial_viewer_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/video_viewer_dialog.dart';

class TutorialSelectionDialog extends ConsumerStatefulWidget {
  const TutorialSelectionDialog({super.key});

  @override
  ConsumerState<TutorialSelectionDialog> createState() =>
      _TutorialSelectionDialogState();
}

class _TutorialSelectionDialogState
    extends ConsumerState<TutorialSelectionDialog> {
  late final ScrollController _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateArrowVisibility);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateArrowVisibility());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void updateSelectedIndex(int index) {
    setState(() {
      selectedIndexes.add(index);
    });
  }

  void _updateArrowVisibility() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final shouldShowLeft = currentScroll > 5.0;
    final shouldShowRight = currentScroll < (maxScroll - 5.0);

    if (shouldShowLeft != _showLeftArrow ||
        shouldShowRight != _showRightArrow) {
      setState(() {
        _showLeftArrow = shouldShowLeft;
        _showRightArrow = shouldShowRight;
      });
    }
  }

  // ** 2. UPDATE THE NAVIGATION LOGIC **
  // This function now correctly navigates to the new screen for rich text tutorials.
  void _showTutorial(BuildContext context, Tutorial tutorial) {
    if (tutorial.tutorialType == TutorialType.video &&
        tutorial.videoUrl != null) {
      // Video tutorials still use the old dialog.
      showDialog(
        context: context,
        builder: (context) => VideoViewerDialog(videoUrl: tutorial.videoUrl!),
      );
    } else if (tutorial.tutorialType == TutorialType.richText) {
      // Rich text tutorials now push a full-screen page.
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RichTextTutorialViewerScreen(tutorial: tutorial),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorialsProvider);
    final tutorials = state.tutorials;
    final screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth / 3) - 48;
    final double itemHeight = (itemWidth * (9 / 16)) + 60;

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.1),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: screenWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Tutorial',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: itemHeight,
                  child: Builder(builder: (context) {
                    if (state.status == TutorialStatus.loading &&
                        tutorials.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == TutorialStatus.error) {
                      return Center(
                          child: Text('Error: ${state.errorMessage}'));
                    }
                    if (tutorials.isEmpty) {
                      return const Center(
                          child: Text('No tutorials available.',
                              style: TextStyle(color: Colors.grey)));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 60.0),
                      itemCount: tutorials.length,
                      itemBuilder: (context, index) {
                        final tutorial = tutorials[index];
                        return Container(
                          width: itemWidth,
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TutorialCard(
                            tutorial: tutorial,
                            isSelected: selectedIndexes.contains(index),
                            onTap: () {
                              updateSelectedIndex(index);
                              _showTutorial(context, tutorial);
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
            if (_showLeftArrow)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 30),
                  onPressed: () => _scrollController.animateTo(
                    _scrollController.offset - (itemWidth * 1.5),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            if (_showRightArrow)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 30),
                  onPressed: () => _scrollController.animateTo(
                    _scrollController.offset + (itemWidth * 1.5),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 35),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialCard extends StatelessWidget {
  final Tutorial tutorial;
  final VoidCallback onTap;
  final bool isSelected;
  const TutorialCard(
      {super.key,
      required this.tutorial,
      required this.onTap,
      required this.isSelected});

  Widget _getPlayIcon() {
    if (tutorial.tutorialType != TutorialType.video) {
      return const SizedBox.shrink();
    }

    bool isYoutube = tutorial.videoUrl?.contains('youtube.com') ?? false;

    final icon = isYoutube
        ? const FaIcon(FontAwesomeIcons.youtube, color: Colors.white, size: 35)
        : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isYoutube ? Colors.red : Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasThumbnail =
        tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: isSelected
                  ? Colors.orange.withOpacity(0.5)
                  : ColorManager.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: hasThumbnail
                      ? CachedNetworkImage(
                          imageUrl: tutorial.thumbnailUrl!,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: context.heightPercent(80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      tutorial.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 2.0, color: Colors.black54)
                        ],
                      ),
                    ),
                  ),
                ),
                _getPlayIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: ColorManager.dark1,
      child: const Center(
        child: Icon(
          Icons.image_search,
          color: ColorManager.grey,
          size: 40,
        ),
      ),
    );
  }
}
