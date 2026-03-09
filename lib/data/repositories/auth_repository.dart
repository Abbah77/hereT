import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database/dao/user_dao.dart';
import 'package:offline_first_app/data/local/secure_storage/auth_storage.dart';
import 'package:offline_first_app/data/models/user.dart';
import 'package:offline_first_app/services/api/auth_api.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final AuthStorage _authStorage;
  final UserDao _userDao;
  final AuthApi _authApi;
  final Ref _ref;
  
  AuthRepository({
    required AuthStorage authStorage,
    required UserDao userDao,
    required AuthApi authApi,
    required Ref ref,
  })  : _authStorage = authStorage,
        _userDao = userDao,
        _authApi = authApi,
        _ref = ref;
  
  // Register new user
  Future<User> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Call API first
      final response = await _authApi.register(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
      );
      
      final user = User.fromJson(response['user']);
      final token = response['token'];
      
      // Save to secure storage
      await _authStorage.saveAuthData(
        token: token,
        userId: user.id,
        email: user.email,
        userData: user.toJson(),
      );
      
      // Save to local database
      await _userDao.insertUser(user);
      
      return user;
    } catch (e) {
      // If API fails, we don't proceed with registration
      throw Exception('Registration failed: $e');
    }
  }
  
  // Login with email/username and password
  Future<User> login({
    required String login, // Can be email or username
    required String password,
  }) async {
    try {
      // Call API
      final response = await _authApi.login(
        login: login,
        password: password,
      );
      
      final user = User.fromJson(response['user']);
      final token = response['token'];
      
      // Save to secure storage
      await _authStorage.saveAuthData(
        token: token,
        userId: user.id,
        email: user.email,
        userData: user.toJson(),
      );
      
      // Save to local database
      await _userDao.insertUser(user);
      
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // Check if user is logged in (offline first)
  Future<bool> isLoggedIn() async {
    return await _authStorage.hasToken();
  }
  
  // Get current user from local DB
  Future<User?> getCurrentUser() async {
    final userId = await _authStorage.getUserId();
    if (userId == null) return null;
    
    // Try local DB first (offline first)
    final localUser = await _userDao.getUser(userId);
    if (localUser != null) return localUser;
    
    // If not in local DB, try API
    try {
      final token = await _authStorage.getToken();
      if (token == null) return null;
      
      final userData = await _authApi.getCurrentUser(token);
      final user = User.fromJson(userData);
      
      // Save to local DB
      await _userDao.insertUser(user);
      
      return user;
    } catch (e) {
      return null;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _authStorage.clearAuthData();
    // Optionally clear user data from DB
  }
}

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authStorage: ref.watch(authStorageProvider),
    userDao: ref.watch(userDaoProvider),
    authApi: ref.watch(authApiProvider),
    ref: ref,
  );
});