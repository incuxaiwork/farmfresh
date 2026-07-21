import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Centralized Dio-based HTTP client with automatic JWT token refresh.
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  bool _isRefreshing = false;
  final List<Function(String)> _pendingRequests = [];
  void Function()? onAuthFailure;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
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
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  Dio get dio => _dio;
  String get baseUrl => AppConstants.apiBaseUrl;

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

      // Use a fresh Dio instance (no interceptors) to avoid infinite refresh loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
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
        print('[AUTH] Token refresh succeeded');
        return newAccessToken;
      }
    } catch (e) {
      print('[AUTH] Token refresh failed: $e');
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
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final errorType = err.type.name;

    print('[API] Error: $errorType | status=$statusCode | path=$path | message=${err.message}');

    if (statusCode == 401) {
      final newToken = await _client._refreshAccessToken();

      if (newToken != null) {
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

/// Classifies [DioException] types into human-readable messages.
String classifyDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Request timed out. The server may be slow or unreachable.';
    case DioExceptionType.connectionError:
      final host = e.requestOptions.uri.host;
      final port = e.requestOptions.uri.port;
      return 'Cannot connect to $host:$port. '
          'Please ensure the backend server is running.';
    case DioExceptionType.badCertificate:
      return 'SSL certificate error. Check your network security config.';
    case DioExceptionType.badResponse:
      return _classifyHttpStatus(e.response?.statusCode);
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.unknown:
      if (e.message?.contains('XMLHttpRequest') ?? false) {
        final host = e.requestOptions.uri.host;
        final port = e.requestOptions.uri.port;
        return 'Network error connecting to $host:$port. '
            'Please ensure the backend server is running and '
            'accessible from this device.';
      }
      return 'An unexpected network error occurred: ${e.message}';
  }
}

String _classifyHttpStatus(int? code) {
  switch (code) {
    case 400:
      return 'Bad request. Please check your input.';
    case 401:
      return 'Invalid credentials. Please check your email and password.';
    case 403:
      return 'You do not have permission to perform this action.';
    case 404:
      return 'The requested resource was not found.';
    case 409:
      return 'A conflict occurred. The resource may already exist.';
    case 422:
      return 'Validation error. Please check your input.';
    case 429:
      return 'Too many requests. Please wait and try again.';
    case 500:
      return 'Internal server error. Please try again later.';
    case 502:
      return 'Bad gateway. The backend server may be restarting.';
    case 503:
      return 'Service unavailable. The backend server may be down.';
    default:
      return 'Server returned an error (HTTP $code).';
  }
}

/// Riverpod provider for the singleton ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  return client;
});
