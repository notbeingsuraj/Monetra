import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../storage/storage_service.dart';

class ApiClient {
  ApiClient._();

  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio _dio;
  late final Dio _tokenDio; // Separate instance to avoid interceptor loops
  bool _isRefreshing = false;
  Future<void>? _refreshTask;

  void initialize() {
    final options = BaseOptions(
      baseUrl: kDebugMode ? AppConstants.baseUrlDev : AppConstants.baseUrlProd,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    _dio = Dio(options);
    _tokenDio = Dio(options); // Base instance for refresh without interceptors

    // Auth token injection interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && error.requestOptions.path != '/auth/login') {
            final refreshToken = await StorageService.instance.getRefreshToken();
            if (refreshToken == null) {
              await StorageService.instance.clearAll();
              return handler.next(error);
            }

            if (!_isRefreshing) {
              _isRefreshing = true;
              _refreshTask = _refreshToken(refreshToken).then((success) async {
                _isRefreshing = false;
                if (!success) {
                  await StorageService.instance.clearAll();
                }
              }).catchError((e) {
                _isRefreshing = false;
                StorageService.instance.clearAll();
              });
            }

            // Wait for refresh to complete
            await _refreshTask;

            // Retry original request if we successfully got a new token
            final newToken = await StorageService.instance.getToken();
            if (newToken != null) {
              try {
                // Update header
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                // Clone the request and replay it via the base _dio instance
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(e as DioException);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Debug logging — NEVER log request bodies (may contain passwords or tokens)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false, // Security: never log request bodies
          responseBody: false, // Only log routes and status codes
          requestHeader: false,
          responseHeader: false,
          logPrint: (o) => debugPrint('[API] $o'),
        ),
      );
    }
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final response = await _tokenDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];
        
        await StorageService.instance.setToken(newToken);
        await StorageService.instance.setRefreshToken(newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Parse clean user-facing error from a Dio exception.
  static String parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please check your connection.';
        case DioExceptionType.connectionError:
          return 'Unable to connect. Check your internet connection.';
        default:
          if (e.response?.statusCode == 401) return 'Invalid credentials.';
          if (e.response?.statusCode == 404) return 'Resource not found.';
          if (e.response?.statusCode == 500) return 'Server error. Please try again.';
          return 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return fromJson != null ? fromJson(response.data!) : response.data as T;
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    return fromJson != null ? fromJson(response.data!) : response.data as T;
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
    return fromJson != null ? fromJson(response.data!) : response.data as T;
  }

  Future<void> delete(String path) async {
    await _dio.delete(path);
  }
}
