part of 'feed_cubit.dart';

enum FeedStatus { initial, loading, success, error }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<FeedItem> items;
  final String? errorMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<FeedItem>? items,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
