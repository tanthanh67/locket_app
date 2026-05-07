import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;

  GetFriendsUseCase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getFriends();
  }
}
