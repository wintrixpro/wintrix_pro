import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String referredBy,
    required bool isBanned,
    required String profilePic,
    required int createdAt,
    required int updatedAt,
  }) : super(
          uid: uid,
          name: name,
          phone: phone,
          email: email,
          referredBy: referredBy,
          isBanned: isBanned,
          profilePic: profilePic,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'referred_by': referredBy,
      'is_banned': isBanned,
      'profile_pic': profilePic,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      referredBy: map['referred_by'] ?? '',
      isBanned: map['is_banned'] ?? false,
      profilePic: map['profile_pic'] ?? '',
      createdAt: map['created_at'] ?? 0,
      updatedAt: map['updated_at'] ?? 0,
    );
  }
}
