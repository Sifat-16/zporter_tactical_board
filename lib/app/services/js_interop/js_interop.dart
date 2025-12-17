/// JS Interop services for Flutter web embedding
///
/// This module provides the necessary classes and functions to enable
/// JavaScript interoperability when the Flutter app is embedded in a
/// parent web application (React, Angular, etc.)
///
/// Based on the ng-flutter example from Flutter samples:
/// https://github.com/flutter/samples/tree/main/web_embedding/ng-flutter
///
/// This library uses conditional exports to provide web-specific implementations
/// on web platforms and stub implementations on mobile/desktop platforms.
library;

// Export web implementations for web, stub implementations for mobile/desktop
export 'tactical_board_state_manager_web.dart'
    if (dart.library.io) 'tactical_board_state_manager_stub.dart';
export 'helper_web.dart' if (dart.library.io) 'helper_stub.dart'
    show broadcastAppEvent;
