import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database/app_database.dart';
import 'package:offline_first_app/data/local/secure_storage/auth_storage.dart';
import 'package:offline_first_app/data/repositories/auth_repository.dart';
import 'package:offline_first_app/data/repositories/post_repository.dart';
import 'package:offline_first_app/services/api/api_client.dart';
import 'package:offline_first_app/services/api/auth_api.dart';
import 'package:offline_first_app/services/api/post_api.dart';
import 'package:offline_first_app/core/utils/connectivity_service.dart';

// Database providers
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final userDaoProvider = Provider((ref) => ref.watch(appDatabaseProvider).userDao);
final postDaoProvider = Provider((ref) => ref.watch(appDatabaseProvider).postDao);

// Storage providers
final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

// Service providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// API providers
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(authStorage: ref.watch(authStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(apiClient: ref.watch(apiClientProvider));
});

final postApiProvider = Provider<PostApi>((ref) {
  return PostApi(apiClient: ref.watch(apiClientProvider));
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authStorage: ref.watch(authStorageProvider),
    userDao: ref.watch(userDaoProvider),
    authApi: ref.watch(authApiProvider),
    ref: ref,
  );
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    postDao: ref.watch(postDaoProvider),
    postApi: ref.watch(postApiProvider),
    authStorage: ref.watch(authStorageProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    ref: ref,
  );
});

// ViewModel providers (for future expansion)
final homeViewModelProvider = Provider((ref) {
  return HomeViewModel(ref: ref);
});

final profileViewModelProvider = Provider((ref) {
  return ProfileViewModel(ref: ref);
});

// Simple ViewModels
class HomeViewModel {
  final Ref ref;
  HomeViewModel({required this.ref});
  
  void refreshPosts() {
    // Implementation
  }
}

class ProfileViewModel {
  final Ref ref;
  ProfileViewModel({required this.ref});
  
  void updateProfile() {
    // Implementation
  }
}