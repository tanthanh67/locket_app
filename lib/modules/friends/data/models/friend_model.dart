// lib/modules/friends/data/models/friend_model.dart

import '../../../../core/domain/entities/user_entity.dart';

class FriendModel extends UserEntity {
  const FriendModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
  });

  factory FriendModel.fromFirestore(Map<String, dynamic> data) {
    return FriendModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }
}
