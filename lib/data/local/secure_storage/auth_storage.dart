import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userDataKey = 'user_data';
  
  // Store auth data
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String email,
    Map<String, dynamic>? userData,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    
    if (userData != null) {
      await _storage.write(
        key: _userDataKey, 
        value: jsonEncode(userData)
      );
    }
  }
  
  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
  
  // Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }
  
  // Get full user data
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userDataKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
  
  // Check if user is logged in
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Clear all auth data (logout)
  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userDataKey);
  }
}

// Provider
final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});