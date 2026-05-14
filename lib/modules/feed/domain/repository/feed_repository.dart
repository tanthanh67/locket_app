import '../entities/feed_post_entity.dart';

abstract class FeedRepository {
  Stream<List<FeedPostEntity>> watchVisiblePosts();
  Future<void> reactToPost(String postId, String emoji);
}
