import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Đăng nhập bằng Email & Password
  Future<void> signIn(String email, String password);

  // Đăng ký, gửi Email xác thực và lưu thông tin vào Firestore
  Future<void> signUpAndSave(String email, String password, String name);

  // Kiểm tra xem người dùng đã click vào link trong Gmail chưa
  Future<bool> checkEmailVerified();

  // Gửi lại email xác thực nếu người dùng yêu cầu
  Future<void> resendVerificationEmail();

  // Đăng xuất
  Future<void> signOut();

  // Stream lắng nghe trạng thái đăng nhập (dùng cho Auto Login)
  Stream<User?> get authStateChanges;
}
