import 'dart:js_interop' show createJSInteropWrapper;
import 'dart:html' as html;
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/app/services/js_interop/js_interop.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen.dart';

// This is the main function for the web using element embedding.
// Following the ng-flutter pattern from Flutter samples.
// https://github.com/flutter/samples/tree/main/web_embedding/ng-flutter
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  html.window.console
      .log('[main_web] Initializing Flutter Tactical Board Widget');

  // Read configuration from host element data attributes (element embedding pattern)
  // The parent React app sets these on the container element
  final hostElement = _findHostElement();

  String userId;
  String? collectionId;
  String? animationId;
  String? tacticalBoardId;
  String? exerciseName;
  String? existingThumbnailUrl;
  bool isPlayerMode;

  if (hostElement != null) {
    // Element embedding mode - read from data attributes
    userId = hostElement.dataset['userId'] ?? 'default-user-id';
    collectionId = hostElement.dataset['collectionId'];
    animationId = hostElement.dataset['animationId'];
    tacticalBoardId = _getNonEmptyValue(hostElement.dataset['tacticalBoardId']);
    exerciseName = _getNonEmptyValue(hostElement.dataset['exerciseName']);
    existingThumbnailUrl =
        _getNonEmptyValue(hostElement.dataset['existingThumbnailUrl']);
    isPlayerMode = hostElement.dataset['isPlayerMode'] == 'true';

    html.window.console.log(
        '[main_web] Host element data attributes - userId: $userId, collectionId: $collectionId, animationId: $animationId, tacticalBoardId: $tacticalBoardId, exerciseName: $exerciseName, existingThumbnailUrl: $existingThumbnailUrl, isPlayerMode: $isPlayerMode');
  } else {
    // Fallback to URL query params (standalone mode)
    final queryParams = Uri.base.queryParameters;
    userId = queryParams['userId'] ?? 'default-user-id';
    collectionId = queryParams['collectionId'];
    animationId = queryParams['animationId'];
    tacticalBoardId = queryParams['tacticalBoardId'];
    exerciseName = queryParams['exerciseName'];
    existingThumbnailUrl = queryParams['existingThumbnailUrl'];
    isPlayerMode = queryParams['isPlayerMode'] == 'true';

    html.window.console.log(
        '[main_web] URL query params - userId: $userId, collectionId: $collectionId, animationId: $animationId, tacticalBoardId: $tacticalBoardId, exerciseName: $exerciseName, existingThumbnailUrl: $existingThumbnailUrl, isPlayerMode: $isPlayerMode');
  }

  // Initialize Firebase and dependencies (works fine in element embedding)
  html.window.console.log('[main_web] Initializing Firebase dependencies');
  await initializeTacticBoardDependencies();

  // Run the app
  runApp(
    MyApp(
      userId: userId,
      collectionId: collectionId,
      animationId: animationId,
      tacticalBoardId: tacticalBoardId,
      exerciseName: exerciseName,
      existingThumbnailUrl: existingThumbnailUrl,
      isPlayerMode: isPlayerMode,
    ),
  );
}

/// Find the Flutter host element by looking for the flt-renderer element's parent
html.Element? _findHostElement() {
  // In element embedding, Flutter renders inside a host element
  // The host element has our data attributes
  try {
    // Look for the element with data-user-id attribute (our React container)
    final elementsWithData = html.document.querySelectorAll('[data-user-id]');
    if (elementsWithData.isNotEmpty) {
      return elementsWithData.first;
    }

    // Fallback: look for flt-renderer and get its parent
    final flutterElement = html.document.querySelector('flt-renderer');
    if (flutterElement != null && flutterElement.parent != null) {
      return flutterElement.parent as html.Element;
    }
  } catch (e) {
    html.window.console.log('[main_web] Error finding host element: $e');
  }
  return null;
}

/// Returns null for empty strings (treats empty string as null)
String? _getNonEmptyValue(String? value) {
  if (value == null || value.isEmpty) return null;
  return value;
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.userId,
    this.collectionId,
    this.animationId,
    this.tacticalBoardId,
    this.exerciseName,
    this.existingThumbnailUrl,
    this.isPlayerMode = false,
  });

  final String userId;
  final String? collectionId;
  final String? animationId;
  final String? tacticalBoardId;
  final String? exerciseName;
  final String? existingThumbnailUrl;
  final bool isPlayerMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State that will be exposed to JavaScript
  final ValueNotifier<Map<String, dynamic>?> _animationData =
      ValueNotifier<Map<String, dynamic>?>(null);
  final ValueNotifier<String?> _thumbnail = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isDirty = ValueNotifier<bool>(false);

  late final TacticalBoardStateManager _stateManager =
      TacticalBoardStateManager(
    animationData: _animationData,
    thumbnail: _thumbnail,
    isDirty: _isDirty,
  );

  @override
  void initState() {
    super.initState();

    // Export the state manager to JavaScript
    final export = createJSInteropWrapper(_stateManager);

    // Broadcast the initialization event through the Flutter root element
    // The parent app will listen for this event and get the state manager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      broadcastAppEvent('tactical-board-initialized', export);
      zlog(data: '[main_web] State manager exported to JavaScript');
    });
  }

  @override
  void dispose() {
    _animationData.dispose();
    _thumbnail.dispose();
    _isDirty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return SizedBox.expand(
      child: ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return botToastBuilder(context, child);
          },
          navigatorObservers: [BotToastNavigatorObserver()],
          home: TacticboardScreen(
            userId: widget.userId,
            collectionId: widget.collectionId,
            animationId: widget.animationId,
            tacticalBoardId: widget.tacticalBoardId,
            exerciseName: widget.exerciseName,
            existingThumbnailUrl: widget.existingThumbnailUrl,
            isPlayerMode: widget.isPlayerMode,
            stateManager: _stateManager,
          ),
        ),
      ),
    );
  }
}
