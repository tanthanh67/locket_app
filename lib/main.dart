import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locket_app/modules/friends/data/repositories/friends_repository_impl.dart';
import 'package:locket_app/modules/friends/domain/repository/friends_repository.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friends_cubit.dart';
import 'package:locket_app/modules/feed/data/repositories/feed_repository_impl.dart';
import 'package:locket_app/modules/feed/domain/repository/feed_repository.dart';
import 'package:locket_app/modules/feed/presentation/application/cubit/feed_cubit.dart';

// Core
import 'core/constants/app_colors.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/gemini_service.dart';

// Auth Module
import 'modules/auth/domain/repository/auth_repository.dart'; // Import Interface
import 'modules/auth/data/repositories/auth_repository_impl.dart';
import 'modules/auth/presentation/application/cubit/auth_cubit.dart';

// Camera Module
import 'modules/camera/domain/repository/camera_repository.dart'; // Import Interface
import 'modules/camera/data/repositories/camera_repository_impl.dart';
import 'modules/camera/presentation/application/cubit/camera_cubit.dart';

// App Root
import 'modules/app/presentation/app_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  final authRepo = AuthRepositoryImpl();
  final cloudinaryService = CloudinaryService();
  final geminiService = GeminiService();

  // Khởi tạo repo camera
  final cameraRepo = CameraRepositoryImpl(cloudinaryService, geminiService);
  final friendsRepo = FriendsRepositoryImpl();
  final feedRepo = FeedRepositoryImpl();

  runApp(
    MultiRepositoryProvider(
      providers: [
        // SỬA Ở ĐÂY: Dùng kiểu AuthRepository thay vì AuthRepositoryImpl
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        // SỬA Ở ĐÂY: Dùng kiểu CameraRepository thay vì CameraRepositoryImpl
        RepositoryProvider<CameraRepository>.value(value: cameraRepo),
        RepositoryProvider<FriendsRepository>.value(value: friendsRepo),
        RepositoryProvider<FeedRepository>.value(value: feedRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>())..monitorAuthState(),
          ),
          BlocProvider(
            create: (context) => CameraCubit(context.read<CameraRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                FriendsCubit(context.read<FriendsRepository>()),
          ),
          BlocProvider(
            create: (context) => FeedCubit(context.read<FeedRepository>()),
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
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      home: const AppRoot(),
    );
  }
}
