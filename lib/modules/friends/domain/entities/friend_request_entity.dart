class FriendRequestEntity {
  final String uid;
  final String displayName;
  final String? photoUrl;

  const FriendRequestEntity({
    required this.uid,
    required this.displayName,
    this.photoUrl,
  });
}