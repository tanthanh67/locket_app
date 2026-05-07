import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Auth
import 'package:locket_app/modules/auth/presentation/application/cubit/auth_cubit.dart';

// Friend Page
import 'package:locket_app/modules/friends/presentation/pages/friend_page.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to switch account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          // ================= FRIEND =================
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendPage()),
              );
            },
          ),

          // ================= SWITCH ACCOUNT =================
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "logout") {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "logout",
                child: Text("Switch account"),
              ),
            ],
          ),
        ],
      ),

      body: const Center(
        child: Text('Feed Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
