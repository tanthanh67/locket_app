import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/friend_repository.dart';

class GetAllUsersUseCase {
  final FriendRepository repository;

  GetAllUsersUseCase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getAllUsers();
  }
}
