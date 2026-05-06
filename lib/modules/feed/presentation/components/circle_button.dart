import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const CircleButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1C),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2A2A28), width: 0.5),
      ),
      child: Icon(icon, size: 24),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: content,
      ),
    );
  }
}
