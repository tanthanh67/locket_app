import 'package:flutter/material.dart';
import 'package:locket_app/modules/camera/presentation/pages/camera_page.dart';
import 'package:locket_app/modules/feed/presentation/pages/feed_page.dart';
import 'package:locket_app/modules/friends/presentation/pages/friends_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // initialPage: 1 (Ở giữa là Camera)
  final PageController _horizontalController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _horizontalController,
        children: [
          const Center(child: Text("Chat Screen")), // Page 0: Bên trái
          _buildVerticalNavigation(), // Page 1: Ở giữa (Camera + Feed)
          const FriendsPage(), // Page 2: Bên phải
        ],
      ),
    );
  }

  Widget _buildVerticalNavigation() {
    return PageView(
      scrollDirection: Axis.vertical,
      children: [
        const CameraPage(), // Vuốt lên/xuống giữa Camera và Feed
        const FeedPage(),
      ],
    );
  }
}
