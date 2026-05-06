import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locket_app/core/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    super.id,
    required super.senderId,
    required super.mediaUrl,
    required super.caption,
    required super.type,
    required super.visibleTo,
    super.reactions,
    required super.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'mediaUrl': mediaUrl,
    'caption': caption,
    'type': type,
    'visibleTo': visibleTo,
    'reactions': reactions,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
