import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web; // Use a prefix to be extra clear
import 'dart:js_interop';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen.dart';

// This is the main function ONLY for the web.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeTacticBoardDependencies();

  final queryParams = Uri.base.queryParameters;
  final userId = queryParams['userId'] ?? 'default-user-id';

  final collectionId = queryParams['collectionId'];
  final animationId = queryParams['animationId'];

  runApp(
    SizedBox.expand(
      child: ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: TacticboardScreen(
            userId: userId,
            collectionId: collectionId,
            animationId: animationId,
            onFullScreenChanged: (isFullScreen) {
              final message =
                  '{"type": "fullscreen", "isFullScreen": $isFullScreen}';
              web.window.parent?.postMessage(message.toJS, '*'.toJS);
            },
          ),
        ),
      ),
    ),
  );
}
