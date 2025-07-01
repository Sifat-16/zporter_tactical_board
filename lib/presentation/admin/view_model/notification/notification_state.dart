// lib/presentation/admin/view_model/notification/notification_state.dart

// Enum to represent the status of a notification for a single user.
import 'package:flutter/foundation.dart';

enum SendStatus {
  Pending,
  Sent,
  Failed,
}

// A helper class to pair a user's data with their notification send status.
@immutable
class UserWithStatus {
  final String uid;
  final String email;
  final String fcmToken;
  final SendStatus status;

  const UserWithStatus({
    required this.uid,
    required this.email,
    required this.fcmToken,
    this.status = SendStatus.Pending,
  });

  UserWithStatus copyWith({
    SendStatus? status,
  }) {
    return UserWithStatus(
      uid: uid,
      email: email,
      fcmToken: fcmToken,
      status: status ?? this.status,
    );
  }
}

// The immutable state for our notification screen.
@immutable
class NotificationState {
  final bool isLoadingUsers;
  final bool isSending;
  final List<UserWithStatus> users;
  final String? errorMessage;

  const NotificationState({
    this.isLoadingUsers = false,
    this.isSending = false,
    this.users = const [],
    this.errorMessage,
  });

  NotificationState copyWith({
    bool? isLoadingUsers,
    bool? isSending,
    List<UserWithStatus>? users,
    String? errorMessage,
  }) {
    return NotificationState(
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      isSending: isSending ?? this.isSending,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}
