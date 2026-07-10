import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password, String role);
  Future<UserModel> signup(String name, String email, String password, String role, String phone);
  Future<void> logout();
}

class PostgresAuthRepository implements AuthRepository {
  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final profile = data['data'];
          return UserModel(
            id: profile['id'],
            name: profile['name'],
            email: profile['email'],
            role: profile['role'],
          );
        }
      }
    } catch (e) {
      // Offline fallback / Connection issue
    }
    return null;
  }

  @override
  Future<UserModel> login(String email, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = json.decode(res.body);
      if (res.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['data']['accessToken']);
      await prefs.setString('refresh_token', data['data']['refreshToken']);

      final profile = data['data']['user'];
      return UserModel(
        id: profile['id'],
        name: profile['name'],
        email: profile['email'],
        role: role, // Persist matching client viewpoint role
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please ensure the backend server is running.');
    }
  }

  @override
  Future<UserModel> signup(String name, String email, String password, String role, String phone) async {
    try {
      final parts = name.split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Doe';

      final endpoint = role.toLowerCase() == 'farmer' 
          ? '${AppConstants.apiBaseUrl}/auth/register/farmer'
          : (role.toLowerCase() == 'delivery partner'
              ? '${AppConstants.apiBaseUrl}/auth/register/delivery'
              : '${AppConstants.apiBaseUrl}/auth/register/customer');

      final body = role.toLowerCase() == 'farmer'
          ? {
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
              'farmName': 'My Farm',
              'farmAddress': 'Orchard Road',
              'governmentId': 'ID-1234',
              'bankAccountDetails': 'Bank Routing-1234',
            }
          : (role.toLowerCase() == 'delivery partner'
              ? {
                  'firstName': firstName,
                  'lastName': lastName,
                  'email': email,
                  'phone': phone,
                  'password': password,
                  'drivingLicenseNumber': 'DL-123',
                  'vehicleType': 'Two-Wheeler',
                  'vehicleNumber': 'VN-123',
                }
              : {
                  'firstName': firstName,
                  'lastName': lastName,
                  'email': email,
                  'phone': phone,
                  'password': password,
                  'confirmPassword': password,
                });

      final res = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 5));

      final data = json.decode(res.body);
      if (res.statusCode != 201) {
        throw Exception(data['message'] ?? 'Signup failed');
      }

      // Automatically login on signup success
      return login(email, password, role);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please ensure the backend server is running.');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    final accessToken = prefs.getString('access_token');
    
    if (accessToken != null && refreshToken != null) {
      try {
        await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'refreshToken': refreshToken,
          }),
        ).timeout(const Duration(seconds: 3));
      } catch (e) {
        // Safe fail-silent during logouts
      }
    }

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
