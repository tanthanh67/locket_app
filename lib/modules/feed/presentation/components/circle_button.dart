import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  const CircleButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1C),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2A2A28), width: 0.5),
      ),
      child: Icon(icon, size: 24),
    );
  }
}
