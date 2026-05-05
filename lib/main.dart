import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import các lớp của bạn
import 'modules/auth/data/repositories/auth_repository_impl.dart';
import 'modules/auth/presentation/application/cubit/auth_cubit.dart';
import 'modules/app/presentation/app_root.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load biến môi trường (.env)
  await dotenv.load(fileName: ".env");

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp();

  // 3. Khởi tạo Repository thực tế
  final authRepo = AuthRepositoryImpl();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryImpl>.value(value: authRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          // Khởi tạo AuthCubit và bắt đầu theo dõi phiên đăng nhập ngay lập tức
          BlocProvider(
            create: (context) => AuthCubit(authRepo)..monitorAuthState(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locket Gold',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: 'Inter', // Hoặc font bạn đã cài
      ),
      home: const AppRoot(), // AppRoot sẽ quyết định hiện trang nào
    );
  }
}
