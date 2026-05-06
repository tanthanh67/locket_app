import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  }) {
    if (state is FriendsLoaded) {
      emit(
        (state as FriendsLoaded).copyWith(
          myFriends: newFriends,
          pendingRequests: newRequests,
          searchResults: searchResults, // Truyền vào copyWith
        ),
      );
    } else {
      emit(
        FriendsLoaded(
          myFriends: newFriends ?? [],
          pendingRequests: newRequests ?? [],
          searchResults: searchResults ?? [],
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
    await _repository.sendFriendRequest(targetUid);
  }

  Future<void> accept(String requestId, String senderId) async {
    await _repository.acceptFriendRequest(requestId, senderId);
  }

  @override
  Future<void> close() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    return super.close();
  }
}
