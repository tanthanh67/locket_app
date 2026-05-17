import 'package:locket_app/modules/feed/domain/entities/feed_post_entity.dart';

class FeedItem {
  final String id;
  final String imageUrl;
  final String caption;
  final String userName;
  final String avatarUrl;
  final String timeAgo;
  final DateTime createdAt;
  final bool isMine;
  final List<FeedActivity> activities;

  const FeedItem({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.userName,
    required this.avatarUrl,
    required this.timeAgo,
    required this.createdAt,
    required this.isMine,
    this.activities = const [],
  });

  factory FeedItem.fromEntity(FeedPostEntity entity) {
    return FeedItem(
      id: entity.post.id ?? '',
      imageUrl: entity.post.mediaUrl,
      caption: entity.post.caption,
      userName: entity.isMine ? 'You' : entity.senderName,
      avatarUrl: entity.senderAvatarUrl,
      timeAgo: _timeAgo(entity.post.createdAt),
      createdAt: entity.post.createdAt,
      isMine: entity.isMine,
      activities: entity.reactions
          .map(
            (reaction) => FeedActivity(
              userName: reaction.userName,
              emoji: reaction.emoji,
            ),
          )
          .toList(),
    );
  }
}

class FeedActivity {
  final String userName;
  final String emoji;

  const FeedActivity({required this.userName, required this.emoji});
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) {
    return 'now';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}m';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}h';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d';
  }

  return '${(diff.inDays / 7).floor()}w';
}
