class UserEntity {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String referredBy;
  final bool isBanned;
  final String profilePic;
  final int createdAt;
  final int updatedAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.referredBy,
    required this.isBanned,
    required this.profilePic,
    required this.createdAt,
    required this.updatedAt,
  });
}
