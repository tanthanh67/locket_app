import 'package:flutter/material.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/feed/presentation/components/circle_button.dart';
import 'package:locket_app/modules/feed/presentation/components/filter_friend_button.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';

class HistoryPage extends StatelessWidget {
  final List<FeedItem> items;

  const HistoryPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const FilterFriendButton(),
                  CircleButton(icon: Icons.chat_bubble_outline_rounded),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _HistoryTile(
                      imageUrl: item.imageUrl,
                      onTap: () => Navigator.of(context).pop(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _HistoryTile({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
