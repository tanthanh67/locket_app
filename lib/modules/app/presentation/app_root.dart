import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/app/presentation/main_screen.dart';
import '../../auth/presentation/application/cubit/auth_cubit.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/waiting_verification_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          Authenticated(user: var user) =>
            user.emailVerified
                ? const MainScreen()
                : const WaitingVerificationPage(),
          Unauthenticated() || AuthError() => const LoginPage(),
          AuthInitial() || AuthLoading() => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD233)),
            ),
          ),
        };
      },
    );
  }
}
