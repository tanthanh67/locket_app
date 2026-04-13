import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Biến để kiểm tra đang ở chế độ Đăng nhập hay Đăng ký
  bool isLogin = true;

  // --- HÀM XỬ LÝ EMAIL (ĐĂNG KÝ HOẶC ĐĂNG NHẬP) ---
  Future<void> handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    try {
      if (isLogin) {
        // CHẾ ĐỘ ĐĂNG NHẬP
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showMsg("✅ Đăng nhập thành công!");
      } else {
        // CHẾ ĐỘ ĐĂNG KÝ (TẠO TÀI KHOẢN MỚI)
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showMsg("✅ Tạo tài khoản thành công!");
      }
    } on FirebaseAuthException catch (e) {
      _showMsg("❌ Lỗi: ${e.message}");
    }
  }

  // --- HÀM ĐĂNG NHẬP GOOGLE (Tự động cả 2 chế độ) ---
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _showMsg("✅ Chào mừng ${googleUser.displayName}!");
    } catch (e) {
      _showMsg("❌ Lỗi Google: ${e.toString()}");
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.yellow),
            const SizedBox(height: 10),

            // Tiêu đề thay đổi theo chế độ
            Text(
              isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ TÀI KHOẢN",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Email"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Mật khẩu"),
            ),
            const SizedBox(height: 25),

            // Nút bấm chính
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: handleEmailAuth,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                child: Text(
                  isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ NGAY",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Nút chuyển đổi giữa Đăng ký và Đăng nhập
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin; // Đảo ngược trạng thái
                });
              },
              child: Text(
                isLogin
                    ? "Chưa có tài khoản? Đăng ký ngay"
                    : "Đã có tài khoản? Đăng nhập",
                style: const TextStyle(color: Colors.yellow),
              ),
            ),

            const Divider(color: Colors.grey, height: 40),

            // Nút Google
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 30),
                label: const Text("Tiếp tục với Google"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo giao diện ô nhập cho đẹp
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
