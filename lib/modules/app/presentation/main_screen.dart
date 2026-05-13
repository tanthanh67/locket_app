import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/camera/presentation/pages/camera_page.dart';
import 'package:locket_app/modules/feed/presentation/components/feed_top_bar.dart';
import 'package:locket_app/modules/feed/presentation/application/cubit/feed_cubit.dart';
import 'package:locket_app/modules/feed/presentation/pages/feed_page.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friends_cubit.dart';
import 'package:locket_app/modules/friends/presentation/pages/friends_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _verticalController = PageController();
  int _verticalPage = 0;
  String _selectedFriend = 'All friends';

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildVerticalNavigation(),
    );
  }

  Widget _buildVerticalNavigation() {
    return Stack(
      children: [
        PageView(
          controller: _verticalController,
          onPageChanged: (page) {
            setState(() {
              _verticalPage = page;
            });
          },
          scrollDirection: Axis.vertical,
          children: [
            CameraPage(onShowFeed: _showFeed),
            FeedPage(onCameraTap: _showCamera, selectedFriend: _selectedFriend),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(bottom: false, child: _buildFixedTopBar()),
        ),
      ],
    );
  }

  Widget _buildFixedTopBar() {
    return _verticalPage == 0 ? _buildCameraTopBar() : _buildFeedTopBar();
  }

  Widget _buildCameraTopBar() {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        final count = state is FriendsLoaded ? state.myFriends.length : 0;
        final label = '$count ${count == 1 ? 'Friend' : 'Friends'}';

        return FeedTopBar(centerLabel: label, onCenterTap: _openFriends);
      },
    );
  }

  Widget _buildFeedTopBar() {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        final options = _friendFilterOptions(state);
        final selected = options.contains(_selectedFriend)
            ? _selectedFriend
            : 'All friends';

        return FeedTopBar(
          filterOptions: options,
          selectedFilter: selected,
          onFilterChanged: (friend) {
            setState(() {
              _selectedFriend = friend;
            });
          },
        );
      },
    );
  }

  List<String> _friendFilterOptions(FeedState state) {
    final names = state.items.map((item) => item.userName).toSet().toList()
      ..sort();
    return ['All friends', ...names];
  }

  Future<void> _showCamera() {
    return _verticalController.animateToPage(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _showFeed() {
    return _verticalController.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openFriends() {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FriendsPage()));
  }
}
