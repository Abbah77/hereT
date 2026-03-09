import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/services/api/api_client.dart';

class AuthApi {
  final ApiClient _apiClient;
  
  AuthApi({required ApiClient apiClient}) : _apiClient = apiClient;
  
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'username': username,
        'password': password,
      },
    );
    return response.data;
  }
  
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'login': login, // Can be email or username
        'password': password,
      },
    );
    return response.data;
  }
  
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await _apiClient.get('/auth/me');
    return response.data;
  }
  
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
  
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return response.data;
  }
}

// Provider
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(apiClient: ref.watch(apiClientProvider));
});