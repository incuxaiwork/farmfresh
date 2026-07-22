import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../core/services/api_client.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password, String role);
  Future<UserModel> signup(
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
  });
  Future<UserModel> updateProfile({String? name, String? phone, String? avatar});
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<void> logout();
  Future<void> refreshToken();
}

class PostgresAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  PostgresAuthRepository(this._apiClient);

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final res = await _apiClient.dio.get('/auth/profile');

      if (res.statusCode == 200 && res.data['success'] == true) {
        final profile = res.data['data'];
        return UserModel.fromJson(profile as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserModel> login(String email, String password, String role) async {
    try {
      final res = await _apiClient.dio.post('/auth/login', data: {
        'username': email,
        'password': password,
        'role': role,
      });

      final data = res.data;
      if (res.statusCode != 200) {
        throw Exception((data is Map ? data['message'] : null) ?? 'Login failed');
      }

      final profile = data['data']['user'];
      final userRoleStr = (profile['role'] as String? ?? '').toUpperCase();
      final selectedRoleUpper = role.trim().toUpperCase();

      bool roleMatches = false;
      if (selectedRoleUpper.contains('CUSTOMER') && userRoleStr == 'CUSTOMER') roleMatches = true;
      else if (selectedRoleUpper.contains('FARMER') && userRoleStr == 'FARMER') roleMatches = true;
      else if (selectedRoleUpper.contains('DELIVERY') && (userRoleStr == 'DELIVERY' || userRoleStr == 'DELIVERY_PARTNER')) roleMatches = true;

      if (!roleMatches) {
        final prettyActualRole = userRoleStr == 'FARMER'
            ? 'Farmer Partner'
            : (userRoleStr == 'DELIVERY_PARTNER' || userRoleStr == 'DELIVERY' ? 'Delivery Partner' : 'Customer Marketplace');
        throw Exception(
          'Access denied. Account \'${profile['email']}\' is registered as a $prettyActualRole. Please select \'$prettyActualRole\' from the portal role dropdown.',
        );
      }

      await _secureStorage.write(key: 'access_token', value: data['data']['accessToken']);
      await _secureStorage.write(key: 'refresh_token', value: data['data']['refreshToken']);

      return UserModel(
        id: profile['id'],
        name: profile['name'],
        email: profile['email'],
        role: profile['role'] ?? role,
        phone: profile['phone'] as String?,
        avatar: profile['avatar'] as String?,
      );
    } on DioException catch (e) {
      final message = (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message;
      throw Exception(message ?? 'Connection failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please ensure the backend server is running.');
    }
  }

  @override
  Future<UserModel> signup(
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
    try {
      final parts = name.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : name;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;

      String endpoint;
      Map<String, dynamic> body;

      final roleLower = role.toLowerCase();
      if (roleLower.contains('farmer')) {
        endpoint = '/auth/register/farmer';
        body = {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'farmName': (farmName != null && farmName.isNotEmpty) ? farmName : '$name\'s Organic Farm',
          'farmAddress': (farmAddress != null && farmAddress.isNotEmpty) ? farmAddress : 'Local Verifying Zone',
          'governmentId': (governmentId != null && governmentId.isNotEmpty) ? governmentId : 'GOV-VERIFIED-8892',
          'bankAccountDetails': (bankAccountDetails != null && bankAccountDetails.isNotEmpty) ? bankAccountDetails : 'HDFC Bank Payout Account',
        };
      } else if (roleLower.contains('delivery')) {
        endpoint = '/auth/register/delivery';
        body = {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'drivingLicenseNumber': (drivingLicenseNumber != null && drivingLicenseNumber.isNotEmpty) ? drivingLicenseNumber : 'DL-2026-FF889',
          'vehicleType': (vehicleType != null && vehicleType.isNotEmpty) ? vehicleType : 'Two-Wheeler',
          'vehicleNumber': (vehicleNumber != null && vehicleNumber.isNotEmpty) ? vehicleNumber : 'AP-07-FF-1001',
        };
      } else {
        endpoint = '/auth/register/customer';
        body = {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'confirmPassword': password,
        };
      }

      final res = await _apiClient.dio.post(endpoint, data: body);

      if (res.statusCode != 201) {
        throw Exception((res.data is Map ? res.data['message'] : null) ?? 'Signup failed');
      }

      return login(email, password, role);
    } on DioException catch (e) {
      final message = (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message;
      throw Exception(message ?? 'Connection failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please ensure the backend server is running.');
    }
  }

  @override
  Future<UserModel> updateProfile({String? name, String? phone, String? avatar}) async {
    try {
      final res = await _apiClient.dio.patch('/auth/profile', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        'avatar': avatar ?? '',
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final profile = res.data['data'];
        return UserModel.fromJson(profile as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      final message = (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message;
      throw Exception(message ?? 'Connection failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed');
    }
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final res = await _apiClient.dio.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if ((res.statusCode != 200 && res.statusCode != 201) || res.data['success'] != true) {
        throw Exception((res.data is Map ? res.data['message'] : null) ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message;
      throw Exception(message ?? 'Connection failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed');
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    if (refreshToken != null) {
      try {
        await _apiClient.dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {}
    }

    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    _apiClient.clearPendingRequests();
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return;

    try {
      final res = await _apiClient.dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        if (data['accessToken'] != null) {
          await _secureStorage.write(key: 'access_token', value: data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _secureStorage.write(key: 'refresh_token', value: data['refreshToken']);
        }
      }
    } catch (_) {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
    }
  }
}