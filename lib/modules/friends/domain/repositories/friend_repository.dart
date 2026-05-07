// lib/modules/friends/domain/repositories/friend_repository.dart
import '../../../../core/domain/entities/user_entity.dart';

abstract class FriendRepository {
  Stream<List<UserEntity>> getFriends();

  Future<void> sendFriendRequest(String receiverId);

  Future<void> acceptFriendRequest(String senderId);

  Future<void> rejectFriendRequest(String senderId);

  Future<void> unfriend(String friendId);

  Stream<List<UserEntity>> getIncomingFriendRequests();

  Stream<List<UserEntity>> getOutgoingFriendRequests();

  Future<List<UserEntity>> searchUsers(String query);
  Stream<List<UserEntity>> getAllUsers();
}
