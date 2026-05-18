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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 26,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: Stack(
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
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.08),
                                  Colors.black.withValues(alpha: 0.42),
                                ],
                                stops: const [0.48, 0.72, 1],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _FeedAvatar(item: item),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                      ),
                                    ),
                                    if (item.caption.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.caption.trim(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.92,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.18,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.timeAgo,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _FeedAvatar extends StatelessWidget {
  const _FeedAvatar({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: item.avatarUrl.isEmpty
          ? Center(
              child: Text(
                _initialsFor(item.userName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            )
          : Image.network(item.avatarUrl, fit: BoxFit.cover),
    );
  }
}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return '?';
  }

  final initials = parts.take(2).map((part) => part[0]).join();
  return initials.toUpperCase();
}
