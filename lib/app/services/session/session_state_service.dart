import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/session/session_state_model.dart';

/// Lightweight local-only service for persisting the user's last navigation
/// context so the app can offer "resume where you left off" on next launch.
class SessionStateService {
  SessionStateService._();

  static final _store = stringMapStoreFactory.store('session_state');
  static const String _recordKey = 'last_session';

  /// Save the current session state to Sembast.
  /// Fire-and-forget — never throws, never blocks the caller.
  static Future<void> save(SessionStateModel sessionState) async {
    try {
      final db = await SemDB.database;
      await _store.record(_recordKey).put(db, sessionState.toJson());
    } catch (e) {
      zlog(data: "SessionState: Error saving session state: $e");
    }
  }

  /// Retrieve the last saved session state, or null if none exists.
  static Future<SessionStateModel?> get() async {
    try {
      final db = await SemDB.database;
      final snapshot = await _store.record(_recordKey).getSnapshot(db);
      if (snapshot == null) return null;
      return SessionStateModel.fromJson(snapshot.value);
    } catch (e) {
      zlog(data: "SessionState: Error reading session state: $e");
      return null;
    }
  }

  /// Clear the saved session state.
  static Future<void> clear() async {
    try {
      final db = await SemDB.database;
      await _store.record(_recordKey).delete(db);
    } catch (e) {
      zlog(data: "SessionState: Error clearing session state: $e");
    }
  }
}
