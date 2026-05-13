import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/feed/domain/entities/feed_post_entity.dart';
import 'package:locket_app/modules/feed/domain/repository/feed_repository.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _repository;
  StreamSubscription<List<FeedPostEntity>>? _subscription;

  FeedCubit(this._repository) : super(const FeedState());

  void watchFeed() {
    emit(state.copyWith(status: FeedStatus.loading));
    _subscription?.cancel();
    _subscription = _repository.watchVisiblePosts().listen(
      (posts) {
        emit(
          state.copyWith(
            status: FeedStatus.success,
            items: posts.map(FeedItem.fromEntity).toList(),
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: FeedStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
