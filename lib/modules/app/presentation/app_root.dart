import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/feed/presentation/pages/feed_page.dart';
import '../../auth/presentation/application/cubit/auth_cubit.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/waiting_verification_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Nếu đã xác thực mail -> Vào Feed
          if (state.user.emailVerified) return const FeedPage();

          // Nếu chưa xác thực -> Hiện màn hình chờ (Waiting)
          return const WaitingVerificationPage();
        }
        return const LoginPage();
      },
    );
  }
}

// Trang tạm thời để test nút Đăng xuất
class DummyFeedPage extends StatelessWidget {
  const DummyFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Locket Gold Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: const Center(child: Text("Chào mừng bạn đã vào App!")),
    );
  }
}
