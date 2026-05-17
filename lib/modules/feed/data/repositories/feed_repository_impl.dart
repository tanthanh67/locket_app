import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locket_app/core/domain/entities/post_entity.dart';
import 'package:locket_app/modules/feed/domain/entities/feed_post_entity.dart';
import 'package:locket_app/modules/feed/domain/repository/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeedRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<FeedPostEntity>> watchVisiblePosts() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final posts = snapshot.docs
              .map(_postFromDoc)
              .where(
                (post) =>
                    post.type == 'image' &&
                    (post.senderId == uid || post.visibleTo.contains(uid)),
              )
              .toList();

          if (posts.isEmpty) {
            return const <FeedPostEntity>[];
          }

          final userIds = <String>{
            for (final post in posts) post.senderId,
            for (final post in posts) ...post.reactions.keys,
          }.toList();
          final users = await _loadUsers(userIds);

          return posts.map((post) {
            final user = users[post.senderId];
            final reactions = post.reactions.entries
                .where((entry) => entry.key != uid)
                .map((entry) {
                  final reactionUser = users[entry.key];
                  return FeedReactionEntity(
                    userId: entry.key,
                    userName:
                        reactionUser?['displayName'] as String? ?? 'A friend',
                    emoji: entry.value,
                  );
                })
                .toList();

            return FeedPostEntity(
              post: post,
              senderName: user?['displayName'] as String? ?? 'Unknown',
              senderAvatarUrl: user?['photoUrl'] as String? ?? '',
              isMine: post.senderId == uid,
              reactions: reactions,
            );
          }).toList();
        });
  }

  @override
  Future<void> reactToPost(String postId, String emoji) {
    final uid = _auth.currentUser!.uid;

    return _firestore.collection('posts').doc(postId).update({
      'reactions.$uid': emoji,
    });
  }

  PostEntity _postFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAt = data['createdAt'];

    return PostEntity(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      type: data['type'] as String? ?? 'image',
      visibleTo: List<String>.from(data['visibleTo'] ?? const []),
      reactions: Map<String, String>.from(data['reactions'] ?? const {}),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _loadUsers(
    List<String> senderIds,
  ) async {
    final result = <String, Map<String, dynamic>>{};

    for (var i = 0; i < senderIds.length; i += 10) {
      final chunk = senderIds.skip(i).take(10).toList();
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        result[doc.id] = doc.data();
      }
    }

    return result;
  }
}
