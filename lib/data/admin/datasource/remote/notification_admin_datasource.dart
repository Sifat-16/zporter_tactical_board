import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';

/// A simple model to represent a user for the notification target list.
class NotificationUserModel {
  final String id;
  final String name;
  final String?
      fcmToken; // The user's FCM token is needed to send direct messages.

  NotificationUserModel({required this.id, required this.name, this.fcmToken});

  factory NotificationUserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationUserModel(
      id: doc.id,
      // Assuming user documents have 'name' and 'fcmToken' fields.
      // Adjust if your user schema is different.
      name: data['name'] ?? 'Unnamed User',
      fcmToken: data['fcmToken'] as String?,
    );
  }
}

/// Abstract interface for the admin-side notification data source.
abstract class NotificationAdminDataSource {
  /// Fetches a list of all users from Firestore.
  Future<List<NotificationUserModel>> getUsers();

  /// Saves a [SentNotificationModel] to the Firestore database.
  Future<void> saveSentNotification(SentNotificationModel notification);

  /// Fetches the historical log of all notifications sent from the admin panel.
  Future<List<SentNotificationModel>> getSentNotifications();
}

/// The Firestore implementation of the [NotificationAdminDataSource].
class NotificationAdminDataSourceImpl implements NotificationAdminDataSource {
  final FirebaseFirestore _firestore;

  // The collection names for users and the notification log.
  static const String _usersCollection = 'users';
  static const String _sentNotificationsCollection = 'sent_notifications';

  NotificationAdminDataSourceImpl(this._firestore);

  @override
  Future<List<NotificationUserModel>> getUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs
          .map((doc) => NotificationUserModel.fromDoc(doc))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      // Return an empty list or rethrow a custom exception.
      return [];
    }
  }

  @override
  Future<void> saveSentNotification(SentNotificationModel notification) async {
    try {
      await _firestore
          .collection(_sentNotificationsCollection)
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      print('Error saving sent notification: $e');
      // Handle the error appropriately.
      rethrow;
    }
  }

  @override
  Future<List<SentNotificationModel>> getSentNotifications() async {
    try {
      final snapshot = await _firestore
          .collection(_sentNotificationsCollection)
          // Order by sent time, with the most recent first.
          .orderBy('sentAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SentNotificationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching sent notifications: $e');
      return [];
    }
  }
}
