import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.photoUrl,
    required super.friends,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'friends': friends,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
