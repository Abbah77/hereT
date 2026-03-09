import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/secure_storage/auth_storage.dart';

class ApiClient {
  final Dio _dio;
  final AuthStorage _authStorage;
  
  ApiClient({required AuthStorage authStorage})
      : _authStorage = authStorage,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://your-api.com/api/v1', // Replace with your API
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token to requests
    final token = await _authStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle token refresh if needed
    if (error.response?.statusCode == 401) {
      // Token expired - try to refresh
      try {
        await _refreshToken();
        // Retry the request
        final response = await _dio.request(
          error.requestOptions.path,
          options: Options(
            method: error.requestOptions.method,
            headers: error.requestOptions.headers,
          ),
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
        );
        handler.resolve(response);
      } catch (e) {
        handler.next(error);
      }
    } else {
      handler.next(error);
    }
  }

  Future<void> _refreshToken() async {
    // Implement token refresh logic
    final refreshToken = await _authStorage.getToken(); // You'd store refresh token separately
    if (refreshToken == null) throw Exception('No refresh token');
    
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    
    final newToken = response.data['token'];
    await _authStorage.saveAuthData(
      token: newToken,
      userId: await _authStorage.getUserId() ?? '',
      email: await _authStorage.getUserEmail() ?? '',
    );
  }

  // HTTP methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Connection timeout');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        case DioExceptionType.connectionError:
          return Exception('No internet connection');
        default:
          if (error.response != null) {
            final message = error.response?.data['message'] ?? 'Unknown error';
            return Exception(message);
          }
          return Exception('Network error');
      }
    }
    return Exception('Unexpected error');
  }
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(authStorage: ref.watch(authStorageProvider));
});