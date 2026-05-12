import 'package:flutter/material.dart';
import 'package:locket_app/modules/feed/presentation/components/bottom_nav.dart';
import 'package:locket_app/modules/feed/presentation/components/circle_button.dart';
import 'package:locket_app/modules/feed/presentation/components/feed_area.dart';
import 'package:locket_app/modules/feed/presentation/components/filter_friend_button.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';
import 'package:locket_app/modules/history/presentation/pages/history_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  final PageController _pageController = PageController();
  bool _isReplying = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleButton(icon: Icons.person_outline_rounded),
                      FilterFriendButton(),
                      CircleButton(icon: Icons.chat_bubble_outline_rounded),
                    ],
                  ),
                ),
                Expanded(
                  child: FeedArea(
                    onUserChanged: _handleUserChanged,
                    controller: _pageController,
                    highlightedIndex: _highlightedIndex,
                  ),
                ),
                _buildCommentBar(),
                BottomNav(onHistoryTap: _openHistory),
              ],
            ),
          ),
          if (_isReplying) _buildReplyOverlay(),
        ],
      ),
    );
  }

  void _handleUserChanged(String userName) {
    if (_currentUser == userName) {
      return;
    }

    setState(() {
      _currentUser = userName;
    });
  }

  Future<void> _openHistory() async {
    final selectedIndex = await Navigator.of(
      context,
    ).push<int>(MaterialPageRoute(builder: (_) => const HistoryPage()));

    if (!mounted || selectedIndex == null || feedItems.isEmpty) {
      return;
    }

    final safeIndex = selectedIndex.clamp(0, feedItems.length - 1).toInt();

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
                  'Gửi tin nhắn...',
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
                  hintText: 'Trả lời $_currentUser...',
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
