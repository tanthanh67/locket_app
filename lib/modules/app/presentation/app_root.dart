import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/app/presentation/main_screen.dart';
import 'package:locket_app/modules/feed/presentation/application/cubit/feed_cubit.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friends_cubit.dart';
import '../../auth/presentation/application/cubit/auth_cubit.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/waiting_verification_page.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String? _activeUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          Authenticated(user: var user) =>
            user.emailVerified
                ? _buildMainFor(user.uid)
                : _resetAndBuild(const WaitingVerificationPage()),
          Unauthenticated() || AuthError() => _resetAndBuild(const LoginPage()),
          AuthInitial() || AuthLoading() => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD233)),
            ),
          ),
        };
      },
    );
  }

  Widget _buildMainFor(String uid) {
    if (_activeUserId != uid) {
      _activeUserId = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        context.read<FriendsCubit>().initFriendsModule();
        context.read<FeedCubit>().watchFeed();
      });
    }

    return const MainScreen();
  }

  Widget _resetAndBuild(Widget child) {
    _activeUserId = null;
    return child;
  }
}
