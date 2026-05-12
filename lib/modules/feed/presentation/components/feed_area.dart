import 'package:flutter/material.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';

class FeedArea extends StatefulWidget {
  const FeedArea({
    super.key,
    required this.items,
    this.onUserChanged,
    this.controller,
    this.highlightedIndex,
  });

  final List<FeedItem> items;
  final ValueChanged<String>? onUserChanged;
  final PageController? controller;
  final int? highlightedIndex;

  @override
  State<FeedArea> createState() => _FeedAreaState();
}

class _FeedAreaState extends State<FeedArea> {
  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text('No moments yet', style: TextStyle(color: Colors.white70)),
      );
    }

    return PageView.builder(
      physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
      controller: widget.controller,
      scrollDirection: Axis.vertical,
      itemCount: widget.items.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        return _buildFeedItem(widget.items[index], index);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.items.isNotEmpty) {
        widget.onUserChanged?.call(widget.items.first.userName);
      }
    });
  }

  void _handlePageChanged(int index) {
    widget.onUserChanged?.call(widget.items[index].userName);
  }

  Widget _buildFeedItem(FeedItem item, int index) {
    final isHighlighted = widget.highlightedIndex == index;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
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
                          width: double.infinity,
                          height: double.infinity,
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
            ),
          ),
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
      ],
    );
  }
}
