import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    this.profilePicture,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = true,
  });
  
  // Create from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] ?? json['full_name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }
  
  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'username': username,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  // Create a copy with updated fields
  User copyWith({
    String? fullName,
    String? email,
    String? username,
    String? profilePicture,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
    );
  }
  
  @override
  List<Object?> get props => [id, email, username];
}