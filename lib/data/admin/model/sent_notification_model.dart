// import 'package:cloud_firestore/cloud_firestore.dart';
//
// /// Enum to represent the status of a sent notification.
// enum SentNotificationStatus {
//   success,
//   failure,
// }
//
// /// Represents the data model for a notification sent from the admin panel.
// ///
// /// This class defines the structure of a notification log object, including its
// /// content, target audience, and the status of the send operation. It includes
// /// methods for converting to and from a map for Firestore storage.
// class SentNotificationModel {
//   final String id;
//   final String title;
//   final String body;
//   final String
//       target; // e.g., 'all_users', 'pro_offers', or a specific user ID/token
//   final DateTime sentAt;
//   final SentNotificationStatus status;
//   final String? failureReason;
//
//   SentNotificationModel({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.target,
//     required this.sentAt,
//     required this.status,
//     this.failureReason,
//   });
//
//   /// Creates a [SentNotificationModel] from a Firestore document snapshot.
//   factory SentNotificationModel.fromMap(Map<String, dynamic> map) {
//     return SentNotificationModel(
//       id: map['id'] as String,
//       title: map['title'] as String,
//       body: map['body'] as String,
//       target: map['target'] as String,
//       sentAt: (map['sentAt'] as Timestamp).toDate(),
//       status: SentNotificationStatus.values.firstWhere(
//         (e) => e.toString() == map['status'],
//         orElse: () => SentNotificationStatus.failure,
//       ),
//       failureReason: map['failureReason'] as String?,
//     );
//   }
//
//   /// Converts the [SentNotificationModel] to a map for Firestore storage.
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'body': body,
//       'target': target,
//       'sentAt': Timestamp.fromDate(sentAt),
//       'status': status.toString(),
//       'failureReason': failureReason,
//     };
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum to represent the status of a sent notification.
enum SentNotificationStatus {
  success,
  failure,
}

/// Represents the data model for a notification sent from the admin panel.
///
/// This class defines the structure of a notification log object, including its
/// content, target audience, and the status of the send operation. It includes
/// methods for converting to and from a map for Firestore storage.
class SentNotificationModel {
  final String id;
  final String title;
  final String body;
  final String
      target; // e.g., 'all_users', 'pro_offers', or a specific user ID/token
  final DateTime sentAt;
  final SentNotificationStatus status;
  final String? failureReason;
  final String? coverImageUrl; // The image shown in the notification itself.
  final List<String>?
      mediaUrls; // The full list of media for the in-app gallery.

  SentNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.sentAt,
    required this.status,
    this.failureReason,
    this.coverImageUrl,
    this.mediaUrls,
  });

  /// Creates a [SentNotificationModel] from a Firestore document snapshot.
  factory SentNotificationModel.fromMap(Map<String, dynamic> map) {
    return SentNotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      target: map['target'] as String,
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      status: SentNotificationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => SentNotificationStatus.failure,
      ),
      failureReason: map['failureReason'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      // Handles a list of strings from Firestore.
      mediaUrls: (map['mediaUrls'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Converts the [SentNotificationModel] to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'target': target,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status.toString(),
      'failureReason': failureReason,
      'coverImageUrl': coverImageUrl,
      'mediaUrls': mediaUrls,
    };
  }
}
