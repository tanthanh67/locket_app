import '../repositories/friend_repository.dart';

class UnfriendUseCase {
  final FriendRepository repository;

  UnfriendUseCase(this.repository);

  Future<void> call(String friendId) {
    return repository.unfriend(friendId);
  }
}
