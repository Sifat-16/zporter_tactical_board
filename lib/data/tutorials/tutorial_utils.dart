import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

class TutorialUtils {
  TutorialUtils._();

  static const String _tutorialStoreName = 'tutorial_status_store';

  static final _tutorialStore = stringMapStoreFactory.store(_tutorialStoreName);

  static Future<void> markTutorialAsShown(String tutorialId) async {
    // try {
    //   final db = await SemDB.database;
    //   await _tutorialStore.record(tutorialId).put(db, {'shown': true});
    //   zlog(data: 'TutorialUtils: Marked tutorial "$tutorialId" as shown.');
    // } catch (e) {
    //   zlog(
    //     data:
    //         'TutorialUtils: Error marking tutorial "$tutorialId" as shown: $e',
    //   );
    // }
  }

  static Future<bool> isTutorialShown(String tutorialId) async {
    try {
      final db = await SemDB.database;
      final record = await _tutorialStore.record(tutorialId).get(db);

      if (record != null && record['shown'] == true) {
        zlog(data: 'TutorialUtils: Tutorial "$tutorialId" has been shown.');
        return true;
      } else {
        zlog(data: 'TutorialUtils: Tutorial "$tutorialId" has NOT been shown.');
        return false;
      }
    } catch (e) {
      zlog(
        data:
            'TutorialUtils: Error checking if tutorial "$tutorialId" was shown: $e',
      );
      return false;
    }
  }

  static Future<void> resetTutorialStatus(String tutorialId) async {
    try {
      final db = await SemDB.database;

      await _tutorialStore.record(tutorialId).delete(db);

      zlog(data: 'TutorialUtils: Reset status for tutorial "$tutorialId".');
    } catch (e) {
      zlog(
        data:
            'TutorialUtils: Error resetting status for tutorial "$tutorialId": $e',
      );
    }
  }

  static Future<void> resetAllTutorials() async {
    try {
      final db = await SemDB.database;
      await _tutorialStore.delete(db); // This deletes all records in the store
      zlog(data: 'TutorialUtils: All tutorial statuses have been reset.');
    } catch (e) {
      zlog(data: 'TutorialUtils: Error resetting all tutorial statuses: $e');
    }
  }
}
