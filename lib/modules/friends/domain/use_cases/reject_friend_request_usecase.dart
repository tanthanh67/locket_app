import '../repositories/friend_repository.dart';

class RejectFriendRequestUseCase {
  final FriendRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<void> call(String senderId) {
    return repository.rejectFriendRequest(senderId);
  }
}
