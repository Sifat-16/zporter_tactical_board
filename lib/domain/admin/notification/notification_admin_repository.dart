// import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
// import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
//
// /// Abstract interface for the admin-side notification repository.
// ///
// /// This contract defines the methods that the presentation layer (ViewModels/Controllers)
// /// will use to interact with notification-related functionalities.
// abstract class NotificationAdminRepository {
//   /// Sends a notification to the specified target and logs the attempt.
//   ///
//   /// The [target] can be a user's FCM token or a topic name.
//   /// Returns `true` if the notification was sent successfully, `false` otherwise.
//   Future<bool> sendNotificationAndLog({
//     required String title,
//     required String body,
//     required String target,
//   });
//
//   /// Fetches a list of all users.
//   Future<List<NotificationUserModel>> getUsers();
//
//   /// Fetches the historical log of all sent notifications.
//   Future<List<SentNotificationModel>> getSentNotifications();
// }

import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';

/// Abstract interface for the admin-side notification repository.
abstract class NotificationAdminRepository {
  /// Sends a notification to the specified target and logs the attempt.
  Future<bool> sendNotificationAndLog({
    required String title,
    required String body,
    required String target,
    String? coverImageUrl, // New parameter
    List<String>? mediaUrls, // New parameter
  });

  /// Fetches a list of all users.
  Future<List<NotificationUserModel>> getUsers();

  /// Fetches the historical log of all sent notifications.
  Future<List<SentNotificationModel>> getSentNotifications();
}
