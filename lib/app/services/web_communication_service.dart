import 'dart:convert';
import 'dart:js_interop';
import 'package:logger/logger.dart';
import 'package:web/web.dart' as web;
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// Message types for communication between Flutter widget and parent web app
enum MessageType {
  WIDGET_READY,
  LOAD_DATA,
  SAVE_DATA,
  ERROR,
  CLOSE,
}

/// Service for handling postMessage communication with parent window
/// Used in web widget mode to communicate with the web app
class WebCommunicationService {
  static final WebCommunicationService _instance =
      WebCommunicationService._internal();

  factory WebCommunicationService() => _instance;

  WebCommunicationService._internal();

  /// Callback for handling messages from parent
  Function(Map<String, dynamic>)? _onMessageReceived;

  /// Check if running in widget mode (embedded in iframe)
  bool get isWidgetMode {
    try {
      return web.window.parent != web.window;
    } catch (e) {
      return false;
    }
  }

  /// Initialize message listener
  void initialize({
    required Function(Map<String, dynamic>) onMessageReceived,
  }) {
    _onMessageReceived = onMessageReceived;

    // Add event listener for messages from parent
    web.window.addEventListener(
      'message',
      ((web.Event event) {
        try {
          final messageEvent = event as web.MessageEvent;
          final data = messageEvent.data;

          // Parse JSON message
          if (data != null) {
            final String jsonString = data.toString();
            final Map<String, dynamic> message = jsonDecode(jsonString);

            zlog(
              data:
                  '[WebComm] Received message from parent: ${message['type']}',
            );

            _onMessageReceived?.call(message);
          }
        } catch (e) {
          zlog(
            data: '[WebComm] Error parsing message from parent: $e',
            level: Level.error,
          );
        }
      }).toJS,
    );

    zlog(data: '[WebComm] Message listener initialized');
  }

  /// Send WIDGET_READY message to parent
  void sendWidgetReady() {
    _sendMessage({
      'type': MessageType.WIDGET_READY.name,
    });
  }

  /// Send SAVE_DATA message with animation data and thumbnail
  void sendSaveData({
    required Map<String, dynamic> animationData,
    required String thumbnail,
  }) {
    _sendMessage({
      'type': MessageType.SAVE_DATA.name,
      'payload': {
        'animationData': animationData,
        'thumbnail': thumbnail,
      },
    });
  }

  /// Send ERROR message to parent
  void sendError({
    required String message,
    String? code,
  }) {
    _sendMessage({
      'type': MessageType.ERROR.name,
      'payload': {
        'message': message,
        if (code != null) 'code': code,
      },
    });
  }

  /// Send CLOSE message to parent
  void sendClose() {
    _sendMessage({
      'type': MessageType.CLOSE.name,
    });
  }

  /// Internal method to send message to parent window
  void _sendMessage(Map<String, dynamic> message) {
    try {
      if (!isWidgetMode) {
        zlog(
          data: '[WebComm] Not in widget mode, skipping message send',
          level: Level.warning,
        );
        return;
      }

      final String jsonMessage = jsonEncode(message);
      web.window.parent?.postMessage(jsonMessage.toJS, '*'.toJS);

      zlog(
        data: '[WebComm] Sent message to parent: ${message['type']}',
      );
    } catch (e) {
      zlog(
        data: '[WebComm] Error sending message to parent: $e',
        level: Level.error,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _onMessageReceived = null;
  }
}
