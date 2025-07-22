// import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
// import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
// import 'package:zporter_tactical_board/data/admin/service/notification_admin_service.dart';
//
// import 'notification_admin_repository.dart';
//
// /// The concrete implementation of the [NotificationAdminRepository].
// ///
// /// This class coordinates between the [NotificationAdminService] to send
// /// messages and the [NotificationAdminDataSource] to log the results and
// /// fetch related data.
// class NotificationAdminRepositoryImpl implements NotificationAdminRepository {
//   final NotificationAdminService _notificationService;
//   final NotificationAdminDataSource _dataSource;
//
//   NotificationAdminRepositoryImpl(
//     this._notificationService,
//     this._dataSource,
//   );
//
//   @override
//   Future<bool> sendNotificationAndLog({
//     required String title,
//     required String body,
//     required String target,
//   }) async {
//     // 1. Attempt to send the notification via the service.
//     final result = await _notificationService.sendNotification(
//       title: title,
//       body: body,
//       target: target,
//     );
//
//     // 2. Create a log entry based on the result.
//     final notificationLog = SentNotificationModel(
//       id: RandomGenerator.generateId(),
//       title: title,
//       body: body,
//       target: target,
//       sentAt: DateTime.now(),
//       status: result.success
//           ? SentNotificationStatus.success
//           : SentNotificationStatus.failure,
//       failureReason: result.error,
//     );
//
//     // 3. Save the log to Firestore.
//     // We do this regardless of success or failure to have a complete audit trail.
//     await _dataSource.saveSentNotification(notificationLog);
//
//     // 4. Return the success status of the send operation.
//     return result.success;
//   }
//
//   @override
//   Future<List<NotificationUserModel>> getUsers() {
//     return _dataSource.getUsers();
//   }
//
//   @override
//   Future<List<SentNotificationModel>> getSentNotifications() {
//     return _dataSource.getSentNotifications();
//   }
// }

import 'dart:convert';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
import 'package:zporter_tactical_board/data/admin/service/notification_admin_service.dart';
import 'package:zporter_tactical_board/domain/admin/notification/notification_admin_repository.dart';

/// The concrete implementation of the [NotificationAdminRepository].
class NotificationAdminRepositoryImpl implements NotificationAdminRepository {
  final NotificationAdminService _notificationService;
  final NotificationAdminDataSource _dataSource;

  NotificationAdminRepositoryImpl(
    this._notificationService,
    this._dataSource,
  );

  @override
  Future<bool> sendNotificationAndLog({
    required String title,
    required String body,
    required String target,
    String? coverImageUrl,
    List<String>? mediaUrls,
  }) async {
    // 1. Prepare the custom data payload for the notification.
    final Map<String, String> dataPayload = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    };
    if (mediaUrls != null && mediaUrls.isNotEmpty) {
      // Encode the list of URLs into a single JSON string.
      dataPayload['mediaUrls'] = jsonEncode(mediaUrls);
    }

    // 2. Attempt to send the notification via the service.
    // NOTE: We will update the `_notificationService` in a future step
    // to accept `imageUrl` and `data`.
    final result = await _notificationService.sendNotification(
      title: title,
      body: body,
      target: target,
      imageUrl: coverImageUrl,
      data: dataPayload,
    );

    // 3. Create a log entry with the new media data.
    final notificationLog = SentNotificationModel(
      id: RandomGenerator.generateId(),
      title: title,
      body: body,
      target: target,
      sentAt: DateTime.now(),
      status: result.success
          ? SentNotificationStatus.success
          : SentNotificationStatus.failure,
      failureReason: result.error,
      coverImageUrl: coverImageUrl,
      mediaUrls: mediaUrls,
    );

    // 4. Save the log to Firestore.
    await _dataSource.saveSentNotification(notificationLog);

    // 5. Return the success status of the send operation.
    return result.success;
  }

  @override
  Future<List<NotificationUserModel>> getUsers() {
    return _dataSource.getUsers();
  }

  @override
  Future<List<SentNotificationModel>> getSentNotifications() {
    return _dataSource.getSentNotifications();
  }
}
