import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthState {
  final bool isLoading;
  final String? token;
  final int? userId;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.token,
    this.userId,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? token,
    int? userId,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  Future<void> signup(String email, String password) async {
  try {
    state = state.copyWith(isLoading: true, error: null);

    final res = await AuthApi.signup(email, password);

    final token = res["access_token"];

    /// SAVE TOKEN
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);

    state = state.copyWith(
      isLoading: false,
      token: token,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}

Future<void> login(String email, String password) async {
  try {
    state = state.copyWith(isLoading: true, error: null);

    final res = await AuthApi.login(email, password);

    final token = res["access_token"];

    /// SAVE TOKEN
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);

    state = state.copyWith(
      isLoading: false,
      token: token,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}

  void logout() {
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});