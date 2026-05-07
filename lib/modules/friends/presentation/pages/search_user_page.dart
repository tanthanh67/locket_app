import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../application/cubit/friend_cubit.dart';
import '../application/cubit/friend_state.dart';
import '../widgets/user_tile.dart';
import 'friend_profile_page.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final controller = TextEditingController();
  Timer? _debounce;

  void onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<FriendCubit>().search(value);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Add Friends"),
        backgroundColor: AppColors.background,
      ),

      body: Column(
        children: [
          // ================= SEARCH BOX =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search name or email...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: BlocBuilder<FriendCubit, FriendState>(
              builder: (context, state) {
                if (state is FriendSearchLoaded) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text(
                        "No users found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (_, i) {
                      final user = state.users[i];

                      return UserTile(
                        user: user,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FriendProfilePage(uid: user.uid),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const Center(
                  child: Text(
                    "Search for friends",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
