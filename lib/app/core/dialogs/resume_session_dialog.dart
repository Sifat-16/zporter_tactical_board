import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/session/session_state_model.dart';

/// Shows a dialog asking the user if they want to resume from their last session.
/// Returns `true` if the user chose to resume, `false` or `null` if dismissed.
Future<bool?> showResumeSessionDialog({
  required BuildContext context,
  required SessionStateModel sessionState,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Theme(
        data: ThemeData.dark().copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: ColorManager.black,
          ),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: ColorManager.black,
          titlePadding: const EdgeInsets.only(
            top: 16.0,
            left: 24.0,
            right: 24.0,
          ),
          title: const Text(
            'Resume where you left off?',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: ColorManager.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the summary of where the user was
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.dark1,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: ColorManager.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sessionState.displaySummary,
                        style: const TextStyle(
                          color: ColorManager.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 8,
                    ),
                    borderRadius: 2,
                    fillColor: ColorManager.dark1,
                    onTap: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text(
                      'Start Fresh',
                      style: TextStyle(color: ColorManager.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 8,
                    ),
                    borderRadius: 2,
                    fillColor: ColorManager.blue,
                    onTap: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text(
                      'Resume',
                      style: TextStyle(color: ColorManager.white),
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
