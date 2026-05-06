import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

/// Enum to represent the user's choice when clearing a scene
enum ClearSceneOption {
  /// Clear only the current scene (becomes blank, following scenes preserved)
  clearOnly,

  /// Clear current scene and delete all following scenes
  clearAndDeleteFollowing,
}

/// Shows a simple confirmation dialog for clearing the last scene or single board
Future<bool?> showSimpleClearDialog({
  required BuildContext context,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Theme(
        data: ThemeData.dark().copyWith(
          dialogBackgroundColor: ColorManager.black,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: ColorManager.black,
          title: Row(
            children: [
              Icon(
                Icons.cleaning_services_outlined,
                color: ColorManager.yellow,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Clean up the Tactics Board?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: ColorManager.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to clean up the Tactics Board?',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This will remove all players, equipment, drawings, and shapes from the board.',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    borderRadius: 4,
                    fillColor: ColorManager.dark1,
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: ColorManager.white),
                    ),
                    onTap: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    borderRadius: 4,
                    fillColor: ColorManager.yellow,
                    onTap: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text(
                      'YES',
                      style: TextStyle(
                        color: ColorManager.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows a dialog with options when clearing a scene that has following scenes
/// Returns [ClearSceneOption.clearOnly] if user wants to just clear this scene,
/// [ClearSceneOption.clearAndDeleteFollowing] if user wants to delete this and following scenes,
/// or null if user cancels.
Future<ClearSceneOption?> showClearSceneOptionsDialog({
  required BuildContext context,
  required int currentSceneNumber,
  required int totalScenes,
}) {
  final int followingScenes = totalScenes - currentSceneNumber;

  return showDialog<ClearSceneOption>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Theme(
        data: ThemeData.dark().copyWith(
          dialogBackgroundColor: ColorManager.black,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: ColorManager.black,
          title: Row(
            children: [
              Icon(
                Icons.cleaning_services_outlined,
                color: ColorManager.yellow,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Clean Scene $currentSceneNumber of $totalScenes?',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: ColorManager.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This scene is connected to $followingScenes following scene${followingScenes > 1 ? 's' : ''}.',
                style: const TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose how to proceed:',
                style: TextStyle(
                  color: ColorManager.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Option 1: Clear only this scene
              _buildOptionCard(
                icon: Icons.cleaning_services_outlined,
                iconColor: ColorManager.yellow,
                title: 'Clear this scene only',
                description:
                    'Scene becomes blank. Following scenes preserved but may show discontinuity.',
                onTap: () {
                  Navigator.of(dialogContext).pop(ClearSceneOption.clearOnly);
                },
              ),

              const SizedBox(height: 12),

              // Option 2: Clear and delete following
              _buildOptionCard(
                icon: Icons.delete_sweep_outlined,
                iconColor: ColorManager.red,
                title: 'Clear & delete all following scenes',
                description:
                    'Removes scene $currentSceneNumber and deletes scenes ${currentSceneNumber + 1}-$totalScenes.',
                onTap: () {
                  Navigator.of(dialogContext)
                      .pop(ClearSceneOption.clearAndDeleteFollowing);
                },
                isDestructive: true,
              ),

              const SizedBox(height: 20),

              // Cancel button
              Center(
                child: CustomButton(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  borderRadius: 4,
                  fillColor: ColorManager.dark1,
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: ColorManager.white),
                  ),
                  onTap: () {
                    Navigator.of(dialogContext).pop(null);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildOptionCard({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String description,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDestructive
              ? ColorManager.red.withOpacity(0.3)
              : ColorManager.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: ColorManager.dark1.withOpacity(0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        isDestructive ? ColorManager.red : ColorManager.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: ColorManager.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: ColorManager.grey,
            size: 20,
          ),
        ],
      ),
    ),
  );
}
