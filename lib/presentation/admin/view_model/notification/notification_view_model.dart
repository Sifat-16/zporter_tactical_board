// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/services/injection_container.dart';
// import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
// import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
// import 'package:zporter_tactical_board/domain/admin/notification/notification_admin_repository.dart';
//
// /// Represents the state of the Admin Notification UI.
// /// It is immutable and uses Equatable to prevent unnecessary rebuilds.
// class NotificationAdminState {
//   final bool isLoading;
//   final bool isSending;
//   final List<NotificationUserModel> users;
//   final List<SentNotificationModel> sentNotifications;
//   final String? error;
//
//   const NotificationAdminState({
//     this.isLoading = false,
//     this.isSending = false,
//     this.users = const [],
//     this.sentNotifications = const [],
//     this.error,
//   });
//
//   /// Creates a copy of the state with the given fields replaced with the new values.
//   NotificationAdminState copyWith({
//     bool? isLoading,
//     bool? isSending,
//     List<NotificationUserModel>? users,
//     List<SentNotificationModel>? sentNotifications,
//     String? error,
//     bool clearError = false,
//   }) {
//     return NotificationAdminState(
//       isLoading: isLoading ?? this.isLoading,
//       isSending: isSending ?? this.isSending,
//       users: users ?? this.users,
//       sentNotifications: sentNotifications ?? this.sentNotifications,
//       error: clearError ? null : error ?? this.error,
//     );
//   }
// }
//
// /// The ViewModel (StateNotifier) for the Admin Notification screen.
// class NotificationAdminViewModel extends StateNotifier<NotificationAdminState> {
//   final NotificationAdminRepository _repository;
//
//   NotificationAdminViewModel(this._repository)
//       : super(const NotificationAdminState()) {
//     // Load initial data when the ViewModel is created.
//     _loadInitialData();
//   }
//
//   Future<void> _loadInitialData() async {
//     state = state.copyWith(isLoading: true, clearError: true);
//     try {
//       // Fetch users and sent notification history in parallel.
//       final futures = [
//         _repository.getUsers(),
//         _repository.getSentNotifications(),
//       ];
//       final results = await Future.wait(futures);
//       state = state.copyWith(
//         isLoading: false,
//         users: results[0] as List<NotificationUserModel>,
//         sentNotifications: results[1] as List<SentNotificationModel>,
//       );
//     } catch (e) {
//       state = state.copyWith(
//           isLoading: false, error: 'Failed to load data: ${e.toString()}');
//     }
//   }
//
//   /// Sends a notification and refreshes the history.
//   Future<bool> sendNotification({
//     required String title,
//     required String body,
//     required String target,
//   }) async {
//     state = state.copyWith(isSending: true, clearError: true);
//     try {
//       final success = await _repository.sendNotificationAndLog(
//         title: title,
//         body: body,
//         target: target,
//       );
//
//       // Refresh the sent notifications list after sending.
//       final updatedList = await _repository.getSentNotifications();
//       state = state.copyWith(
//         isSending: false,
//         sentNotifications: updatedList,
//       );
//       return success;
//     } catch (e) {
//       state = state.copyWith(
//           isSending: false,
//           error: 'Failed to send notification: ${e.toString()}');
//       return false;
//     }
//   }
// }
//
// // The StateNotifierProvider that the UI will use to interact with the ViewModel.
// final notificationAdminViewModelProvider = StateNotifierProvider.autoDispose<
//     NotificationAdminViewModel, NotificationAdminState>(
//   (ref) {
//     // Get the repository instance from the GetIt service locator.
//     final repository = sl.get<NotificationAdminRepository>();
//     return NotificationAdminViewModel(repository);
//   },
// );

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
import 'package:zporter_tactical_board/data/admin/service/file_storage_service.dart';
import 'package:zporter_tactical_board/domain/admin/notification/notification_admin_repository.dart';

/// Represents the state of the Admin Notification UI.
class NotificationAdminState {
  final bool isLoading;
  final bool isSending;
  final List<NotificationUserModel> users;
  final List<SentNotificationModel> sentNotifications;
  final String? error;

  // Fields for media handling
  final bool isUploadingMedia;
  final List<String> uploadedMediaUrls;
  final String? coverImageUrl;
  final String? mediaError;

  const NotificationAdminState({
    this.isLoading = false,
    this.isSending = false,
    this.users = const [],
    this.sentNotifications = const [],
    this.error,
    this.isUploadingMedia = false,
    this.uploadedMediaUrls = const [],
    this.coverImageUrl,
    this.mediaError,
  });

  /// Creates a copy of the state with the given fields replaced with the new values.
  NotificationAdminState copyWith({
    bool? isLoading,
    bool? isSending,
    List<NotificationUserModel>? users,
    List<SentNotificationModel>? sentNotifications,
    String? error,
    bool clearError = false,
    bool? isUploadingMedia,
    List<String>? uploadedMediaUrls,
    String? coverImageUrl,
    bool clearCoverImage = false,
    String? mediaError,
    bool clearMediaError = false,
  }) {
    return NotificationAdminState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      users: users ?? this.users,
      sentNotifications: sentNotifications ?? this.sentNotifications,
      error: clearError ? null : error ?? this.error,
      isUploadingMedia: isUploadingMedia ?? this.isUploadingMedia,
      uploadedMediaUrls: uploadedMediaUrls ?? this.uploadedMediaUrls,
      coverImageUrl:
          clearCoverImage ? null : coverImageUrl ?? this.coverImageUrl,
      mediaError: clearMediaError ? null : mediaError ?? this.mediaError,
    );
  }
}

/// The ViewModel (StateNotifier) for the Admin Notification screen.
class NotificationAdminViewModel extends StateNotifier<NotificationAdminState> {
  final NotificationAdminRepository _repository;
  final FileStorageService _fileStorageService;

  NotificationAdminViewModel(this._repository, this._fileStorageService)
      : super(const NotificationAdminState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
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
    if (state.isSending || state.isUploadingMedia) return false;

    state = state.copyWith(
        isSending: true, clearError: true, clearMediaError: true);
    try {
      final success = await _repository.sendNotificationAndLog(
        title: title,
        body: body,
        target: target,
        coverImageUrl: state.coverImageUrl,
        mediaUrls: state.uploadedMediaUrls,
      );

      final updatedList = await _repository.getSentNotifications();
      state = state.copyWith(
        isSending: false,
        sentNotifications: updatedList,
        // Clear media from composer on successful send for good UX
        uploadedMediaUrls: [],
        clearCoverImage: true,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
          isSending: false,
          error: 'Failed to send notification: ${e.toString()}');
      return false;
    }
  }

  /// Opens a file picker, uploads selected media, and updates the state.
  Future<void> selectAndUploadMedia() async {
    state = state.copyWith(isUploadingMedia: true, clearMediaError: true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media, // Allows images and videos
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<String> newUrls = [];
        for (final file in result.files) {
          if (file.path != null) {
            final url = await _fileStorageService.uploadFile(
              File(file.path!),
              'notification_media', // Folder in Firebase Storage
            );
            newUrls.add(url);
          }
        }
        state = state.copyWith(
          uploadedMediaUrls: [...state.uploadedMediaUrls, ...newUrls],
          isUploadingMedia: false,
        );
      } else {
        // User canceled the picker
        state = state.copyWith(isUploadingMedia: false);
      }
    } catch (e) {
      state = state.copyWith(
          isUploadingMedia: false, mediaError: 'Upload failed: $e');
    }
  }

  /// Adds a media item from a pasted URL.
  void addMediaFromUrl(String url) {
    if (url.isEmpty || !Uri.parse(url).isAbsolute) {
      state = state.copyWith(mediaError: 'Please enter a valid URL.');
      return;
    }
    if (state.uploadedMediaUrls.contains(url)) {
      state = state.copyWith(mediaError: 'This media has already been added.');
      return;
    }

    final updatedUrls = [...state.uploadedMediaUrls, url];
    state = state.copyWith(
      uploadedMediaUrls: updatedUrls,
      clearMediaError: true,
    );
  }

  /// Removes a media URL from the list.
  void removeMedia(String urlToRemove) {
    final updatedUrls = List<String>.from(state.uploadedMediaUrls)
      ..remove(urlToRemove);

    if (state.coverImageUrl == urlToRemove) {
      state = state.copyWith(
        uploadedMediaUrls: updatedUrls,
        clearCoverImage: true,
      );
    } else {
      state = state.copyWith(uploadedMediaUrls: updatedUrls);
    }
  }

  /// Designates one of the uploaded images as the cover/teaser image.
  void setAsCoverImage(String url) {
    state = state.copyWith(coverImageUrl: url);
  }
}

// The StateNotifierProvider that the UI will use to interact with the ViewModel.
final notificationAdminViewModelProvider = StateNotifierProvider.autoDispose<
    NotificationAdminViewModel, NotificationAdminState>(
  (ref) {
    final repository = sl.get<NotificationAdminRepository>();
    final fileStorageService = sl.get<FileStorageService>();
    return NotificationAdminViewModel(repository, fileStorageService);
  },
);
