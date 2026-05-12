/// User entity - Domain layer
class UserEntity {
  final int? id;
  final String username;
  final String password;
  final String? displayName;
  final String? avatarPath;
  final DateTime createdAt;

  const UserEntity({
    this.id,
    required this.username,
    required this.password,
    this.displayName,
    this.avatarPath,
    required this.createdAt,
  });

  UserEntity copyWith({
    int? id,
    String? username,
    String? password,
    String? displayName,
    String? avatarPath,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
