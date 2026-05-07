import 'package:flutter/material.dart';
import 'package:locket_app/modules/friends/presentation/pages/friend_profile_page.dart';
import '../../../../core/domain/entities/user_entity.dart';

import '../../../../core/constants/app_colors.dart';

class FriendTile extends StatelessWidget {
  final UserEntity user;

  const FriendTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FriendProfilePage(uid: user.uid)),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : "?",
                style: const TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
