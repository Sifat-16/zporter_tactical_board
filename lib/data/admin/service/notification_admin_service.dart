import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// A service to handle sending notifications via the FCM v1 HTTP API using a service account.
class NotificationAdminService {
  // The project ID from your service account JSON file.
  // You can find it in the file, or it's the same as in your firebase.json.
  static const String _projectId = 'zporter-board-dev';

  // This will hold the authenticated HTTP client.
  http.Client? _authClient;

  // Scopes required for FCM.
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  /// Gets an authenticated HTTP client using the service account credentials.
  Future<http.Client> _getAuthClient() async {
    if (_authClient != null) return _authClient!;

    // Load the service account JSON from assets.
    final jsonString =
        await rootBundle.loadString('assets/secure/fcm_service_account.json');
    final credentials =
        ServiceAccountCredentials.fromJson(json.decode(jsonString));

    // Get the authenticated client.
    final client = await clientViaServiceAccount(credentials, _scopes);
    _authClient = client;
    return client;
  }

  /// Sends a notification to a specific target (topic or device token).
  Future<({bool success, String? error})> sendNotification({
    required String title,
    required String body,
    required String target,
  }) async {
    try {
      final client = await _getAuthClient();
      final Uri url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');

      final Map<String, String> messageTarget;
      if (!target.contains(':') && !target.contains(' ')) {
        messageTarget = {'topic': target};
      } else {
        messageTarget = {'token': target};
      }

      print("Here comes the target ${target} - ${messageTarget}");

      final bodyPayload = {
        'message': {
          ...messageTarget,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        }
      };

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyPayload),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully: ${response.body}');
        return (success: true, error: null);
      } else {
        final errorBody =
            'Failed to send notification. Status: ${response.statusCode}. Body: ${response.body}';
        debugPrint(errorBody);
        return (success: false, error: errorBody);
      }
    } catch (e) {
      final errorBody = 'Error sending notification: $e';
      debugPrint(errorBody);
      return (success: false, error: errorBody);
    }
  }
}
