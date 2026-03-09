import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database/dao/post_dao.dart';
import 'package:offline_first_app/data/local/secure_storage/auth_storage.dart';
import 'package:offline_first_app/data/models/post.dart';
import 'package:offline_first_app/services/api/post_api.dart';
import 'package:offline_first_app/core/utils/connectivity_service.dart';

class PostRepository {
  final PostDao _postDao;
  final PostApi _postApi;
  final AuthStorage _authStorage;
  final ConnectivityService _connectivityService;
  final Ref _ref;
  
  PostRepository({
    required PostDao postDao,
    required PostApi postApi,
    required AuthStorage authStorage,
    required ConnectivityService connectivityService,
    required Ref ref,
  })  : _postDao = postDao,
        _postApi = postApi,
        _authStorage = authStorage,
        _connectivityService = connectivityService,
        _ref = ref;
  
  // Create post (offline first)
  Future<Post> createPost(String content, {String? imageUrl}) async {
    final userId = await _authStorage.getUserId();
    if (userId == null) throw Exception('User not logged in');
    
    // Create post locally first
    final post = Post.createOffline(
      userId: userId,
      content: content,
      imageUrl: imageUrl,
    );
    
    // Save to local DB immediately
    await _postDao.insertPost(post);
    
    // Try to sync if online
    if (await _connectivityService.isConnected()) {
      // Don't await, let it sync in background
      _syncPost(post);
    }
    
    return post;
  }
  
  // Get all posts (stream for real-time UI)
  Stream<List<Post>> getPostsStream() {
    return _postDao.watchAllPosts();
  }
  
  // Get posts by user
  Stream<List<Post>> getUserPostsStream(String userId) {
    return _postDao.watchUserPosts(userId);
  }
  
  // Delete post (offline first)
  Future<void> deletePost(String postId) async {
    // Mark as deleted locally
    await _postDao.markPostAsDeleted(postId);
    
    // Try to sync deletion if online
    if (await _connectivityService.isConnected()) {
      _syncDeletion(postId);
    }
  }
  
  // Sync a single post
  Future<void> _syncPost(Post post) async {
    try {
      final token = await _authStorage.getToken();
      if (token == null) throw Exception('No auth token');
      
      // Upload to server
      final serverPost = await _postApi.createPost(
        token: token,
        content: post.content,
        imageUrl: post.imageUrl,
      );
      
      // Update local post with server data and mark as synced
      await _postDao.updatePostAfterSync(
        localId: post.id,
        serverId: serverPost.id,
      );
    } catch (e) {
      // Mark sync failed
      await _postDao.markPostSyncFailed(post.id, e.toString());
    }
  }
  
  // Sync deletion
  Future<void> _syncDeletion(String postId) async {
    try {
      final token = await _authStorage.getToken();
      if (token == null) throw Exception('No auth token');
      
      // Delete from server
      await _postApi.deletePost(token, postId);
      
      // Remove from local DB
      await _postDao.deletePostPermanently(postId);
    } catch (e) {
      // If deletion sync fails, keep it marked as deleted
      // It will be retried later
    }
  }
  
  // Sync all pending posts (called when connection is restored)
  Future<void> syncPendingPosts() async {
    final pendingPosts = await _postDao.getPendingPosts();
    
    for (final post in pendingPosts) {
      if (post.isDeleted) {
        await _syncDeletion(post.id);
      } else {
        await _syncPost(post);
      }
    }
  }
}

// Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    postDao: ref.watch(postDaoProvider),
    postApi: ref.watch(postApiProvider),
    authStorage: ref.watch(authStorageProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    ref: ref,
  );
});