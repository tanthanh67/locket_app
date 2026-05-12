import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final VoidCallback? onHistoryTap;
  final VoidCallback? onCameraTap;

  const BottomNav({super.key, this.onHistoryTap, this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Grid 2x2 icon
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onHistoryTap,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          // Nút chụp / đăng story (có viền vàng)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCameraTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 3),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Nút "..."
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
