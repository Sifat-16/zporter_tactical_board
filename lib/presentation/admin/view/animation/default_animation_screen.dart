import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/admin/view/animation/field/default_animation_field_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/default_animation_view_model/default_animation_controller.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/admin/view_model/default_animation_view_model/default_animation_state.dart'; // Adjust path

class DefaultAnimationScreen extends ConsumerStatefulWidget {
  const DefaultAnimationScreen({super.key});

  @override
  ConsumerState<DefaultAnimationScreen> createState() =>
      _DefaultAnimationScreenState();
}

class _DefaultAnimationScreenState
    extends ConsumerState<DefaultAnimationScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildAnimationNameField(TextEditingController controller) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: const TextStyle(color: ColorManager.white),
      decoration: InputDecoration(
        labelText: 'Animation Name',
        labelStyle: const TextStyle(color: ColorManager.grey),
        hintText: 'e.g., Attacking Pattern 1',
        hintStyle: TextStyle(color: ColorManager.grey.withValues(alpha: 0.7)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.green),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.grey),
        ),
      ),
    );
  }

  void _showCreateEditAnimationDialog({AnimationModel? existingAnimation}) {
    final bool isEditing = existingAnimation != null;
    final TextEditingController nameController = TextEditingController(
      text: existingAnimation?.name ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: Text(
            isEditing ? 'Edit Default Animation' : 'Create Default Animation',
            style: const TextStyle(color: ColorManager.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[_buildAnimationNameField(nameController)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: ColorManager.grey),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(color: ColorManager.green),
              ),
              onPressed: () {
                final String name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Animation name cannot be empty.'),
                      backgroundColor: ColorManager.red,
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  // For editing, we pass the existing animation's core data along with changes
                  final animationToUpdate = existingAnimation.copyWith(
                    name: name,
                  );
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .editDefaultAnimation(animationToUpdate);
                } else {
                  // For new, the controller will set defaults like ID, userId, timestamps, and default fieldColor
                  final newAnimationData = AnimationModel(
                    id: '', // Controller will generate ID
                    name: name,
                    userId:
                        '', // Controller will set to SYSTEM_USER_ID_FOR_DEFAULTS
                    fieldColor: ColorManager.grey.withOpacity(
                      0.7,
                    ), // Default, controller can also set this
                    animationScenes: [],
                    createdAt: DateTime.now(), // Controller can set this
                    updatedAt: DateTime.now(), // Controller can set this
                  );
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .addDefaultAnimation(newAnimationData);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAnimationDialog(AnimationModel animation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: const Text(
            'Confirm Delete',
            style: TextStyle(color: ColorManager.white),
          ),
          content: Text(
            'Are you sure you want to delete the animation "${animation.name}"?',
            style: const TextStyle(color: ColorManager.grey),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: ColorManager.white),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: ColorManager.red.withOpacity(0.8),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: ColorManager.white),
              ),
              onPressed: () {
                ref
                    .read(defaultAnimationControllerProvider.notifier)
                    .deleteDefaultAnimation(animation.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- UI Building Helper Methods ---
  Widget _buildCreateNewButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_circle_outline, color: ColorManager.white),
        label: const Text('Create New Default Animation'),
        onPressed: () => _showCreateEditAnimationDialog(),
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

  Widget _buildLoadingIndicator() {
    return const Expanded(
      child: Center(
        child: ZLoader(logoAssetPath: "assets/image/logo.png"),
        // child: CircularProgressIndicator(color: ColorManager.yellow),
      ),
    );
  }

  Widget _buildErrorDisplay(String? errorMessage) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: ColorManager.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Animations',
                style: TextStyle(
                  color: ColorManager.red.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'An unknown error occurred.',
                style: TextStyle(
                  color: ColorManager.red.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, color: ColorManager.white),
                label: const Text(
                  "Retry",
                  style: TextStyle(color: ColorManager.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blueAccent.withOpacity(0.8),
                ),
                onPressed: () {
                  ref
                      .read(defaultAnimationControllerProvider.notifier)
                      .loadAllDefaultAnimations();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyListIndicator() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_creation_outlined,
                color: ColorManager.grey,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'No default animations found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap "Create New" to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorManager.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationListItem(AnimationModel animation, int index) {
    return Card(
      key: ValueKey(animation.id),
      color: ColorManager.dark1,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle, color: ColorManager.grey),
        ),
        title: Text(
          animation.name,
          style: const TextStyle(
            color: ColorManager.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${animation.animationScenes.length} scene(s) | Updated: ${TimeOfDay.fromDateTime(animation.updatedAt).format(context)}',
          style: const TextStyle(color: ColorManager.grey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: ImageIcon(
                AssetImage("assets/image/soccer-field.png"),
                color: ColorManager.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DefaultAnimationFieldScreen(
                      animationModel: animation,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: ColorManager.blueAccent,
              ),
              tooltip: 'Edit "${animation.name}"',
              onPressed: () => _showCreateEditAnimationDialog(
                existingAnimation: animation,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: ColorManager.red),
              tooltip: 'Delete "${animation.name}"',
              onPressed: () => _deleteAnimationDialog(animation),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAnimationList(List<AnimationModel> animations) {
  //   return Expanded(
  //     child: ListView.builder(
  //       padding: const EdgeInsets.only(bottom: 16.0),
  //       itemCount: animations.length,
  //       itemBuilder: (context, index) {
  //         final animation = animations[index];
  //         return _buildAnimationListItem(animation);
  //       },
  //     ),
  //   );
  // }

  Widget _buildAnimationList(List<AnimationModel> animations) {
    return Expanded(
      // MODIFIED: Use ReorderableListView.builder
      child: ReorderableListView.builder(
        padding: const EdgeInsets.only(bottom: 16.0),
        itemCount: animations.length,
        itemBuilder: (context, index) {
          final animation = animations[index];
          // Pass index to the item builder for the drag listener
          return _buildAnimationListItem(animation, index);
        },
        onReorder: (oldIndex, newIndex) {
          // Call the new method in the controller
          ref
              .read(defaultAnimationControllerProvider.notifier)
              .reorderDefaultAnimations(oldIndex, newIndex);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultAnimationState = ref.watch(defaultAnimationControllerProvider);
    final List<AnimationModel> animationsToDisplay =
        defaultAnimationState.defaultAnimations;

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text(
          "Default Animations",
          style: TextStyle(color: ColorManager.white),
        ),
        backgroundColor: ColorManager.dark1,
        elevation: 2,
        iconTheme: const IconThemeData(color: ColorManager.white),
      ),
      body: Column(
        children: [
          _buildCreateNewButton(),
          if (defaultAnimationState.status == DefaultAnimationStatus.loading)
            _buildLoadingIndicator()
          else if (defaultAnimationState.status == DefaultAnimationStatus.error)
            _buildErrorDisplay(defaultAnimationState.errorMessage)
          else if (animationsToDisplay.isEmpty) // Check the derived list
            _buildEmptyListIndicator()
          else
            _buildAnimationList(animationsToDisplay), // Pass the derived list
        ],
      ),
    );
  }
}
