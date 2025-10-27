import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/responsive_screen_component.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/app/services/user_preferences_service.dart';
import 'package:zporter_tactical_board/presentation/auth/view_model/auth_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/responsive/tacticboard_screen_tablet.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class TacticboardScreen extends ResponsiveScreen {
  const TacticboardScreen({
    super.key,
    required this.userId,
    this.onFullScreenChanged,
    this.collectionId,
    this.animationId,
  });

  final String userId;
  final ValueChanged<bool>? onFullScreenChanged;
  final String? collectionId;
  final String? animationId;

  @override
  Widget buildDesktop(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final bp = ref.watch(boardProvider);
        WidgetsBinding.instance.addPostFrameCallback((t) {
          onFullScreenChanged?.call(bp.showFullScreen);
        });
        return TacticboardScreenTablet(
          userId: userId,
          collectionId: collectionId,
          animationId: animationId,
        );
      },
    );
  }

  @override
  Widget buildMobile(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final bp = ref.watch(boardProvider);
        WidgetsBinding.instance.addPostFrameCallback((t) {
          onFullScreenChanged?.call(bp.showFullScreen);
        });
        return TacticboardScreenTablet(
          userId: userId,
          collectionId: collectionId,
          animationId: animationId,
        );
      },
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final bp = ref.watch(boardProvider);
        WidgetsBinding.instance.addPostFrameCallback((t) {
          onFullScreenChanged?.call(bp.showFullScreen);
        });
        return TacticboardScreenTablet(
          userId: userId,
          collectionId: collectionId,
          animationId: animationId,
        );
      },
    );
  }

  @override
  _TacticboardScreenState createState() => _TacticboardScreenState();
}

class _TacticboardScreenState extends ResponsiveScreenState<TacticboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((t) {
      // Set the userId in UserPreferencesService for Firestore sync
      final prefsService = sl.get<UserPreferencesService>();
      prefsService.setUserId(widget.userId);

      // Initialize user authentication
      ref.read(authProvider.notifier).initiateUser(widget.userId);
    });
    _loadTacticalBoard();
  }

  _loadTacticalBoard() {}
}
