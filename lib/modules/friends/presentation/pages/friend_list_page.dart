import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/cubit/friend_cubit.dart';
import '../application/cubit/friend_state.dart';
import '../widgets/friend_tile.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  @override
  void initState() {
    super.initState();

    // ✅ chỉ chạy 1 lần
    Future.microtask(() {
      context.read<FriendCubit>().loadFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendCubit, FriendState>(
      builder: (context, state) {
        // ================= LOADING =================
        if (state is FriendLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ================= FRIEND LIST =================
        if (state is FriendLoaded) {
          if (state.friends.isEmpty) {
            return const Center(
              child: Text(
                "No friends yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              return FriendTile(user: state.friends[i]);
            },
          );
        }

        // ================= DEFAULT =================
        return const Center(
          child: Text(
            "Loading friends...",
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
