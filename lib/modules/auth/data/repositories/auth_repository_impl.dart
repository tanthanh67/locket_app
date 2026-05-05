import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lắng nghe thay đổi trạng thái đăng nhập từ Firebase
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kiểm tra xem đã xác thực mail chưa
    if (!cred.user!.emailVerified) {
      await _auth.signOut(); // Đăng xuất lại nếu chưa xác thực
      throw Exception("Please verify your email in Gmail first!");
    }
  }

  @override
  Future<void> signUpAndSave(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      // 1. Gửi mail xác thực
      await cred.user!.sendEmailVerification();
      // 2. Lưu thông tin vào Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'displayName': name,
        'email': email,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Lưu ý: Không SignOut ở đây để AppRoot có thể giữ User ở màn hình Waiting
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Làm mới dữ liệu từ server
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Hàm bổ trợ để xử lý các lỗi thường gặp của Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'invalid-email':
        return "The email address is not valid.";
      case 'weak-password':
        return "The password is too weak.";
      default:
        return e.message ?? "An unknown error occurred.";
    }
  }
}
