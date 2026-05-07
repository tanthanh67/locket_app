import 'package:flutter/material.dart';
import 'package:locket_app/modules/friends/presentation/pages/friend_list_page.dart';
import 'package:locket_app/modules/friends/presentation/pages/search_user_page.dart';
import 'package:locket_app/modules/friends/presentation/pages/friend_request_page.dart';
import '../../../../core/constants/app_colors.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchUserPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      // ================= APPBAR FIX =================
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,

        // 🔥 FIX ANDROID HEIGHT
        toolbarHeight: 60,

        titleSpacing: 12,

        title: const Text(
          "Friends",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),

          child: Column(
            children: [
              // ================= SEARCH BAR =================
              GestureDetector(
                onTap: openSearch,
                child: Container(
                  height: 48, // 🔥 FIX HEIGHT CONSISTENCY

                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),

                  padding: const EdgeInsets.symmetric(horizontal: 12),

                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.primary),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Search friends or users...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15, // 🔥 TO RÕ TRÊN ANDROID
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= TABS =================
              Container(
                height: 44, // 🔥 FIX HEIGHT

                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                padding: const EdgeInsets.all(4),

                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: TabBar(
                  controller: _tab,

                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,

                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),

                  unselectedLabelStyle: const TextStyle(fontSize: 13),

                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,

                  tabs: const [
                    Tab(text: "Friends"),
                    Tab(text: "Requests"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= BODY =================
      body: TabBarView(
        controller: _tab,
        children: const [FriendListPage(), FriendRequestPage()],
      ),
    );
  }
}
