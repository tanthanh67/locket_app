import 'package:equatable/equatable.dart';
import 'package:locket_app/core/domain/entities/post_entity.dart';

class FeedPostEntity extends Equatable {
  final PostEntity post;
  final String senderName;
  final String senderAvatarUrl;
  final bool isMine;
  final List<FeedReactionEntity> reactions;

  const FeedPostEntity({
    required this.post,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.isMine,
    this.reactions = const [],
  });

  @override
  List<Object?> get props => [
    post,
    senderName,
    senderAvatarUrl,
    isMine,
    reactions,
  ];
}

class FeedReactionEntity extends Equatable {
  final String userId;
  final String userName;
  final String emoji;

  const FeedReactionEntity({
    required this.userId,
    required this.userName,
    required this.emoji,
  });

  @override
  List<Object?> get props => [userId, userName, emoji];
}
