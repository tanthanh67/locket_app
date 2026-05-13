import 'package:equatable/equatable.dart';
import 'package:locket_app/core/domain/entities/post_entity.dart';

class FeedPostEntity extends Equatable {
  final PostEntity post;
  final String senderName;
  final String senderAvatarUrl;

  const FeedPostEntity({
    required this.post,
    required this.senderName,
    required this.senderAvatarUrl,
  });

  @override
  List<Object?> get props => [post, senderName, senderAvatarUrl];
}
