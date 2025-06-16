class AuthState {
  final String? userId;

  AuthState({this.userId});

  AuthState copyWith({String? userId}) {
    return AuthState(userId: userId ?? this.userId);
  }
}
