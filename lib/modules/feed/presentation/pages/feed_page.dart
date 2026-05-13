import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/feed/presentation/components/bottom_nav.dart';
import 'package:locket_app/modules/feed/presentation/components/feed_area.dart';
import 'package:locket_app/modules/feed/presentation/application/cubit/feed_cubit.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';
import 'package:locket_app/modules/history/presentation/pages/history_page.dart';

class FeedPage extends StatefulWidget {
  final VoidCallback? onCameraTap;
  final String selectedFriend;

  const FeedPage({
    super.key,
    this.onCameraTap,
    this.selectedFriend = 'All friends',
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  final PageController _pageController = PageController();
  bool _isReplying = false;
  bool _isReturningToCamera = false;
  String _currentUser = 'John Doe';
  int? _highlightedIndex;

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFriend != widget.selectedFriend &&
        _pageController.hasClients) {
      _pageController.jumpToPage(0);
      final items = _filteredItems(context.read<FeedCubit>().state.items);
      if (items.isNotEmpty) {
        _handleUserChanged(items.first.userName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        final items = _filteredItems(state.items);

        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleFeedScroll,
                      child: FeedArea(
                        items: items,
                        isLoading: state.status == FeedStatus.loading,
                        errorMessage: state.errorMessage,
                        onUserChanged: _handleUserChanged,
                        controller: _pageController,
                        highlightedIndex: _highlightedIndex,
                      ),
                    ),
                  ),
                  _buildCommentBar(),
                  BottomNav(
                    onHistoryTap: _openHistory,
                    onCameraTap: _returnToCamera,
                  ),
                ],
              ),
              if (_isReplying) _buildReplyOverlay(),
            ],
          ),
        );
      },
    );
  }

  List<FeedItem> _filteredItems(List<FeedItem> items) {
    if (widget.selectedFriend == 'All friends') {
      return items;
    }

    return items
        .where((item) => item.userName == widget.selectedFriend)
        .toList();
  }

  void _handleUserChanged(String userName) {
    _isReturningToCamera = false;

    if (_currentUser == userName) {
      return;
    }

    setState(() {
      _currentUser = userName;
    });
  }

  bool _handleFeedScroll(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      return _handleFeedOverscroll(notification);
    }

    if (notification is ScrollUpdateNotification) {
      return _handleFeedPullDownUpdate(notification);
    }

    return false;
  }

  bool _handleFeedOverscroll(OverscrollNotification notification) {
    final onFirstItem =
        notification.metrics.pixels <= notification.metrics.minScrollExtent + 8;
    final pullingDown = notification.overscroll < 0;

    if (!_isReturningToCamera &&
        onFirstItem &&
        pullingDown &&
        widget.onCameraTap != null) {
      _returnToCamera();
      return true;
    }

    return false;
  }

  bool _handleFeedPullDownUpdate(ScrollUpdateNotification notification) {
    final dragDelta = notification.dragDetails?.delta.dy ?? 0;
    final currentPage = _pageController.hasClients
        ? (_pageController.page ?? _pageController.initialPage.toDouble())
        : 0.0;
    final onFirstItem =
        currentPage <= 0.02 &&
        notification.metrics.pixels <= notification.metrics.minScrollExtent + 8;

    if (!_isReturningToCamera &&
        onFirstItem &&
        dragDelta > 8 &&
        widget.onCameraTap != null) {
      _returnToCamera();
      return true;
    }

    return false;
  }

  void _returnToCamera() {
    _isReturningToCamera = true;
    widget.onCameraTap?.call();

    Future.delayed(const Duration(milliseconds: 420), () {
      _isReturningToCamera = false;
    });
  }

  Future<void> _openHistory() async {
    final feedCubit = context.read<FeedCubit>();
    final feedItems = feedCubit.state.items;
    final selectedIndex = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => HistoryPage(items: feedItems)),
    );

    if (!mounted) {
      return;
    }

    final items = _filteredItems(feedCubit.state.items);

    if (selectedIndex == null || items.isEmpty) {
      return;
    }

    final safeIndex = selectedIndex.clamp(0, items.length - 1).toInt();

    await _pageController.animateToPage(
      safeIndex,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _highlightedIndex = safeIndex;
    });

    _clearHighlightAfter(safeIndex);
  }

  void _clearHighlightAfter(int index) {
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) {
        return;
      }

      if (_highlightedIndex == index) {
        setState(() {
          _highlightedIndex = null;
        });
      }
    });
  }

  Widget _buildCommentBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _openReply,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text(
                  'Send a message...',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('🤍', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 4),
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 4),
          const Text('😍', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 4),
          const Icon(Icons.add_reaction_outlined, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildReplyOverlay() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _closeReply,
            child: AnimatedOpacity(
              opacity: _isReplying ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: Container(color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                0,
                12,
                bottomInset > 0 ? bottomInset : 12,
              ),
              child: _buildReplyInput(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A28),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3A3A38), width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocusNode,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white70,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'Reply to $_currentUser...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _handleSend,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReply() {
    if (_isReplying) {
      return;
    }

    setState(() {
      _isReplying = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _replyFocusNode.requestFocus();
    });
  }

  void _closeReply() {
    _replyFocusNode.unfocus();
    setState(() {
      _isReplying = false;
    });
  }

  void _handleSend() {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _replyController.clear();
    _closeReply();
  }
}
