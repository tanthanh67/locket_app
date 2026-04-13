import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:locket_app/home_page.dart';
import 'firebase_options.dart'; // File này do CLI tự tạo
import 'login_page.dart';

void main() async {
  // Bắt buộc phải có để khởi tạo Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo kết nối với Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        // Lắng nghe trạng thái đăng nhập của Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Nếu snapshot có dữ liệu (user khác null) nghĩa là đã đăng nhập
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Ngược lại, bắt đăng nhập
          return const LoginPage();
        },
      ),
    );
  }
}
