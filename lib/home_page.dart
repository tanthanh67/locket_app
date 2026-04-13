import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ Firebase
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Locket Home Test"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Đăng xuất cả Firebase và Google
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🎉 ĐĂNG NHẬP THÀNH CÔNG!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Hiển thị ảnh đại diện nếu có (từ Google)
            if (user?.photoURL != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            const SizedBox(height: 10),
            Text("Tên: ${user?.displayName ?? 'Người dùng Email'}"),
            Text("Email: ${user?.email}"),
            const SizedBox(height: 30),
            const Text(
              "Bây giờ bạn có thể bắt đầu làm tính năng Locket rồi đó!",
            ),
          ],
        ),
      ),
    );
  }
}
