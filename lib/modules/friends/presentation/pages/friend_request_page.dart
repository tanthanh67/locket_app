import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/cubit/friend_cubit.dart';
import '../application/cubit/friend_state.dart';
import '../../../../core/constants/app_colors.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({super.key});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  @override
  void initState() {
    super.initState();

    // 🔥 đảm bảo load request realtime
    context.read<FriendCubit>().loadIncomingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      body: BlocBuilder<FriendCubit, FriendState>(
        builder: (context, state) {
          // ================= LOADING =================
          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= DATA =================
          if (state is FriendIncomingLoaded) {
            if (state.requests.isEmpty) {
              return const Center(
                child: Text(
                  "No friend requests",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final user = state.requests[i];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: [
                      // ================= AVATAR =================
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ================= INFO =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "wants to be your friend",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ================= ACTION =================
                      Row(
                        children: [
                          // ACCEPT
                          GestureDetector(
                            onTap: () {
                              context.read<FriendCubit>().accept(user.uid);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // REJECT
                          GestureDetector(
                            onTap: () {
                              context.read<FriendCubit>().reject(user.uid);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // ================= DEFAULT =================
          return const Center(
            child: Text(
              "Loading requests...",
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
