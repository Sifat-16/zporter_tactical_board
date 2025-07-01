import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Adjust these imports to match your project's file structure
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/add_edit_tutorials_content_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

class AdminTutorialsScreen extends ConsumerWidget {
  const AdminTutorialsScreen({super.key});

  /// Shows the combined dialog for adding/editing a tutorial.
  void _showAddEditTutorialDialog(BuildContext context, WidgetRef ref,
      [Tutorial? tutorial]) {
    showDialog(
      context: context,
      builder: (_) => _AddEditTutorialDialog(
        tutorial: tutorial,
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a tutorial.
  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Tutorial tutorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark2,
        title: const Text('Confirm Delete',
            style: TextStyle(color: ColorManager.white)),
        content: Text('Are you sure you want to delete "${tutorial.name}"?',
            style: const TextStyle(color: ColorManager.grey)),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: ColorManager.red),
            child: const Text('Delete',
                style: TextStyle(color: ColorManager.white)),
            onPressed: () {
              ref.read(tutorialsProvider.notifier).deleteTutorial(tutorial.id);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _buildCreateNewButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Add padding
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, color: ColorManager.white),
        label: const Text('New Tutorial'),
        onPressed: () => _showAddEditTutorialDialog(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.green,
          foregroundColor: ColorManager.white,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorialsProvider);
    final status = state.status;

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text('Manage Tutorials',
            style: TextStyle(color: ColorManager.white)),
        backgroundColor: ColorManager.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorManager.white),
      ),
      body: Column(
        children: [
          _buildCreateNewButton(context, ref),
          Expanded(
            child: Stack(
              children: [
                if (status == TutorialStatus.loading && state.tutorials.isEmpty)
                  const Center(
                      child:
                          CircularProgressIndicator(color: ColorManager.yellow))
                else if (status == TutorialStatus.error)
                  Center(
                      child: Text(
                          'Error: ${state.errorMessage ?? "An unknown error occurred."}'))
                else
                  ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.tutorials.length,
                    itemBuilder: (context, index) {
                      final tutorial = state.tutorials[index];
                      return Card(
                        key: ValueKey(tutorial.id),
                        color: ColorManager.dark1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          leading: SizedBox(
                            width: 80,
                            height: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: tutorial.thumbnailUrl != null
                                  ? Image.network(
                                      tutorial.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.image_not_supported,
                                          color: ColorManager.grey),
                                    )
                                  : const Icon(Icons.image_search,
                                      color: ColorManager.grey, size: 40),
                            ),
                          ),
                          title: Text(tutorial.name,
                              style: const TextStyle(
                                  color: ColorManager.white,
                                  fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  TutorialEditorScreen(tutorial: tutorial),
                            ));
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: ColorManager.blueAccent),
                                tooltip: 'Edit Details',
                                onPressed: () => _showAddEditTutorialDialog(
                                    context, ref, tutorial),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: ColorManager.red),
                                tooltip: 'Delete',
                                onPressed: () =>
                                    _showDeleteDialog(context, ref, tutorial),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      ref
                          .read(tutorialsProvider.notifier)
                          .reorderTutorials(oldIndex, newIndex);
                    },
                  ),
                if (status == TutorialStatus.uploading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: ColorManager.yellow),
                          SizedBox(height: 16),
                          Text('Processing...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _showAddEditTutorialDialog(context, ref),
      //   backgroundColor: ColorManager.green,
      //   icon: const Icon(Icons.add, color: ColorManager.white),
      //   label: const Text('New Tutorial',
      //       style: TextStyle(color: ColorManager.white)),
      // ),
    );
  }
}

/// A dedicated stateful widget for the Add/Edit Tutorial Dialog.
class _AddEditTutorialDialog extends ConsumerStatefulWidget {
  final Tutorial? tutorial;

  const _AddEditTutorialDialog({this.tutorial});

  @override
  ConsumerState<_AddEditTutorialDialog> createState() =>
      __AddEditTutorialDialogState();
}

class __AddEditTutorialDialogState
    extends ConsumerState<_AddEditTutorialDialog> {
  late final TextEditingController _nameController;
  File? _pickedThumbnailFile;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.tutorial != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tutorial?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onPickThumbnail() async {
    final picker = ImagePicker();
    final xFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (xFile != null) {
      setState(() {
        _pickedThumbnailFile = File(xFile.path);
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final tutorialsNotifier = ref.read(tutorialsProvider.notifier);

    // Close the dialog before starting async operations
    if (mounted) Navigator.of(context).pop();

    if (_isEditing) {
      // --- UPDATE FLOW ---
      final tutorialToUpdate = widget.tutorial!;
      // 1. Update the name if it has changed
      if (tutorialToUpdate.name != name) {
        await tutorialsNotifier
            .updateTutorial(tutorialToUpdate.copyWith(name: name));
      }
      // 2. Upload a new thumbnail if one was picked
      if (_pickedThumbnailFile != null) {
        await tutorialsNotifier.uploadThumbnailForTutorial(
            _pickedThumbnailFile!, tutorialToUpdate.id);
      }
    } else {
      // --- CREATE FLOW ---
      // 1. Create the tutorial document first to get an ID
      final newTutorial = await tutorialsNotifier.addAndReturnTutorial(name);
      if (newTutorial == null) return; // Handle error case

      // 2. If a thumbnail was picked, upload it using the new ID
      if (_pickedThumbnailFile != null) {
        await tutorialsNotifier.uploadThumbnailForTutorial(
            _pickedThumbnailFile!, newTutorial.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManager.dark2,
      title: Text(_isEditing ? 'Edit Tutorial' : 'New Tutorial',
          style: const TextStyle(color: ColorManager.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail Preview and Upload Button
            SizedBox(
              width: 120,
              height: 90,
              child: InkWell(
                onTap: _onPickThumbnail,
                child: _pickedThumbnailFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_pickedThumbnailFile!,
                            fit: BoxFit.cover),
                      )
                    : widget.tutorial?.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(widget.tutorial!.thumbnailUrl!,
                                fit: BoxFit.cover),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: ColorManager.dark1,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ColorManager.grey)),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: ColorManager.grey),
                                SizedBox(height: 4),
                                Text('Thumbnail',
                                    style: TextStyle(
                                        color: ColorManager.grey,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 24),
            // Name Text Field
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: ColorManager.white),
              decoration: const InputDecoration(
                labelText: 'Tutorial Name',
                labelStyle: TextStyle(color: ColorManager.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.green)),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a name'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: ColorManager.green),
          onPressed: _onSave,
          child:
              const Text('Save', style: TextStyle(color: ColorManager.white)),
        ),
      ],
    );
  }
}
