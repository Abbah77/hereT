import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/themes/app_theme.dart';
import 'package:offline_first_app/data/local/database/app_database.dart';
import 'package:offline_first_app/data/local/secure_storage/auth_storage.dart';
import 'package:offline_first_app/data/repositories/auth_repository.dart';
import 'package:offline_first_app/services/background/sync_service.dart';
import 'package:offline_first_app/ui/navigation/app_router.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background sync
  await SyncService.initialize();
  
  // Initialize database
  final database = AppDatabase();
  
  // Check if user is logged in
  final authStorage = AuthStorage();
  final hasToken = await authStorage.hasToken();
  
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: MyApp(isLoggedIn: hasToken),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Offline First App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router(isLoggedIn),
      debugShowCheckedModeBanner: false,
    );
  }
}