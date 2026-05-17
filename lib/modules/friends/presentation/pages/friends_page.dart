import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../application/cubit/friends_cubit.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: BlocBuilder<FriendsCubit, FriendsState>(
                builder: (context, state) {
                  if (state is FriendsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (state is FriendsLoaded) {
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (state.searchResults.isNotEmpty) ...[
                          _buildSectionTitle("SEARCH RESULTS"),
                          ...state.searchResults.map(
                            (u) => _buildUserTile(
                              context,
                              u,
                              isSearch: true,
                              isRequestSent: state.sentRequestIds.contains(
                                u.uid,
                              ),
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 40),
                        ],
                        if (state.pendingRequests.isNotEmpty) ...[
                          _buildSectionTitle("FRIEND REQUESTS"),
                          ...state.pendingRequests.map(
                            (r) => _buildRequestTile(context, r),
                          ),
                          const SizedBox(height: 20),
                        ],
                        _buildSectionTitle(
                          "FRIENDS (${state.myFriends.length})",
                        ),
                        ...state.myFriends.map(
                          (u) => _buildUserTile(context, u),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (val) => context.read<FriendsCubit>().search(val),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search by email...",
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    user, {
    bool isSearch = false,
    bool isRequestSent = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, color: Colors.black),
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        user.email,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
      trailing: isSearch
          ? ElevatedButton(
              onPressed: isRequestSent
                  ? null
                  : () => context.read<FriendsCubit>().sendRequest(user.uid),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRequestSent
                    ? AppColors.card
                    : AppColors.primary,
                disabledBackgroundColor: AppColors.card,
                shape: const StadiumBorder(),
              ),
              child: Text(
                isRequestSent ? "Sent" : "Add",
                style: TextStyle(
                  color: isRequestSent ? AppColors.textGrey : Colors.black,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }

  Widget _buildRequestTile(BuildContext context, Map<String, dynamic> request) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Friend request",
        style: TextStyle(color: Colors.white),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 30,
            ),
            onPressed: () => context.read<FriendsCubit>().accept(
              request['id'],
              request['senderId'],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white24),
            onPressed: () =>
                context.read<FriendsCubit>().deleteRequest(request['id']),
          ),
        ],
      ),
    );
  }
}
