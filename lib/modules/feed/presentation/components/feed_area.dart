import 'package:flutter/material.dart';

class FeedArea extends StatefulWidget {
  const FeedArea({super.key, this.onUserChanged});

  final ValueChanged<String>? onUserChanged;

  @override
  State<FeedArea> createState() => _FeedAreaState();
}

class _FeedAreaState extends State<FeedArea> {
  static const List<_FeedItem> _items = [
    _FeedItem(
      imageUrl:
          'https://img.magnific.com/free-photo/closeup-shot-beautiful-butterfly-with-interesting-textures-orange-petaled-flower_181624-7640.jpg?semt=ais_hybrid&w=740&q=80',
      caption: 'This is a caption for the photo.',
      userName: 'John Doe',
      avatarUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGa70BgePn1Rsf41oiG6ac0_TAzpKXj4d9qg&s',
      timeAgo: '2h',
    ),
    _FeedItem(
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
      caption: 'Morning light in the city.',
      userName: 'Mai Nguyen',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      timeAgo: '5h',
    ),
    _FeedItem(
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
      caption: 'Late afternoon by the lake.',
      userName: 'Alex Tran',
      avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=80',
      timeAgo: '1d',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _items.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        return _buildFeedItem(_items[index]);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onUserChanged?.call(_items.first.userName);
    });
  }

  void _handlePageChanged(int index) {
    widget.onUserChanged?.call(_items[index].userName);
  }

  Widget _buildFeedItem(_FeedItem item) {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  height: 400,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(item.avatarUrl),
            ),
            const SizedBox(width: 8),
            Text(
              item.userName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              item.timeAgo,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}

class _FeedItem {
  final String imageUrl;
  final String caption;
  final String userName;
  final String avatarUrl;
  final String timeAgo;

  const _FeedItem({
    required this.imageUrl,
    required this.caption,
    required this.userName,
    required this.avatarUrl,
    required this.timeAgo,
  });
}
