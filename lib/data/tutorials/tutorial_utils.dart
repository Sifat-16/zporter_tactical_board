import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';

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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> resetTutorialStatus(String tutorialId) async {
    try {
      final db = await SemDB.database;

      await _tutorialStore.record(tutorialId).delete(db);
    } catch (e) {}
  }

  static Future<void> resetAllTutorials() async {
    try {
      final db = await SemDB.database;
      await _tutorialStore.delete(db); // This deletes all records in the store
    } catch (e) {}
  }
}
