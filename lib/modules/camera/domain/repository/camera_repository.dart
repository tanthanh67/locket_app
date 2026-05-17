import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/domain/entities/post_entity.dart';

abstract class CameraRepository {
  Future<String> uploadMedia(String path, bool isVideo);
  Future<String> getAiCaption(String path);
  Future<void> createPost(PostEntity post);
  Future<List<String>> getMyFriendIds();
  Future<List<UserEntity>> getMyFriends();
}
