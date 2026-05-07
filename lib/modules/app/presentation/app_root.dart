import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:locket_app/modules/feed/presentation/pages/feed_page.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friend_cubit.dart';

import '../../auth/presentation/application/cubit/auth_cubit.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/waiting_verification_page.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _initialized = false;

  void _initFriend() {
    if (_initialized) return;
    _initialized = true;

    final friendCubit = context.read<FriendCubit>();

    friendCubit.loadFriends();
    friendCubit.loadIncomingRequests(); // 🔥 THÊM DÒNG NÀY
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initFriend();
          });
        }

        if (state is Unauthenticated) {
          _initialized = false;
        }
      },

      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            if (state.user.emailVerified) {
              return const FeedPage();
            }
            return const WaitingVerificationPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
