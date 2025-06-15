// file: presentation/user/widgets/tutorial_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Adjust imports
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_viewer_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

class TutorialSelectionDialog extends ConsumerWidget {
  const TutorialSelectionDialog({super.key});

  // This new function shows the viewer dialog
  void _showTutorialViewerDialog(BuildContext context, Tutorial tutorial) {
    showDialog(
      context: context,
      // As requested, tapping the background barrier will not dismiss the dialog
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TutorialViewerDialog(tutorial: tutorial);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorialsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: ColorManager.dark2,
      title: const Text('Select a Tutorial',
          style: TextStyle(color: ColorManager.white)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      content: SizedBox(
        width: screenWidth * 0.9,
        child: Builder(builder: (context) {
          if (state.status == TutorialStatus.loading &&
              state.tutorials.isEmpty) {
            return const SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator()));
          }
          if (state.status == TutorialStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.tutorials.isEmpty) {
            return const Center(child: Text('No tutorials available.'));
          }

          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            itemCount: state.tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = state.tutorials[index];
              return InkWell(
                // --- THIS IS THE UPDATED PART ---
                onTap: () {
                  // First, close the current selection dialog
                  Navigator.of(context).pop();
                  // Then, show the new viewer dialog
                  _showTutorialViewerDialog(context, tutorial);
                },
                child: Card(
                  color: ColorManager.dark1,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        tutorial.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ColorManager.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Text('Close', style: TextStyle(color: ColorManager.white)),
        ),
      ],
    );
  }
}
