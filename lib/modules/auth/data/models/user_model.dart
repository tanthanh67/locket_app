import '../../../../core/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
  });

  // Chuyển sang Map để ghi vào Firestore
  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl ?? '',
    'friends': [], // Mặc định chưa có bạn
    'createdAt': DateTime.now(),
  };
}
