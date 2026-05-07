import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/friend_repository.dart';

class GetIncomingRequestsUseCase {
  final FriendRepository repository;

  GetIncomingRequestsUseCase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getIncomingFriendRequests();
  }
}
