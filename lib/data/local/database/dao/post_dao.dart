import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/post.dart';


part 'post_dao.g.dart';

@DriftAccessor(tables: [Posts])
class PostDao extends DatabaseAccessor<AppDatabase> with _$PostDaoMixin {
  PostDao(super.db);
  
  // Insert post
  Future<void> insertPost(Post post) async {
    await into(posts).insert(
      PostsCompanion(
        id: Value(post.id),
        userId: Value(post.userId),
        content: Value(post.content),
        imageUrl: Value(post.imageUrl),
        createdAt: Value(post.createdAt),
        updatedAt: Value(post.updatedAt),
        isSynced: Value(post.isSynced),
        syncAttempts: Value(post.syncAttempts),
        syncError: Value(post.syncError),
        isDeleted: Value(post.isDeleted),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
  
  // Get all posts
  Future<List<Post>> getAllPosts() async {
    final rows = await select(posts).get();
    return rows.map(_mapToPost).toList();
  }
  
  // Stream all posts (for real-time UI)
  Stream<List<Post>> watchAllPosts() {
    return (select(posts)
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToPost).toList());
  }
  
  // Get posts by user
  Future<List<Post>> getUserPosts(String userId) async {
    final rows = await (select(posts)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
    return rows.map(_mapToPost).toList();
  }
  
  // Stream user posts
  Stream<List<Post>> watchUserPosts(String userId) {
    return (select(posts)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToPost).toList());
  }
  
  // Get pending posts (not synced)
  Future<List<Post>> getPendingPosts() async {
    final rows = await (select(posts)
          ..where((t) => t.isSynced.equals(false) & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
    return rows.map(_mapToPost).toList();
  }
  
  // Mark post as synced
  Future<void> updatePostAfterSync({
    required String localId,
    required String serverId,
  }) async {
    await (update(posts)..where((t) => t.id.equals(localId))).write(
      PostsCompanion(
        id: Value(serverId),
        isSynced: Value(true),
        syncAttempts: Value(0),
        syncError: Value(null),
      ),
    );
  }
  
  // Mark post sync failed
  Future<void> markPostSyncFailed(String id, String error) async {
    await (update(posts)..where((t) => t.id.equals(id))).write(
      PostsCompanion(
        syncAttempts: Value(posts.syncAttempts + 1),
        syncError: Value(error),
      ),
    );
  }
  
  // Mark post as deleted
  Future<void> markPostAsDeleted(String id) async {
    await (update(posts)..where((t) => t.id.equals(id))).write(
      const PostsCompanion(
        isDeleted: Value(true),
        isSynced: Value(false),
      ),
    );
  }
  
  // Permanently delete post
  Future<void> deletePostPermanently(String id) async {
    await (delete(posts)..where((t) => t.id.equals(id))).go();
  }
  
  // Clean up old deleted posts
  Future<void> cleanupOldDeletedPosts() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await (delete(posts)
          ..where((t) => t.isDeleted.equals(true) & t.createdAt.isSmallerThan(cutoff)))
        .go();
  }
  
  // Helper to map database row to Post model
  Post _mapToPost(PostsData row) {
    return Post(
      id: row.id,
      userId: row.userId,
      content: row.content,
      imageUrl: row.imageUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
      syncAttempts: row.syncAttempts,
      syncError: row.syncError,
      isDeleted: row.isDeleted,
    );
  }
}