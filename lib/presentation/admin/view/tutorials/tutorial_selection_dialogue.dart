// // file: presentation/user/widgets/tutorial_selection_dialog.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // Adjust imports
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
// import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_viewer_screen.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';
//
// class TutorialSelectionDialog extends ConsumerWidget {
//   const TutorialSelectionDialog({super.key});
//
//   // This function shows the viewer dialog
//   void _showTutorialViewerDialog(BuildContext context, Tutorial tutorial) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return TutorialViewerDialog(tutorial: tutorial);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(tutorialsProvider);
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return AlertDialog(
//       backgroundColor: ColorManager.dark2,
//       title: const Text('Select a Tutorial',
//           style: TextStyle(color: ColorManager.white)),
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//       content: SizedBox(
//         width: screenWidth * 0.9,
//         child: Builder(builder: (context) {
//           if (state.status == TutorialStatus.loading &&
//               state.tutorials.isEmpty) {
//             return const SizedBox(
//                 height: 100, child: Center(child: CircularProgressIndicator()));
//           }
//           if (state.status == TutorialStatus.error) {
//             return Center(child: Text('Error: ${state.errorMessage}'));
//           }
//           if (state.tutorials.isEmpty) {
//             return const Center(child: Text('No tutorials available.'));
//           }
//
//           return GridView.builder(
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 4 / 3,
//             ),
//             itemCount: state.tutorials.length,
//             itemBuilder: (context, index) {
//               final tutorial = state.tutorials[index];
//               final hasThumbnail = tutorial.thumbnailUrl != null &&
//                   tutorial.thumbnailUrl!.isNotEmpty;
//
//               return InkWell(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _showTutorialViewerDialog(context, tutorial);
//                 },
//                 child: Card(
//                   color: ColorManager.dark1,
//                   elevation: 4,
//                   clipBehavior: Clip.antiAlias,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   // --- THIS IS THE UPDATED LOGIC ---
//                   child: hasThumbnail
//                       // **Layout WITH Thumbnail**
//                       ? Stack(
//                           alignment: Alignment.bottomCenter,
//                           children: [
//                             Positioned.fill(
//                               child: Image.network(
//                                 tutorial.thumbnailUrl!,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Icon(Icons.broken_image,
//                                       color: ColorManager.grey);
//                                 },
//                               ),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter,
//                                 colors: [
//                                   Colors.black.withOpacity(0.8),
//                                   Colors.transparent,
//                                 ],
//                               )),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 tutorial.name,
//                                 textAlign: TextAlign.center,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     color: ColorManager.white,
//                                     fontWeight: FontWeight.bold,
//                                     shadows: [Shadow(blurRadius: 2.0)]),
//                               ),
//                             ),
//                           ],
//                         )
//                       // **Layout WITHOUT Thumbnail**
//                       : Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               tutorial.name,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: ColorManager.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child:
//               const Text('Close', style: TextStyle(color: ColorManager.white)),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_viewer_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateArrowVisibility);
    // A small delay to ensure clients are attached before checking arrows
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateArrowVisibility());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowVisibility() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    final shouldShowLeft = currentScroll > 5.0; // Add a small buffer
    final shouldShowRight = currentScroll < (maxScroll - 5.0);

    if (shouldShowLeft != _showLeftArrow ||
        shouldShowRight != _showRightArrow) {
      setState(() {
        _showLeftArrow = shouldShowLeft;
        _showRightArrow = shouldShowRight;
      });
    }
  }

  void _showTutorialViewerDialog(BuildContext context, Tutorial tutorial) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TutorialViewerDialog(tutorial: tutorial);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorialsProvider);
    final tutorials = state.tutorials;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define item width to show 3 items, with some spacing
    final double itemWidth = (screenWidth / 3) - 48;
    final double itemHeight =
        (itemWidth * (9 / 16)) + 60; // Image height + text area height

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: screenWidth,
        // height: screenHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main Content
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60.0), // Space for arrows
                      itemCount: tutorials.length,
                      itemBuilder: (context, index) {
                        final tutorial = tutorials[index];
                        return Container(
                          width: itemWidth,
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _TutorialCard(
                            tutorial: tutorial,
                            onTap: () {
                              Navigator.of(context).pop();
                              _showTutorialViewerDialog(context, tutorial);
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),

            // Navigation Arrows
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

/// A dedicated widget to display a single tutorial card, matching the new design.
/// A dedicated widget to display a single tutorial card, matching the new design.
class _TutorialCard extends StatelessWidget {
  final Tutorial tutorial;
  final VoidCallback onTap;

  const _TutorialCard({required this.tutorial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasThumbnail =
        tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: ColorManager.yellowLight.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          // Use ClipRRect for the rounded corners
          borderRadius: BorderRadius.circular(8.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            // MODIFIED: Replaced Column with Stack for layering
            child: Stack(
              alignment:
                  Alignment.bottomLeft, // Aligns children to the bottom-left
              children: [
                // Layer 1: Image or Placeholder (fills the entire space)
                Positioned.fill(
                  child: hasThumbnail
                      ? Image.network(
                          tutorial.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),

                // Layer 2: Gradient Overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8), // Darker at the bottom
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),

                // Layer 3: The Text, positioned over the gradient
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    tutorial.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // This helper method remains the same
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
