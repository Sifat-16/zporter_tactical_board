import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/state/animation_notifier.dart';
import 'package:zporter_tactical_board/v2/state/animation_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/collection_notifier.dart';
import 'package:zporter_tactical_board/v2/state/collection_provider.dart';

/// Animation panel: collection/animation/scene browser + playback controls.
///
/// Watches [collectionProviderV2] for collections, selected animation, scenes.
/// Provides CRUD operations and playback controls via the respective notifiers.
class AnimationPanelV2 extends ConsumerWidget {
  /// User ID required for creating collections/animations.
  final String userId;

  const AnimationPanelV2({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collState = ref.watch(collectionProviderV2);
    final animState = ref.watch(animationProviderV2);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Collection dropdown
        _buildCollectionDropdown(context, ref, collState),
        const SizedBox(height: 12),

        // Animation dropdown
        if (collState.selectedCollection != null) ...[
          _buildAnimationDropdown(context, ref, collState),
          const SizedBox(height: 12),
        ],

        // Scene list
        if (collState.selectedAnimation != null) ...[
          _buildSceneList(context, ref, collState),
          const SizedBox(height: 16),
        ],

        // Playback controls
        _buildPlaybackControls(ref, animState),

        const SizedBox(height: 12),

        // Save button
        if (collState.selectedAnimation != null) _buildSaveButton(ref),
      ],
    );
  }

  Widget _buildCollectionDropdown(
    BuildContext context,
    WidgetRef ref,
    CollectionState collState,
  ) {
    final collections = collState.collections;
    final selectedIdx = collState.selectedCollection == null
        ? -1
        : collections.indexWhere(
            (c) => c.id == collState.selectedCollection!.id);

    return _LabeledDropdown(
      label: 'Collection',
      onAdd: () => _createCollection(context, ref),
      child: DropdownButton<int>(
        value: selectedIdx >= 0 ? selectedIdx : null,
        hint: const Text('Select Collection',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white, fontSize: 12),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: List.generate(collections.length, (i) {
          return DropdownMenuItem(value: i, child: Text(collections[i].name));
        }),
        onChanged: (i) {
          if (i != null) {
            ref
                .read(collectionProviderV2.notifier)
                .selectCollection(collections[i]);
          }
        },
      ),
    );
  }

  Widget _buildAnimationDropdown(
    BuildContext context,
    WidgetRef ref,
    CollectionState collState,
  ) {
    final animations = collState.selectedCollection!.animations;
    final selectedIdx = collState.selectedAnimation == null
        ? -1
        : animations.indexWhere(
            (a) => a.id == collState.selectedAnimation!.id);

    return _LabeledDropdown(
      label: 'Animation',
      onAdd: () => _createAnimation(context, ref),
      child: DropdownButton<int>(
        value: selectedIdx >= 0 ? selectedIdx : null,
        hint: const Text('Select Animation',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white, fontSize: 12),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: List.generate(animations.length, (i) {
          return DropdownMenuItem(value: i, child: Text(animations[i].name));
        }),
        onChanged: (i) {
          if (i != null) {
            ref
                .read(collectionProviderV2.notifier)
                .selectAnimation(animations[i]);
          }
        },
      ),
    );
  }

  Widget _buildSceneList(
    BuildContext context,
    WidgetRef ref,
    CollectionState collState,
  ) {
    final scenes = collState.selectedAnimation!.animationScenes;
    final selectedIndex = collState.selectedSceneIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Scenes',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
            InkWell(
              onTap: () {
                final boardState = ref.read(boardProviderV2);
                ref
                    .read(collectionProviderV2.notifier)
                    .addScene(boardState.currentScene);
              },
              child: const Icon(Icons.add, color: Colors.amber, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...scenes.asMap().entries.map((entry) {
          final index = entry.key;
          final scene = entry.value;
          final isSelected = index == selectedIndex;

          return InkWell(
            onTap: () {
              ref.read(collectionProviderV2.notifier).selectScene(index);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? Border.all(color: Colors.amber, width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    'Scene ${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.amber : Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${scene.components.length} items',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      ref
                          .read(collectionProviderV2.notifier)
                          .deleteScene(scene.id);
                    },
                    child: const Icon(Icons.close,
                        color: Colors.white38, size: 14),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlaybackControls(
      WidgetRef ref, AnimationPlaybackState animState) {
    final isPlaying = animState.playbackState == PlaybackState.playing;
    final isPaused = animState.playbackState == PlaybackState.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.white70,
          iconSize: 24,
          onPressed: () => ref.read(animationProviderV2.notifier).stop(),
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          color: Colors.amber,
          iconSize: 32,
          onPressed: () {
            final notifier = ref.read(animationProviderV2.notifier);
            if (isPlaying) {
              notifier.pause();
            } else if (isPaused) {
              notifier.resume();
            } else {
              // Load and play from beginning
              final animation =
                  ref.read(collectionProviderV2).selectedAnimation;
              if (animation != null) {
                notifier.loadAnimation(animation);
                notifier.play();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final boardState = ref.read(boardProviderV2);
          ref
              .read(collectionProviderV2.notifier)
              .saveCurrentScene(boardState.currentScene);
        },
        icon: const Icon(Icons.save, size: 16),
        label: const Text('Save Scene', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Future<void> _createCollection(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(context, 'New Collection');
    if (name == null || name.isEmpty) return;
    ref.read(collectionProviderV2.notifier).createCollection(name, userId);
  }

  Future<void> _createAnimation(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(context, 'New Animation');
    if (name == null || name.isEmpty) return;
    ref.read(collectionProviderV2.notifier).createAnimation(name, userId);
  }

  Future<String?> _showNameDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter name',
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child:
                  const Text('Create', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }
}

/// Internal labeled dropdown wrapper.
class _LabeledDropdown extends StatelessWidget {
  final String label;
  final VoidCallback onAdd;
  final Widget child;

  const _LabeledDropdown({
    required this.label,
    required this.onAdd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            InkWell(
              onTap: onAdd,
              child: const Icon(Icons.add, color: Colors.amber, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
        ),
      ],
    );
  }
}
