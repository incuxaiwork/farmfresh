import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/services/api_client.dart';
import 'app_providers.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  bool _mounted = true;

  AuthNotifier(this._ref) : super(AuthState()) {
    _ref.read(apiClientProvider).onAuthFailure = forceLogout;
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void forceLogout() {
    print('[AUTH] forceLogout triggered');
    if (_mounted) {
      state = AuthState();
    }
  }

  Future<void> _loadCurrentUser() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      print('[AUTH] _loadCurrentUser loaded user=${user?.email}');
      if (_mounted) {
        state = AuthState(user: user);
      }
    } catch (e) {
      print('[AUTH] _loadCurrentUser failed error=$e');
      if (_mounted) {
        state = AuthState(errorMessage: _cleanErrorMessage(e));
      }
    }
  }

  Future<bool> login(String email, String password, String role) async {
    if (!_mounted) return false;
    print('[AUTH] login start for $email, role=$role');
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _ref.read(authRepositoryProvider).login(email, password, role);
      print('[AUTH] login success user=${user?.email}, role=${user?.role}');
      if (_mounted) {
        state = AuthState(user: user);
      }
      return true;
    } catch (e) {
      print('[AUTH] login failed error=$e');
      if (_mounted) {
        state = AuthState(errorMessage: _cleanErrorMessage(e));
      }
      return false;
    }
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
    String role,
    String phone, {
    String? farmName,
    String? farmAddress,
    String? governmentId,
    String? bankAccountDetails,
    String? drivingLicenseNumber,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _ref.read(authRepositoryProvider).signup(
            name,
            email,
            password,
            role,
            phone,
            farmName: farmName,
            farmAddress: farmAddress,
            governmentId: governmentId,
            bankAccountDetails: bankAccountDetails,
            drivingLicenseNumber: drivingLicenseNumber,
            vehicleType: vehicleType,
            vehicleNumber: vehicleNumber,
          );
      if (_mounted) {
        state = AuthState(user: user);
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = AuthState(errorMessage: _cleanErrorMessage(e));
      }
      return false;
    }
  }

  Future<void> switchRole(String newRole) async {
    if (!_mounted || state.user == null) return;
    final updatedUser = state.user!.copyWith(role: newRole);
    if (_mounted) {
      state = AuthState(user: updatedUser);
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? avatar}) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final updated = await _ref
          .read(authRepositoryProvider)
          .updateProfile(name: name, phone: phone, avatar: avatar);
      if (_mounted) {
        state = AuthState(user: updated, successMessage: 'Profile updated successfully');
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: _cleanErrorMessage(e));
      }
      return false;
    }
  }

  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      if (_mounted) {
        state = state.copyWith(isLoading: false, successMessage: 'Password changed successfully');
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: _cleanErrorMessage(e));
      }
      return false;
    }
  }

  void clearMessages() {
    if (_mounted) {
      state = state.copyWith(errorMessage: null, successMessage: null);
    }
  }

  Future<void> logout() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(authRepositoryProvider).logout();
      if (_mounted) {
        state = AuthState();
      }
    } catch (e) {
      if (_mounted) {
        state = AuthState(errorMessage: _cleanErrorMessage(e));
      }
    }
  }

  /// Strips the "Exception: " prefix that Flutter adds to thrown exceptions.
  static String _cleanErrorMessage(Object e) {
    final raw = e.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
