class FeedItem {
  final String imageUrl;
  final String caption;
  final String userName;
  final String avatarUrl;
  final String timeAgo;

  const FeedItem({
    required this.imageUrl,
    required this.caption,
    required this.userName,
    required this.avatarUrl,
    required this.timeAgo,
  });
}

const List<FeedItem> feedItems = [
  FeedItem(
    imageUrl:
        'https://img.magnific.com/free-photo/closeup-shot-beautiful-butterfly-with-interesting-textures-orange-petaled-flower_181624-7640.jpg?semt=ais_hybrid&w=740&q=80',
    caption: 'This is a caption for the photo.',
    userName: 'John Doe',
    avatarUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGa70BgePn1Rsf41oiG6ac0_TAzpKXj4d9qg&s',
    timeAgo: '2h',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
    caption: 'Morning light in the city.',
    userName: 'Mai Nguyen',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
    timeAgo: '5h',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    caption: 'Late afternoon by the lake.',
    userName: 'Alex Tran',
    avatarUrl:
        'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=80',
    timeAgo: '1d',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=80',
    caption: 'Warm tones at dusk.',
    userName: 'Linh Pham',
    avatarUrl:
        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
    timeAgo: '1d',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    caption: 'Calm lake scene.',
    userName: 'Nina Dao',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    timeAgo: '2d',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?auto=format&fit=crop&w=1200&q=80',
    caption: 'City lights on a rainy night.',
    userName: 'Tuan Vu',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
    timeAgo: '2d',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=80',
    caption: 'Forest trail walk.',
    userName: 'Kim Le',
    avatarUrl:
        'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=200&q=80',
    timeAgo: '3d',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1200&q=80',
    caption: 'Golden field horizon.',
    userName: 'Quang Ho',
    avatarUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
    timeAgo: '4d',
  ),
  FeedItem(
    imageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    caption: 'Quiet afternoon scene.',
    userName: 'Ha Tran',
    avatarUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
    timeAgo: '5d',
  ),
];
