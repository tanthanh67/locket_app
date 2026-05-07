import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/core/domain/entities/user_entity.dart';
import 'package:locket_app/modules/friends/domain/use_cases/get_all_users_usecase.dart';

// ================= USE CASES =================
import 'package:locket_app/modules/friends/domain/use_cases/get_friends_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/get_incoming_friend_requests_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/send_friend_request_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/accept_friend_request_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/reject_friend_request_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/unfriend_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/search_users_usecase.dart';

import 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  final GetFriendsUseCase getFriends;
  final SendFriendRequestUseCase sendRequest;
  final AcceptFriendRequestUseCase acceptRequest;
  final RejectFriendRequestUseCase rejectRequest;
  final UnfriendUseCase unfriendUseCase;
  final SearchUsersUseCase searchUsersUseCase;
  final GetIncomingRequestsUseCase getIncomingRequestsUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  List<UserEntity> _allUsers = [];
  Timer? _debounce;
  StreamSubscription? _usersSub;
  StreamSubscription? _friendsSub;
  StreamSubscription? _incomingSub;

  FriendCubit({
    required this.getFriends,
    required this.sendRequest,
    required this.acceptRequest,
    required this.rejectRequest,
    required this.unfriendUseCase,
    required this.searchUsersUseCase,
    required this.getIncomingRequestsUseCase,
    required this.getAllUsersUseCase,
  }) : super(FriendInitial());
  void loadUsers() {
    _usersSub?.cancel();

    _usersSub = getAllUsersUseCase().listen((data) {
      _allUsers = data;
    });
  }

  // ================= FRIEND LIST =================
  void loadFriends() {
    emit(FriendLoading());

    _friendsSub?.cancel();
    _friendsSub = getFriends().listen(
      (data) => emit(FriendLoaded(data)),
      onError: (e) => emit(FriendError(e.toString())),
    );
  }

  // ================= SEARCH =================
  Future<void> search(String query) async {
    try {
      emit(FriendLoading());

      final result = await searchUsersUseCase(query);

      emit(FriendSearchLoaded(result));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  // ================= INCOMING REQUEST =================
  void loadIncomingRequests() {
    _incomingSub?.cancel();

    _incomingSub = getIncomingRequestsUseCase().listen(
      (data) => emit(FriendIncomingLoaded(data)),
      onError: (e) => emit(FriendError(e.toString())),
    );
  }

  // ================= SEND REQUEST =================
  Future<void> sendFriend(String uid) async {
    try {
      await sendRequest(uid);
      emit(const FriendActionSuccess("Friend request sent"));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  // ================= ACCEPT =================
  Future<void> accept(String uid) async {
    try {
      await acceptRequest(uid);
      emit(const FriendActionSuccess("Friend request accepted"));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  // ================= REJECT =================
  Future<void> reject(String uid) async {
    try {
      await rejectRequest(uid);
      emit(const FriendActionSuccess("Friend request rejected"));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  // ================= UNFRIEND =================
  Future<void> unfriend(String uid) async {
    try {
      await unfriendUseCase(uid);
      emit(const FriendActionSuccess("Unfriended successfully"));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  // ================= CLEANUP =================
  @override
  Future<void> close() {
    _friendsSub?.cancel();
    _incomingSub?.cancel();
    return super.close();
  }
}
