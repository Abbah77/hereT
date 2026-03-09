import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/models/post.dart';
import 'package:offline_first_app/services/api/api_client.dart';

class PostApi {
  final ApiClient _apiClient;
  
  PostApi({required ApiClient apiClient}) : _apiClient = apiClient;
  
  Future<Post> createPost({
    required String token,
    required String content,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      '/posts',
      data: {
        'content': content,
        'imageUrl': imageUrl,
      },
    );
    return Post.fromJson(response.data);
  }
  
  Future<List<Post>> getPosts({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/posts',
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );
    return (response.data['data'] as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }
  
  Future<Post> getPost(String postId) async {
    final response = await _apiClient.get('/posts/$postId');
    return Post.fromJson(response.data);
  }
  
  Future<void> deletePost(String token, String postId) async {
    await _apiClient.delete('/posts/$postId');
  }
  
  Future<Post> updatePost(String postId, String content) async {
    final response = await _apiClient.put(
      '/posts/$postId',
      data: {'content': content},
    );
    return Post.fromJson(response.data);
  }
  
  Future<List<Post>> getUserPosts(String userId) async {
    final response = await _apiClient.get('/users/$userId/posts');
    return (response.data['data'] as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }
}

// Provider
final postApiProvider = Provider<PostApi>((ref) {
  return PostApi(apiClient: ref.watch(apiClientProvider));
});