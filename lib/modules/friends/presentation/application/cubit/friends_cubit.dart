import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/entities/user_entity.dart';
import '../../../domain/repository/friends_repository.dart';

part 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsRepository _repository;
  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;

  FriendsCubit(this._repository) : super(FriendsInitial());

  // Lắng nghe dữ liệu bạn bè và lời mời theo thời gian thực
  void initFriendsModule() {
    emit(FriendsLoading());
    _friendsSub?.cancel();
    _requestsSub?.cancel();

    // Lắng nghe danh sách bạn bè
    _friendsSub = _repository.getFriendsList().listen((friends) {
      _updateState(newFriends: friends);
    });

    // Lắng nghe lời mời kết bạn
    _requestsSub = _repository.getPendingRequests().listen((requests) {
      _updateState(newRequests: requests);
    });
  }

  void _updateState({
    List<UserEntity>? newFriends,
    List<Map<String, dynamic>>? newRequests,
    List<UserEntity>? searchResults, // Thêm tham số này vào hàm helper
    List<String>? sentRequestIds,
  }) {
    if (state is FriendsLoaded) {
      emit(
        (state as FriendsLoaded).copyWith(
          myFriends: newFriends,
          pendingRequests: newRequests,
          searchResults: searchResults, // Truyền vào copyWith
          sentRequestIds: sentRequestIds,
        ),
      );
    } else {
      emit(
        FriendsLoaded(
          myFriends: newFriends ?? [],
          pendingRequests: newRequests ?? [],
          searchResults: searchResults ?? [],
          sentRequestIds: sentRequestIds ?? [],
        ),
      );
    }
  }

  Future<void> search(String email) async {
    if (email.isEmpty) {
      _updateState(searchResults: []);
      return;
    }
    try {
      final results = await _repository.searchUsers(email);
      _updateState(searchResults: results);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> sendRequest(String targetUid) async {
    try {
      await _repository.sendFriendRequest(targetUid);

      if (state is FriendsLoaded) {
        final currentState = state as FriendsLoaded;
        _updateState(
          sentRequestIds: {...currentState.sentRequestIds, targetUid}.toList(),
        );
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> accept(String requestId, String senderId) async {
    try {
      await _repository.acceptFriendRequest(requestId, senderId);
      _removePendingRequest(requestId);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await _repository.deleteFriendRequest(requestId);
      _removePendingRequest(requestId);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _removePendingRequest(String requestId) {
    if (state is! FriendsLoaded) {
      return;
    }

    final currentState = state as FriendsLoaded;
    _updateState(
      newRequests: currentState.pendingRequests
          .where((request) => request['id'] != requestId)
          .toList(),
    );
  }

  @override
  Future<void> close() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    return super.close();
  }
}
