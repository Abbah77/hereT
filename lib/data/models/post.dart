import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final int syncAttempts;
  final String? syncError;
  final bool isDeleted;
  
  // UI-specific fields (not part of data)
  bool get isPending => !isSynced && syncAttempts > 0;
  bool get hasError => syncError != null && !isSynced;
  
  const Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = true,
    this.syncAttempts = 0,
    this.syncError,
    this.isDeleted = false,
  });
  
  // Create from JSON (API response)
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isSynced: true,
    );
  }
  
  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  // Create a new post (offline first)
  factory Post.createOffline({
    required String userId,
    required String content,
    String? imageUrl,
  }) {
    return Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      isSynced: false,
      syncAttempts: 0,
    );
  }
  
  // Mark as synced
  Post markAsSynced(String serverId) {
    return Post(
      id: serverId,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isSynced: true,
      syncAttempts: 0,
      syncError: null,
    );
  }
  
  // Mark sync failed
  Post markSyncFailed(String error) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: false,
      syncAttempts: syncAttempts + 1,
      syncError: error,
    );
  }
  
  @override
  List<Object?> get props => [id, content, isSynced];
}