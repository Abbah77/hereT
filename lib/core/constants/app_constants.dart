class AppConstants {
  // API
  static const String apiBaseUrl = 'https://your-api.com/api/v1';
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  
  // Database
  static const String databaseName = 'app_database.sqlite';
  static const int databaseVersion = 1;
  
  // Pagination
  static const int postsPerPage = 20;
  
  // Sync
  static const int maxSyncAttempts = 5;
  static const Duration syncRetryDelay = Duration(minutes: 5);
  static const Duration backgroundSyncInterval = Duration(minutes: 15);
  
  // Storage Keys
  static const String themeModeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxPostLength = 500;
  
  // Regex
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String usernameRegex = r'^[a-zA-Z0-9_]{3,20}$';
}

class AppMessages {
  // Success
  static const String postCreated = 'Post created successfully';
  static const String postDeleted = 'Post deleted successfully';
  static const String postUpdated = 'Post updated successfully';
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logged out successfully';
  
  // Errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorized = 'Session expired. Please login again.';
  static const String invalidCredentials = 'Invalid email/username or password';
  static const String emailInUse = 'Email already in use';
  static const String usernameTaken = 'Username already taken';
  static const String weakPassword = 'Password is too weak';
  static const String postTooLong = 'Post exceeds maximum length';
  
  // Offline
  static const String offlinePostSaved = 'Post saved locally. Will sync when online.';
  static const String offlineDeleteSaved = 'Delete will sync when online.';
  static const String offlineMode = 'You are in offline mode';
  static const String syncComplete = 'Sync complete';
  static const String syncPending = 'Syncing...';
}