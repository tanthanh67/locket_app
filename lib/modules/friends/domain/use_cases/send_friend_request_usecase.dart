import '../repositories/friend_repository.dart';

class SendFriendRequestUseCase {
  final FriendRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<void> call(String receiverId) {
    return repository.sendFriendRequest(receiverId);
  }
}
