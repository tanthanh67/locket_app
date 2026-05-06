import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/auth/presentation/application/cubit/auth_cubit.dart';

class WaitingVerificationPage extends StatelessWidget {
  const WaitingVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.email_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              "Verify your email",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We've sent a link to your Gmail. Please click it to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 48),

            // Nút "Đã xác thực" -> Sẽ về màn hình Login
            _buildButton("I've Verified", AppColors.primary, () {
              context.read<AuthCubit>().checkEmailVerification();
            }),

            const SizedBox(height: 16),

            // Nút "Gửi lại"
            TextButton(
              onPressed: () => context.read<AuthCubit>().resendEmail(),
              child: const Text(
                "Resend Email",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
