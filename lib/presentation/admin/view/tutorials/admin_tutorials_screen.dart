//
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
// import 'package:zporter_tactical_board/presentation/admin/view/tutorials/add_edit_tutorials_content_screen.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';
//
// class AdminTutorialsScreen extends ConsumerWidget {
//   const AdminTutorialsScreen({super.key});
//
//   void _showAddEditTutorialDialog(BuildContext context, WidgetRef ref,
//       [Tutorial? tutorial]) {
//     showDialog(
//       context: context,
//       builder: (_) => _AddEditTutorialDialog(tutorial: tutorial),
//     );
//   }
//
//   void _showDeleteDialog(
//       BuildContext context, WidgetRef ref, Tutorial tutorial) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: ColorManager.dark2,
//         title: const Text('Confirm Delete',
//             style: TextStyle(color: ColorManager.white)),
//         content: Text('Are you sure you want to delete "${tutorial.name}"?',
//             style: const TextStyle(color: ColorManager.grey)),
//         actions: [
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(backgroundColor: ColorManager.red),
//             child: const Text('Delete',
//                 style: TextStyle(color: ColorManager.white)),
//             onPressed: () {
//               ref.read(tutorialsProvider.notifier).deleteTutorial(tutorial.id);
//               Navigator.of(context).pop();
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   void _handleTutorialTap(BuildContext context, Tutorial tutorial) {
//     // Only navigate to the rich text editor if the type is richText.
//     if (tutorial.tutorialType == TutorialType.richText) {
//       Navigator.of(context).push(MaterialPageRoute(
//         builder: (_) => TutorialEditorScreen(tutorial: tutorial),
//       ));
//     }
//     // For video tutorials, editing happens in the dialog, so tapping does nothing here.
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(tutorialsProvider);
//     final status = state.status;
//
//     return Scaffold(
//       backgroundColor: ColorManager.black,
//       appBar: AppBar(
//         title: const Text('Manage Tutorials',
//             style: TextStyle(color: ColorManager.white)),
//         backgroundColor: ColorManager.black,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: ColorManager.white),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
//             child: ElevatedButton.icon(
//               icon: const Icon(Icons.add, color: ColorManager.white),
//               label: const Text('New Tutorial'),
//               onPressed: () => _showAddEditTutorialDialog(context, ref),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ColorManager.green,
//                 foregroundColor: ColorManager.white,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 if (status == TutorialStatus.loading && state.tutorials.isEmpty)
//                   const Center(
//                       child:
//                           CircularProgressIndicator(color: ColorManager.yellow))
//                 else if (status == TutorialStatus.error)
//                   Center(
//                       child: Text(
//                           'Error: ${state.errorMessage ?? "An unknown error occurred."}'))
//                 else
//                   ReorderableListView.builder(
//                     padding: const EdgeInsets.only(bottom: 80, top: 10),
//                     itemCount: state.tutorials.length,
//                     itemBuilder: (context, index) {
//                       final tutorial = state.tutorials[index];
//                       return Card(
//                         key: ValueKey(tutorial.id),
//                         color: ColorManager.dark1,
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 8.0, horizontal: 16.0),
//                           leading: SizedBox(
//                             width: 80,
//                             height: 60,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: tutorial.thumbnailUrl != null
//                                   ? Image.network(
//                                       tutorial.thumbnailUrl!,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (_, __, ___) => const Icon(
//                                           Icons.image_not_supported,
//                                           color: ColorManager.grey),
//                                     )
//                                   : const Icon(Icons.image_search,
//                                       color: ColorManager.grey, size: 40),
//                             ),
//                           ),
//                           // --- NEW: Add an icon to indicate tutorial type ---
//                           title: Row(
//                             children: [
//                               Icon(
//                                 tutorial.tutorialType == TutorialType.video
//                                     ? Icons.videocam_outlined
//                                     : Icons.article_outlined,
//                                 color: ColorManager.grey,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   tutorial.name,
//                                   style: const TextStyle(
//                                       color: ColorManager.white,
//                                       fontWeight: FontWeight.bold),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           onTap: () => _handleTutorialTap(context, tutorial),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit_outlined,
//                                     color: ColorManager.blueAccent),
//                                 tooltip: 'Edit Details',
//                                 onPressed: () => _showAddEditTutorialDialog(
//                                     context, ref, tutorial),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outline,
//                                     color: ColorManager.red),
//                                 tooltip: 'Delete',
//                                 onPressed: () =>
//                                     _showDeleteDialog(context, ref, tutorial),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                     onReorder: (int oldIndex, int newIndex) {
//                       ref
//                           .read(tutorialsProvider.notifier)
//                           .reorderTutorials(oldIndex, newIndex);
//                     },
//                   ),
//                 if (status == TutorialStatus.uploading)
//                   Container(
//                     color: Colors.black.withOpacity(0.5),
//                     child: const Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircularProgressIndicator(color: ColorManager.yellow),
//                           SizedBox(height: 16),
//                           Text('Processing...',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 16)),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AddEditTutorialDialog extends ConsumerStatefulWidget {
//   final Tutorial? tutorial;
//   const _AddEditTutorialDialog({this.tutorial});
//
//   @override
//   ConsumerState<_AddEditTutorialDialog> createState() =>
//       __AddEditTutorialDialogState();
// }
//
// class __AddEditTutorialDialogState
//     extends ConsumerState<_AddEditTutorialDialog> {
//   late final TextEditingController _nameController;
//   late final TextEditingController _videoUrlController;
//   final _formKey = GlobalKey<FormState>();
//   File? _pickedThumbnailFile;
//   late TutorialType _selectedType;
//   bool get _isEditing => widget.tutorial != null;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedType = widget.tutorial?.tutorialType ?? TutorialType.richText;
//     _nameController = TextEditingController(text: widget.tutorial?.name ?? '');
//     _videoUrlController =
//         TextEditingController(text: widget.tutorial?.videoUrl ?? '');
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _videoUrlController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _onPickThumbnail() async {
//     final picker = ImagePicker();
//     final xFile =
//         await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
//     if (xFile != null) {
//       setState(() => _pickedThumbnailFile = File(xFile.path));
//     }
//   }
//
//   Future<void> _onSave() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final name = _nameController.text.trim();
//     final videoUrl = _videoUrlController.text.trim();
//     final tutorialsNotifier = ref.read(tutorialsProvider.notifier);
//
//     if (mounted) Navigator.of(context).pop();
//
//     if (_isEditing) {
//       final tutorialToUpdate = widget.tutorial!.copyWith(
//         name: name,
//         tutorialType: _selectedType,
//         videoUrl: _selectedType == TutorialType.video ? videoUrl : null,
//         contentJson: _selectedType == TutorialType.richText
//             ? widget.tutorial!.contentJson
//             : '',
//       );
//       await tutorialsNotifier.updateTutorial(tutorialToUpdate);
//       if (_pickedThumbnailFile != null) {
//         await tutorialsNotifier.uploadThumbnailForTutorial(
//             _pickedThumbnailFile!, tutorialToUpdate.id);
//       }
//     } else {
//       final newTutorialStub = Tutorial(
//         id: '',
//         name: name,
//         tutorialType: _selectedType,
//         videoUrl: _selectedType == TutorialType.video ? videoUrl : null,
//       );
//       final newTutorial =
//           await tutorialsNotifier.addAndReturnTutorial(newTutorialStub);
//
//       if (newTutorial != null && _pickedThumbnailFile != null) {
//         await tutorialsNotifier.uploadThumbnailForTutorial(
//             _pickedThumbnailFile!, newTutorial.id);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: ColorManager.dark2,
//       title: Text(_isEditing ? 'Edit Tutorial' : 'New Tutorial',
//           style: const TextStyle(color: ColorManager.white)),
//       content: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 120,
//                 height: 90,
//                 child: InkWell(
//                   onTap: _onPickThumbnail,
//                   child: _pickedThumbnailFile != null
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.file(_pickedThumbnailFile!,
//                               fit: BoxFit.cover))
//                       : widget.tutorial?.thumbnailUrl != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                   widget.tutorial!.thumbnailUrl!,
//                                   fit: BoxFit.cover))
//                           : Container(
//                               decoration: BoxDecoration(
//                                 color: ColorManager.dark1,
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: ColorManager.grey),
//                               ),
//                               child: const Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.add_a_photo_outlined,
//                                         color: ColorManager.grey),
//                                     SizedBox(height: 4),
//                                     Text('Thumbnail',
//                                         style: TextStyle(
//                                             color: ColorManager.grey,
//                                             fontSize: 12)),
//                                   ]),
//                             ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               DropdownButtonFormField<TutorialType>(
//                 value: _selectedType,
//                 dropdownColor: ColorManager.dark1,
//                 style: const TextStyle(color: ColorManager.white),
//                 decoration: const InputDecoration(
//                   labelText: 'Tutorial Type',
//                   labelStyle: TextStyle(color: ColorManager.grey),
//                 ),
//                 items: TutorialType.values
//                     .map((type) => DropdownMenuItem(
//                         value: type,
//                         child: Text(type == TutorialType.richText
//                             ? 'Rich Text'
//                             : 'Video')))
//                     .toList(),
//                 onChanged: (value) {
//                   if (value != null) setState(() => _selectedType = value);
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _nameController,
//                 autofocus: true,
//                 style: const TextStyle(color: ColorManager.white),
//                 decoration: const InputDecoration(
//                     labelText: 'Tutorial Name',
//                     labelStyle: TextStyle(color: ColorManager.grey)),
//                 validator: (value) => (value == null || value.trim().isEmpty)
//                     ? 'Please enter a name'
//                     : null,
//               ),
//               if (_selectedType == TutorialType.video)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0),
//                   child: TextFormField(
//                     controller: _videoUrlController,
//                     style: const TextStyle(color: ColorManager.white),
//                     decoration: const InputDecoration(
//                         labelText: 'YouTube or Video URL',
//                         labelStyle: TextStyle(color: ColorManager.grey)),
//                     validator: (value) {
//                       if (_selectedType == TutorialType.video &&
//                           (value == null || value.trim().isEmpty)) {
//                         return 'Please enter a video URL';
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.of(context).pop()),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: ColorManager.green),
//           onPressed: _onSave,
//           child:
//               const Text('Save', style: TextStyle(color: ColorManager.white)),
//         ),
//       ],
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/add_edit_tutorials_content_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_viewer_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/video_viewer_dialog.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

class AdminTutorialsScreen extends ConsumerWidget {
  const AdminTutorialsScreen({super.key});

  void _showAddEditTutorialDialog(BuildContext context, WidgetRef ref,
      [Tutorial? tutorial]) {
    showDialog(
      context: context,
      builder: (_) => _AddEditTutorialDialog(tutorial: tutorial),
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

  void _handleTutorialTap(BuildContext context, Tutorial tutorial) {
    if (tutorial.tutorialType == TutorialType.video &&
        tutorial.videoUrl != null) {
      showDialog(
        context: context,
        builder: (context) => VideoViewerDialog(videoUrl: tutorial.videoUrl!),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => TutorialViewerDialog(tutorial: tutorial),
      );
    }
  }

  Widget _getTutorialTypeIcon(Tutorial tutorial) {
    if (tutorial.tutorialType == TutorialType.video) {
      bool isYoutube = tutorial.videoUrl?.contains('youtube.com/0') ?? false;
      if (isYoutube) {
        return const FaIcon(FontAwesomeIcons.youtube,
            color: Colors.red, size: 18);
      }
      return const Icon(Icons.videocam_outlined,
          color: ColorManager.grey, size: 20);
    }
    return const Icon(Icons.article_outlined,
        color: ColorManager.grey, size: 20);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: ColorManager.white),
              label: const Text('New Tutorial'),
              onPressed: () => _showAddEditTutorialDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.green,
                foregroundColor: ColorManager.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
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
                    padding: const EdgeInsets.only(bottom: 80, top: 10),
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
                          title: Row(
                            children: [
                              _getTutorialTypeIcon(tutorial),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tutorial.name,
                                  style: const TextStyle(
                                      color: ColorManager.white,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _handleTutorialTap(context, tutorial),
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
    );
  }
}

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
  late final TextEditingController _videoUrlController;
  final _formKey = GlobalKey<FormState>();
  File? _pickedThumbnailFile;
  late TutorialType _selectedType;
  bool get _isEditing => widget.tutorial != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.tutorial?.tutorialType ?? TutorialType.richText;
    _nameController = TextEditingController(text: widget.tutorial?.name ?? '');
    _videoUrlController =
        TextEditingController(text: widget.tutorial?.videoUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _onPickThumbnail() async {
    final picker = ImagePicker();
    final xFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (xFile != null) {
      setState(() => _pickedThumbnailFile = File(xFile.path));
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final videoUrl = _videoUrlController.text.trim();
    final tutorialsNotifier = ref.read(tutorialsProvider.notifier);

    if (mounted) Navigator.of(context).pop();

    if (_isEditing) {
      final tutorialToUpdate = widget.tutorial!.copyWith(
        name: name,
        tutorialType: _selectedType,
        videoUrl: _selectedType == TutorialType.video ? videoUrl : null,
        contentJson: _selectedType == TutorialType.richText
            ? widget.tutorial!.contentJson
            : '',
      );
      await tutorialsNotifier.updateTutorial(tutorialToUpdate);
      if (_pickedThumbnailFile != null) {
        await tutorialsNotifier.uploadThumbnailForTutorial(
            _pickedThumbnailFile!, tutorialToUpdate.id);
      }
    } else {
      final newTutorialStub = Tutorial(
        id: '',
        name: name,
        tutorialType: _selectedType,
        videoUrl: _selectedType == TutorialType.video ? videoUrl : null,
      );
      final newTutorial =
          await tutorialsNotifier.addAndReturnTutorial(newTutorialStub);

      if (newTutorial != null && _pickedThumbnailFile != null) {
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 90,
                child: InkWell(
                  onTap: _onPickThumbnail,
                  child: _pickedThumbnailFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_pickedThumbnailFile!,
                              fit: BoxFit.cover))
                      : widget.tutorial?.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                  widget.tutorial!.thumbnailUrl!,
                                  fit: BoxFit.cover))
                          : Container(
                              decoration: BoxDecoration(
                                color: ColorManager.dark1,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ColorManager.grey),
                              ),
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
                                  ]),
                            ),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<TutorialType>(
                value: _selectedType,
                dropdownColor: ColorManager.dark1,
                style: const TextStyle(color: ColorManager.white),
                decoration: const InputDecoration(
                  labelText: 'Tutorial Type',
                  labelStyle: TextStyle(color: ColorManager.grey),
                ),
                items: TutorialType.values
                    .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type == TutorialType.richText
                            ? 'Rich Text'
                            : 'Video')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(color: ColorManager.white),
                decoration: const InputDecoration(
                    labelText: 'Tutorial Name',
                    labelStyle: TextStyle(color: ColorManager.grey)),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a name'
                    : null,
              ),
              if (_selectedType == TutorialType.video)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _videoUrlController,
                    style: const TextStyle(color: ColorManager.white),
                    decoration: const InputDecoration(
                        labelText: 'YouTube or Video URL',
                        labelStyle: TextStyle(color: ColorManager.grey)),
                    validator: (value) {
                      if (_selectedType == TutorialType.video &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter a video URL';
                      }
                      return null;
                    },
                  ),
                ),
            ],
          ),
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
