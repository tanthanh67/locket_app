import '../../../../core/domain/entities/user_entity.dart';

abstract class FriendsRepository {
  Future<List<UserEntity>> searchUsers(String email);
  Future<void> sendFriendRequest(String receiverId);
  Stream<List<Map<String, dynamic>>> getPendingRequests(); // Lời mời đang chờ
  Future<void> acceptFriendRequest(String requestId, String senderId);
  Future<void> deleteFriendRequest(String requestId);
  Stream<List<UserEntity>> getFriendsList();
}
