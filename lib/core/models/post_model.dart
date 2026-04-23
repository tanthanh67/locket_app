import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String senderId;
  final String senderName;
  final String mediaUrl;
  final String caption;
  final DateTime timestamp;
  final List<String> visibleTo;

  PostModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.mediaUrl,
    required this.caption,
    required this.timestamp,
    required this.visibleTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'timestamp': timestamp,
      'visibleTo': visibleTo,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      caption: map['caption'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      visibleTo: List<String>.from(map['visibleTo'] ?? []),
    );
  }
}
