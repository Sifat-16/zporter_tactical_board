import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/animation/field/default_animation_field_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/default_animation_view_model/default_animation_controller.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/default_animation_view_model/default_animation_state.dart';

class DefaultAnimationScreen extends ConsumerStatefulWidget {
  const DefaultAnimationScreen({super.key});

  @override
  ConsumerState<DefaultAnimationScreen> createState() =>
      _DefaultAnimationScreenState();
}

class _DefaultAnimationScreenState
    extends ConsumerState<DefaultAnimationScreen> {
  // --- DIALOGS for Collections and Animations ---

  void _showCreateEditCollectionDialog({AnimationCollectionModel? collection}) {
    final bool isEditing = collection != null;
    final controller = TextEditingController(text: collection?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark2,
        title: Text(isEditing ? 'Edit Collection Name' : 'New Collection',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Collection Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: ColorManager.green),
            ),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (isEditing) {
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .editCollectionName(
                        collectionId: collection!.id,
                        newName: name,
                      );
                } else {
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .createCollection(name);
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark2,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: ColorManager.red.withOpacity(0.8)),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateEditAnimationDialog(
      {required String collectionId, AnimationModel? existingAnimation}) {
    final bool isEditing = existingAnimation != null;
    final nameController =
        TextEditingController(text: existingAnimation?.name ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark2,
        title: Text(isEditing ? 'Edit Animation Name' : 'New Animation',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Animation Name'),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: ColorManager.green),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                if (isEditing) {
                  final animationToUpdate =
                      existingAnimation!.copyWith(name: name);
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .editAnimation(animationToUpdate);
                } else {
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .addAnimationToCollection(
                        name: name,
                        collectionId: collectionId,
                      );
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  // --- UI BUILDING HELPER METHODS ---

  Widget _buildLoadingIndicator() => const Expanded(
      child: Center(child: ZLoader(logoAssetPath: 'assets/image/logo.png')));

  Widget _buildErrorDisplay(String? msg) => Expanded(
      child: Center(
          child: Text(msg ?? 'An error occurred.',
              style: const TextStyle(color: Colors.red))));

  Widget _buildEmptyListIndicator(String text) => Expanded(
          child: Center(
              child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16)),
      )));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(defaultAnimationControllerProvider);
    final collections = state.defaultAnimationCollections;

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text("Default Animation Collections",
            style: TextStyle(color: Colors.white)),
        backgroundColor: ColorManager.dark1,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.create_new_folder_outlined,
                  color: Colors.white),
              label: const Text('Create New Collection'),
              onPressed: () => _showCreateEditCollectionDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (state.status == DefaultAnimationStatus.loading)
            _buildLoadingIndicator()
          else if (state.status == DefaultAnimationStatus.error)
            _buildErrorDisplay(state.errorMessage)
          else if (collections.isEmpty)
            _buildEmptyListIndicator(
                "No collections found. Create one to begin.")
          else
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: collections.length,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .reorderCollections(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return Card(
                    key: ValueKey(collection.id),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: ColorManager.dark1,
                    child: ExpansionTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child:
                            const Icon(Icons.drag_handle, color: Colors.grey),
                      ),
                      title: Text(collection.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: ColorManager.green),
                            tooltip: 'Add Animation to this Collection',
                            onPressed: () => _showCreateEditAnimationDialog(
                                collectionId: collection.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: ColorManager.blueAccent),
                            tooltip: 'Edit Collection Name',
                            onPressed: () => _showCreateEditCollectionDialog(
                                collection: collection),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: ColorManager.red),
                            tooltip: 'Delete Collection',
                            onPressed: () => _showDeleteConfirmationDialog(
                              title: 'Delete Collection',
                              content:
                                  'Are you sure you want to delete "${collection.name}" and all animations inside it?',
                              onConfirm: () => ref
                                  .read(defaultAnimationControllerProvider
                                      .notifier)
                                  .deleteCollection(collection.id),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        if (collection.animations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No animations in this collection.',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic)),
                          ),
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: collection.animations.length,
                          onReorder: (oldAnimIndex, newAnimIndex) {
                            ref
                                .read(
                                    defaultAnimationControllerProvider.notifier)
                                .reorderAnimationsInCollection(
                                  collectionId: collection.id,
                                  oldIndex: oldAnimIndex,
                                  newIndex: newAnimIndex,
                                );
                          },
                          itemBuilder: (context, animIndex) {
                            final animation = collection.animations[animIndex];
                            return ListTile(
                              key: ValueKey(animation.id),
                              leading: ReorderableDragStartListener(
                                index: animIndex,
                                child: const Icon(Icons.drag_handle,
                                    color: Colors.grey, size: 20),
                              ),
                              title: Text(animation.name,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                  '${animation.animationScenes.length} scenes',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DefaultAnimationFieldScreen(
                                      animationModel: animation),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        color: Colors.white70, size: 20),
                                    tooltip: 'Edit Animation Name',
                                    onPressed: () =>
                                        _showCreateEditAnimationDialog(
                                            collectionId: collection.id,
                                            existingAnimation: animation),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent, size: 20),
                                    tooltip: 'Delete Animation',
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                      title: 'Delete Animation',
                                      content:
                                          'Are you sure you want to delete "${animation.name}"?',
                                      onConfirm: () => ref
                                          .read(
                                              defaultAnimationControllerProvider
                                                  .notifier)
                                          .deleteAnimation(
                                              animation: animation),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
