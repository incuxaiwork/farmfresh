import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Centralized Dio-based HTTP client with automatic JWT token refresh.
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isRefreshing = false;
  final List<Function(String)> _pendingRequests = [];
  void Function()? onAuthFailure;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(this));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;

  /// Attaches the current access token to a request.
  Future<void> _attachToken(RequestOptions options) async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Attempts to refresh the JWT access token using the stored refresh token.
  /// Returns the new access token on success, or null on failure.
  Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) {
      return null;
    }
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        onAuthFailure?.call();
        return null;
      }

      final response = await Dio().post(
        '${AppConstants.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _secureStorage.write(key: 'access_token', value: newAccessToken);
        }
        if (newRefreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);
        }
        return newAccessToken;
      }
    } catch (_) {
      // Refresh failed — clear tokens and trigger auth failure callback
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      onAuthFailure?.call();
    } finally {
      _isRefreshing = false;
    }
    return null;
  }

  /// Clears all pending requests (called on logout or fatal auth failure).
  void clearPendingRequests() {
    _pendingRequests.clear();
  }
}

/// Dio interceptor that automatically attaches JWT tokens and handles 401 refresh.
class _AuthInterceptor extends Interceptor {
  final ApiClient _client;

  _AuthInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await _client._attachToken(options);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final newToken = await _client._refreshAccessToken();

      if (newToken != null) {
        // Retry the original request with the new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _client._dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          // Retry failed even with new token
        }
      } else {
        _client.onAuthFailure?.call();
      }
    }
    handler.next(err);
  }
}

/// Riverpod provider for the singleton ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  return client;
});
