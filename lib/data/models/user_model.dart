import '../../domain/entities/user_entity.dart';

/// Data model for User - handles serialization to/from database
class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.username,
    required super.password,
    super.displayName,
    super.avatarPath,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      displayName: map['display_name'] as String?,
      avatarPath: map['avatar_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'display_name': displayName,
      'avatar_path': avatarPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      password: entity.password,
      displayName: entity.displayName,
      avatarPath: entity.avatarPath,
      createdAt: entity.createdAt,
    );
  }
}
