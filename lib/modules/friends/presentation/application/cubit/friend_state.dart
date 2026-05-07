import 'package:equatable/equatable.dart';
import 'package:locket_app/core/domain/entities/user_entity.dart';

class FriendState extends Equatable {
  final List<UserEntity> friends;
  final List<UserEntity> searchResults;
  final List<UserEntity> incomingRequests;
  final bool isLoading;
  final String? error;

  const FriendState({
    this.friends = const [],
    this.searchResults = const [],
    this.incomingRequests = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
    friends,
    searchResults,
    incomingRequests,
    isLoading,
    error,
  ];
}

// ================= INIT =================
class FriendInitial extends FriendState {}

class FriendLoading extends FriendState {}

class FriendError extends FriendState {
  final String message;

  const FriendError(this.message);

  @override
  List<Object?> get props => [message];
}

// ================= FRIEND LIST =================
class FriendLoaded extends FriendState {
  final List<UserEntity> friends;

  const FriendLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}

// ================= SEARCH =================
class FriendSearchLoaded extends FriendState {
  final List<UserEntity> users;

  const FriendSearchLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

// ================= INCOMING REQUESTS =================
class FriendIncomingLoaded extends FriendState {
  final List<UserEntity> requests;

  const FriendIncomingLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

// ================= ACTION SUCCESS =================
class FriendActionSuccess extends FriendState {
  final String message;

  const FriendActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
