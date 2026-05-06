import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final List<String> friends; // Danh sách UID bạn bè

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.friends,
  });

  @override
  List<Object?> get props => [uid, displayName, email, photoUrl, friends];
}
