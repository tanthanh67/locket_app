import 'package:flutter/material.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';

class FeedArea extends StatefulWidget {
  const FeedArea({
    super.key,
    this.onUserChanged,
    this.controller,
    this.highlightedIndex,
  });

  final ValueChanged<String>? onUserChanged;
  final PageController? controller;
  final int? highlightedIndex;

  @override
  State<FeedArea> createState() => _FeedAreaState();
}

class _FeedAreaState extends State<FeedArea> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      scrollDirection: Axis.vertical,
      itemCount: feedItems.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        return _buildFeedItem(feedItems[index], index);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (feedItems.isNotEmpty) {
        widget.onUserChanged?.call(feedItems.first.userName);
      }
    });
  }

  void _handlePageChanged(int index) {
    widget.onUserChanged?.call(feedItems[index].userName);
  }

  Widget _buildFeedItem(FeedItem item, int index) {
    final isHighlighted = widget.highlightedIndex == index;

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
                AnimatedScale(
                  scale: isHighlighted ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    height: 400,
                    width: double.infinity,
                  ),
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
