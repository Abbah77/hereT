import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/user.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);
  
  // Insert user
  Future<void> insertUser(User user) async {
    await into(users).insert(
      UsersCompanion(
        id: Value(user.id),
        fullName: Value(user.fullName),
        email: Value(user.email),
        username: Value(user.username),
        profilePicture: Value(user.profilePicture),
        createdAt: Value(user.createdAt),
        updatedAt: Value(user.updatedAt),
        isSynced: Value(user.isSynced),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
  
  // Get user by ID
  Future<User?> getUser(String id) async {
    final row = await (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    
    return User(
      id: row.id,
      fullName: row.fullName,
      email: row.email,
      username: row.username,
      profilePicture: row.profilePicture,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }
  
  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final row = await (select(users)..where((t) => t.email.equals(email))).getSingleOrNull();
    if (row == null) return null;
    
    return User(
      id: row.id,
      fullName: row.fullName,
      email: row.email,
      username: row.username,
      profilePicture: row.profilePicture,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }
  
  // Update user
  Future<void> updateUser(User user) async {
    await (update(users)..where((t) => t.id.equals(user.id))).write(
      UsersCompanion(
        fullName: Value(user.fullName),
        email: Value(user.email),
        username: Value(user.username),
        profilePicture: Value(user.profilePicture),
        updatedAt: Value(DateTime.now()),
        isSynced: Value(user.isSynced),
      ),
    );
  }
  
  // Delete user
  Future<void> deleteUser(String id) async {
    await (delete(users)..where((t) => t.id.equals(id))).go();
  }
  
  // Stream of user by ID
  Stream<User?> watchUser(String id) {
    return (select(users)..where((t) => t.id.equals(id))).watchSingleOrNull().map((row) {
      if (row == null) return null;
      return User(
        id: row.id,
        fullName: row.fullName,
        email: row.email,
        username: row.username,
        profilePicture: row.profilePicture,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        isSynced: row.isSynced,
      );
    });
  }
}