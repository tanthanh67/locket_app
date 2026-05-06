import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../domain/repository/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<List<UserEntity>> searchUsers(String email) async {
    final snap = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return UserEntity(
        uid: doc.id,
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        photoUrl: data['photoUrl'] ?? '',
        friends: List<String>.from(data['friends'] ?? []),
      );
    }).toList();
  }

  @override
  Future<void> sendFriendRequest(String receiverId) async {
    final senderId = _auth.currentUser!.uid;
    await _firestore.collection('friend_requests').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> acceptFriendRequest(String requestId, String senderId) async {
    final myUid = _auth.currentUser!.uid;

    // 1. Cập nhật trạng thái lời mời
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'accepted',
    });

    // 2. Thêm nhau vào danh sách bạn bè (Atomic update)
    await _firestore.collection('users').doc(myUid).update({
      'friends': FieldValue.arrayUnion([senderId]),
    });
    await _firestore.collection('users').doc(senderId).update({
      'friends': FieldValue.arrayUnion([myUid]),
    });
  }

  @override
  Stream<List<UserEntity>> getFriendsList() {
    final myUid = _auth.currentUser!.uid;
    // Lắng nghe user hiện tại để lấy mảng friends
    return _firestore.collection('users').doc(myUid).snapshots().asyncMap((
      userDoc,
    ) async {
      List<String> friendIds = List<String>.from(
        userDoc.data()?['friends'] ?? [],
      );
      if (friendIds.isEmpty) return [];

      // Truy vấn thông tin chi tiết từng người bạn
      final friendsSnap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      return friendsSnap.docs.map((doc) {
        final data = doc.data();
        return UserEntity(
          uid: doc.id,
          displayName: data['displayName'] ?? '',
          email: data['email'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          friends: List<String>.from(data['friends'] ?? []),
        );
      }).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getPendingRequests() {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }
}
