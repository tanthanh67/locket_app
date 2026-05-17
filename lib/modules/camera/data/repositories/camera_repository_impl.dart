import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/domain/entities/post_entity.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/repository/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CloudinaryService _cloudinary;
  final GeminiService _gemini;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CameraRepositoryImpl(this._cloudinary, this._gemini);

  @override
  Future<String> uploadMedia(String path, bool isVideo) async {
    // CloudinaryService xử lý resourceType: isVideo ? 'video' : 'image'
    return await _cloudinary.uploadImage(path) ?? "";
  }

  @override
  Future<String> getAiCaption(String path) async =>
      await _gemini.generateCaption(path);

  @override
  Future<void> createPost(PostEntity post) async {
    await _firestore.collection('posts').add({
      'senderId': post.senderId,
      'mediaUrl': post.mediaUrl,
      'caption': post.caption,
      'type': post.type,
      'visibleTo': post.visibleTo,
      'reactions': {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<String>> getMyFriendIds() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    return List<String>.from(doc.data()?['friends'] ?? []);
  }

  @override
  Future<List<UserEntity>> getMyFriends() async {
    final friendIds = await getMyFriendIds();
    final friends = <UserEntity>[];

    for (var i = 0; i < friendIds.length; i += 10) {
      final chunk = friendIds.skip(i).take(10).toList();
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      friends.addAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return UserEntity(
            uid: doc.id,
            displayName: data['displayName'] ?? '',
            email: data['email'] ?? '',
            photoUrl: data['photoUrl'] ?? '',
            friends: List<String>.from(data['friends'] ?? []),
          );
        }),
      );
    }

    return friends;
  }
}
