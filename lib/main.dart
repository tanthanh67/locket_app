import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Services
import 'core/services/auth_service.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/gemini_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Modules (Giả định bạn đã tạo các Repository)
import 'modules/app/presentation/app_root.dart';
// import 'modules/auth/repository/auth_repository.dart';
// import 'modules/camera/repository/camera_repository.dart';
// import 'modules/home/repository/home_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // 1. Khởi tạo Services
  final authService = AuthService();
  final cloudinaryService = CloudinaryService();
  final geminiService = GeminiService();

  // 2. Khởi tạo Repositories (Truyền Service vào)
  // final authRepo = AuthRepository(authService);
  // final cameraRepo = CameraRepository(cloudinaryService, geminiService);
  // final homeRepo = HomeRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        // RepositoryProvider.value(value: authRepo),
        // RepositoryProvider.value(value: cameraRepo),
        // RepositoryProvider.value(value: homeRepo),
      ],
      child: const AppRoot(), // AppRoot sẽ chứa MultiBlocProvider bên trong
    ),
  );
}
