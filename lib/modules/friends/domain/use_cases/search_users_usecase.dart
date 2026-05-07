import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/friend_repository.dart';

class SearchUsersUseCase {
  final FriendRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<UserEntity>> call(String query) {
    return repository.searchUsers(query);
  }
}
