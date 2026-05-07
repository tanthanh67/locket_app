import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/friend_repository.dart';

class GetOutgoingRequestsUseCase {
  final FriendRepository repository;

  GetOutgoingRequestsUseCase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getOutgoingFriendRequests();
  }
}
