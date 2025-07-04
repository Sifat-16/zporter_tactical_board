import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
import 'package:zporter_tactical_board/domain/admin/notification/notification_admin_repository.dart';

/// Represents the state of the Admin Notification UI.
/// It is immutable and uses Equatable to prevent unnecessary rebuilds.
class NotificationAdminState {
  final bool isLoading;
  final bool isSending;
  final List<NotificationUserModel> users;
  final List<SentNotificationModel> sentNotifications;
  final String? error;

  const NotificationAdminState({
    this.isLoading = false,
    this.isSending = false,
    this.users = const [],
    this.sentNotifications = const [],
    this.error,
  });

  /// Creates a copy of the state with the given fields replaced with the new values.
  NotificationAdminState copyWith({
    bool? isLoading,
    bool? isSending,
    List<NotificationUserModel>? users,
    List<SentNotificationModel>? sentNotifications,
    String? error,
    bool clearError = false,
  }) {
    return NotificationAdminState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      users: users ?? this.users,
      sentNotifications: sentNotifications ?? this.sentNotifications,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// The ViewModel (StateNotifier) for the Admin Notification screen.
class NotificationAdminViewModel extends StateNotifier<NotificationAdminState> {
  final NotificationAdminRepository _repository;

  NotificationAdminViewModel(this._repository)
      : super(const NotificationAdminState()) {
    // Load initial data when the ViewModel is created.
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Fetch users and sent notification history in parallel.
      final futures = [
        _repository.getUsers(),
        _repository.getSentNotifications(),
      ];
      final results = await Future.wait(futures);
      state = state.copyWith(
        isLoading: false,
        users: results[0] as List<NotificationUserModel>,
        sentNotifications: results[1] as List<SentNotificationModel>,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load data: ${e.toString()}');
    }
  }

  /// Sends a notification and refreshes the history.
  Future<bool> sendNotification({
    required String title,
    required String body,
    required String target,
  }) async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final success = await _repository.sendNotificationAndLog(
        title: title,
        body: body,
        target: target,
      );

      // Refresh the sent notifications list after sending.
      final updatedList = await _repository.getSentNotifications();
      state = state.copyWith(
        isSending: false,
        sentNotifications: updatedList,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
          isSending: false,
          error: 'Failed to send notification: ${e.toString()}');
      return false;
    }
  }
}

// The StateNotifierProvider that the UI will use to interact with the ViewModel.
final notificationAdminViewModelProvider = StateNotifierProvider.autoDispose<
    NotificationAdminViewModel, NotificationAdminState>(
  (ref) {
    // Get the repository instance from the GetIt service locator.
    final repository = sl.get<NotificationAdminRepository>();
    return NotificationAdminViewModel(repository);
  },
);
