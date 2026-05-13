import 'package:flutter/material.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';

class FeedArea extends StatefulWidget {
  const FeedArea({
    super.key,
    required this.items,
    this.isLoading = false,
    this.errorMessage,
    this.onUserChanged,
    this.onItemChanged,
    this.controller,
    this.highlightedIndex,
  });

  final List<FeedItem> items;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String>? onUserChanged;
  final ValueChanged<FeedItem>? onItemChanged;
  final PageController? controller;
  final int? highlightedIndex;

  @override
  State<FeedArea> createState() => _FeedAreaState();
}

class _FeedAreaState extends State<FeedArea> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD233)),
      );
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Text(
          widget.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

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
        _notifyCurrentItem(widget.items.first);
      }
    });
  }

  void _handlePageChanged(int index) {
    _notifyCurrentItem(widget.items[index]);
  }

  void _notifyCurrentItem(FeedItem item) {
    widget.onUserChanged?.call(item.userName);
    widget.onItemChanged?.call(item);
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
              backgroundColor: Colors.white24,
              backgroundImage: item.avatarUrl.isEmpty
                  ? null
                  : NetworkImage(item.avatarUrl),
              child: item.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white70, size: 18)
                  : null,
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
