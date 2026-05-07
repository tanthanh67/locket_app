import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/domain/entities/user_entity.dart';

class UserTile extends StatelessWidget {
  final UserEntity user;
  final VoidCallback? onTap; // ✅ THÊM DÒNG NÀY

  const UserTile({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // ✅ enable click

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          children: [
            CircleAvatar(
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
