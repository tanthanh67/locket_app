part of 'friends_cubit.dart';

sealed class FriendsState extends Equatable {
  const FriendsState();
  @override
  List<Object?> get props => [];
}

final class FriendsInitial extends FriendsState {}

final class FriendsLoading extends FriendsState {}

final class FriendsLoaded extends FriendsState {
  final List<UserEntity> myFriends;
  final List<Map<String, dynamic>> pendingRequests;
  final List<UserEntity> searchResults; // Đảm bảo có dòng này
  final List<String> sentRequestIds;

  const FriendsLoaded({
    required this.myFriends,
    required this.pendingRequests,
    this.searchResults = const [], // Đảm bảo có dòng này trong constructor
    this.sentRequestIds = const [],
  });

  // Đảm bảo phương thức copyWith có đầy đủ 3 tham số
  FriendsLoaded copyWith({
    List<UserEntity>? myFriends,
    List<Map<String, dynamic>>? pendingRequests,
    List<UserEntity>? searchResults,
    List<String>? sentRequestIds,
  }) {
    return FriendsLoaded(
      myFriends: myFriends ?? this.myFriends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      searchResults: searchResults ?? this.searchResults, // Thêm dòng này
      sentRequestIds: sentRequestIds ?? this.sentRequestIds,
    );
  }

  @override
  List<Object?> get props => [
    myFriends,
    pendingRequests,
    searchResults,
    sentRequestIds,
  ];
}

final class FriendsError extends FriendsState {
  final String message;
  const FriendsError(this.message);
  @override
  List<Object?> get props => [message];
}
