import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../domain/repositories/friend_repository.dart';
import '../data_sources/friend_remote_data_source.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remote;
  final FirebaseAuth auth;

  FriendRepositoryImpl(this.remote, this.auth);

  String get _uid => auth.currentUser!.uid;

  // ================= FRIENDS =================
  @override
  Stream<List<UserEntity>> getFriends() {
    return remote.getFriends(_uid);
  }

  // ================= ALL USERS =================
  @override
  Stream<List<UserEntity>> getAllUsers() {
    return remote.getAllUsers();
  }

  // ================= REQUEST =================
  @override
  Stream<List<UserEntity>> getIncomingFriendRequests() {
    return remote.getIncomingFriendRequests(_uid);
  }

  @override
  Stream<List<UserEntity>> getOutgoingFriendRequests() {
    return remote.getOutgoingFriendRequests(_uid);
  }

  // ================= SEARCH =================
  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    final users = await remote.searchUsers(query);

    // remove myself
    return users.where((u) => u.uid != _uid).toList();
  }

  // ================= ACTIONS =================
  @override
  Future<void> sendFriendRequest(String receiverId) {
    return remote.sendFriendRequest(_uid, receiverId);
  }

  @override
  Future<void> acceptFriendRequest(String senderId) {
    return remote.acceptFriendRequest(senderId, _uid);
  }

  @override
  Future<void> rejectFriendRequest(String senderId) {
    return remote.rejectFriendRequest(senderId, _uid);
  }

  @override
  Future<void> unfriend(String friendId) {
    return remote.unfriend(_uid, friendId);
  }
}
