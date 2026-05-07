import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locket_app/core/domain/entities/user_entity.dart';
import 'package:locket_app/modules/auth/data/models/user_model.dart';

abstract class FriendRemoteDataSource {
  Stream<List<UserEntity>> getFriends(String currentUserId);

  Stream<List<UserEntity>> getAllUsers();

  Stream<List<UserEntity>> getIncomingFriendRequests(String userId);
  Stream<List<UserEntity>> getOutgoingFriendRequests(String userId);

  Future<void> sendFriendRequest(String senderId, String receiverId);
  Future<void> acceptFriendRequest(String senderId, String receiverId);
  Future<void> rejectFriendRequest(String senderId, String receiverId);
  Future<void> unfriend(String currentUserId, String friendId);

  Future<List<UserEntity>> searchUsers(String query);
}

// ================= IMPLEMENT =================

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final FirebaseFirestore firestore;

  FriendRemoteDataSourceImpl(this.firestore);

  // ================= GET USER =================
  Future<UserEntity?> _getUser(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc.data()!);
  }

  // ================= FRIENDS =================
  @override
  Stream<List<UserEntity>> getFriends(String currentUserId) {
    return firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
          final list = <UserEntity>[];

          for (var doc in snapshot.docs) {
            final user = await _getUser(doc.id);
            if (user != null) list.add(user);
          }

          return list;
        });
  }

  // ================= ALL USERS =================
  @override
  Stream<List<UserEntity>> getAllUsers() {
    return firestore.collection('users').snapshots().map((snap) {
      return snap.docs.map((e) => UserModel.fromFirestore(e.data())).toList();
    });
  }

  // ================= INCOMING =================
  @override
  Stream<List<UserEntity>> getIncomingFriendRequests(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests_received')
        .snapshots()
        .asyncMap((snapshot) async {
          final list = <UserEntity>[];

          for (var doc in snapshot.docs) {
            final user = await _getUser(doc.id);
            if (user != null) list.add(user);
          }

          return list;
        });
  }

  // ================= OUTGOING =================
  @override
  Stream<List<UserEntity>> getOutgoingFriendRequests(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests_sent')
        .snapshots()
        .asyncMap((snapshot) async {
          final list = <UserEntity>[];

          for (var doc in snapshot.docs) {
            final user = await _getUser(doc.id);
            if (user != null) list.add(user);
          }

          return list;
        });
  }

  // ================= SEARCH =================
  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final snap = await firestore.collection('users').get();

    final q = query.toLowerCase();

    return snap.docs
        .map((e) => UserModel.fromFirestore(e.data()))
        .where(
          (u) =>
              u.displayName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  // ================= SEND REQUEST =================
  @override
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    await firestore
        .collection('users')
        .doc(senderId)
        .collection('friend_requests_sent')
        .doc(receiverId)
        .set({'time': FieldValue.serverTimestamp()});

    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests_received')
        .doc(senderId)
        .set({'time': FieldValue.serverTimestamp()});
  }

  // ================= ACCEPT =================
  @override
  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    await rejectFriendRequest(senderId, receiverId);

    await firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId)
        .set({'time': FieldValue.serverTimestamp()});

    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(senderId)
        .set({'time': FieldValue.serverTimestamp()});
  }

  // ================= REJECT =================
  @override
  Future<void> rejectFriendRequest(String senderId, String receiverId) async {
    await firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests_received')
        .doc(senderId)
        .delete();

    await firestore
        .collection('users')
        .doc(senderId)
        .collection('friend_requests_sent')
        .doc(receiverId)
        .delete();
  }

  // ================= UNFRIEND =================
  @override
  Future<void> unfriend(String currentUserId, String friendId) async {
    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .delete();

    await firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(currentUserId)
        .delete();
  }
}
