import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/core/services/widget_sync_service.dart';
import 'package:locket_app/modules/feed/domain/entities/feed_post_entity.dart';
import 'package:locket_app/modules/feed/domain/repository/feed_repository.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _repository;
  final WidgetSyncService _widgetSyncService;
  StreamSubscription<List<FeedPostEntity>>? _subscription;
  String? _lastSyncedWidgetPostId;

  FeedCubit(this._repository, {WidgetSyncService? widgetSyncService})
    : _widgetSyncService = widgetSyncService ?? WidgetSyncService(),
      super(const FeedState());

  void watchFeed() {
    emit(state.copyWith(status: FeedStatus.loading));
    _subscription?.cancel();
    _subscription = _repository.watchVisiblePosts().listen(
      (posts) {
        final items = posts.map(FeedItem.fromEntity).toList();
        emit(state.copyWith(status: FeedStatus.success, items: items));
        _syncLatestPostToWidget(items);
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

  Future<void> reactToPost(String postId, String emoji) {
    return _repository.reactToPost(postId, emoji);
  }

  void _syncLatestPostToWidget(List<FeedItem> items) {
    if (items.isEmpty) {
      return;
    }

    final latest = items.first;
    if (_lastSyncedWidgetPostId == latest.id) {
      return;
    }

    _lastSyncedWidgetPostId = latest.id;
    unawaited(
      _widgetSyncService
          .syncLatestPost(
            imageUrl: latest.imageUrl,
            username: latest.isMine ? 'You' : latest.userName,
            avatarUrl: latest.avatarUrl,
            caption: latest.caption,
            timestamp: latest.timeAgo,
          )
          .catchError((_) {}),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
