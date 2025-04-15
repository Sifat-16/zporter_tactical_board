import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/presentation/auth/view_model/auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState());

  void initiateUser(String userId) {
    state = state.copyWith(userId: userId);
  }
}
