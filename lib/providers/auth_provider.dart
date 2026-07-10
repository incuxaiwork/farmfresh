import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  Future<bool> login(String email, String password, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).login(email, password, role);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String role, String phone) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).signup(name, email, password, role, phone);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> switchRole(String newRole) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(role: newRole);
      state = AuthState(user: updatedUser);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(authRepositoryProvider).logout();
      state = AuthState();
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
