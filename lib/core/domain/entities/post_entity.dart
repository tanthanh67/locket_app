import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String? id;
  final String senderId;
  final String mediaUrl;
  final String caption;
  final String type; // 'image' hoặc 'video'
  final List<String> visibleTo; // Danh sách UIDs được xem bài này
  final Map<String, String> reactions; // { "uid": "❤️" }
  final DateTime createdAt;

  const PostEntity({
    this.id,
    required this.senderId,
    required this.mediaUrl,
    required this.caption,
    required this.type,
    required this.visibleTo,
    this.reactions = const {},
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    mediaUrl,
    caption,
    type,
    visibleTo,
    reactions,
    createdAt,
  ];
}
