// file: presentation/admin/view/tutorials/admin_tutorials_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Adjust these imports to your project structure
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';

import 'add_edit_tutorials_content_screen.dart';

class AdminTutorialsScreen extends ConsumerWidget {
  const AdminTutorialsScreen({super.key});

  void _showAddOrEditDialog(BuildContext context, WidgetRef ref,
      [Tutorial? tutorial]) {
    final isEditing = tutorial != null;
    final controller =
        TextEditingController(text: isEditing ? tutorial.name : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark2,
        title: Text(
          isEditing ? 'Rename Tutorial' : 'New Tutorial',
          style: const TextStyle(color: ColorManager.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: ColorManager.white),
          decoration: const InputDecoration(
            hintText: 'Enter tutorial name',
            hintStyle: TextStyle(color: ColorManager.grey),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (isEditing) {
                  ref
                      .read(tutorialsProvider.notifier)
                      .updateTutorial(tutorial.copyWith(name: name));
                } else {
                  ref.read(tutorialsProvider.notifier).addTutorial(name);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Tutorial tutorial) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: ColorManager.dark2,
              title: const Text('Confirm Delete',
                  style: TextStyle(color: ColorManager.white)),
              content: Text(
                  'Are you sure you want to delete "${tutorial.name}"?',
                  style: const TextStyle(color: ColorManager.grey)),
              actions: [
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop()),
                TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: ColorManager.red),
                  child: const Text('Delete',
                      style: TextStyle(color: ColorManager.white)),
                  onPressed: () {
                    ref
                        .read(tutorialsProvider.notifier)
                        .deleteTutorial(tutorial.id);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorialsProvider);

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text(
          'Manage Tutorials',
          style: TextStyle(color: ColorManager.white),
        ),
        backgroundColor: ColorManager.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorManager.white),
      ),
      body: ListView.builder(
        itemCount: state.tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = state.tutorials[index];
          return Card(
            color: ColorManager.dark1,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(tutorial.name,
                  style: const TextStyle(color: ColorManager.white)),
              onTap: () {
                // Tap to open the content editor
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TutorialEditorScreen(tutorial: tutorial),
                ));
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: ColorManager.blueAccent),
                    tooltip: 'Rename',
                    onPressed: () =>
                        _showAddOrEditDialog(context, ref, tutorial),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: ColorManager.red),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteDialog(context, ref, tutorial),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditDialog(context, ref),
        backgroundColor: ColorManager.green,
        icon: const Icon(Icons.add),
        label: const Text('New Tutorial'),
      ),
    );
  }
}
