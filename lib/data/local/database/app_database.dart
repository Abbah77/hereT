import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// IMPORT TABLES
import 'tables/users.dart';
import 'tables/posts.dart';

// IMPORT DAOS
import 'dao/user_dao.dart';
import 'dao/post_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, Posts],
  daos: [UserDao, PostDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here if needed
      },
    );
  }
  
  // Close database
  Future<void> close() async {
    await customSelect('VACUUM').get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// Providers
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final userDaoProvider = Provider<UserDao>((ref) {
  return ref.watch(appDatabaseProvider).userDao;
});

final postDaoProvider = Provider<PostDao>((ref) {
  return ref.watch(appDatabaseProvider).postDao;
});