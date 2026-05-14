import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repository/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(AuthInitial());

  void monitorAuthState() {
    _repo.authStateChanges.listen((user) {
      if (user != null) {
        // Nếu tìm thấy phiên đăng nhập cũ, phát ra trạng thái Authenticated
        emit(Authenticated(user));
      } else {
        // Nếu không có, hoặc đã logout, phát ra trạng thái Unauthenticated
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      emit(AuthLoading());
      await _repo.signUpAndSave(email, password, name);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());
      await _repo.signIn(email, password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkVerificationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Làm mới dữ liệu

    if (user?.emailVerified ?? false) {
      await _repo.signOut(); // Đăng xuất
      emit(Unauthenticated()); // AppRoot sẽ tự nhảy về Login
    } else {
      emit(const AuthError("Bạn chưa xác thực Gmail!"));
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading()); // Hiển thị loading nhẹ trong lúc thoát
      await _repo.signOut();
      // Lưu ý: Chúng ta không cần emit(Unauthenticated()) ở đây
      // vì hàm monitorAuthState() đang lắng nghe Stream từ Firebase.
      // Khi signOut thành công, Stream sẽ tự bắn về null và Cubit tự emit Unauthenticated.
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateAccount({
    required String displayName,
    required String username,
  }) async {
    final updatedUser = await _repo.updateAccount(
      displayName: displayName,
      username: username,
    );
    emit(Authenticated(updatedUser));
  }

  // Kiểm tra xem đã xác thực chưa
  Future<void> checkEmailVerification() async {
    bool isVerified = await _repo.checkEmailVerified();
    if (isVerified) {
      await _repo.signOut(); // Đăng xuất để về màn hình Login theo yêu cầu
      emit(Unauthenticated());
    } else {
      emit(
        const AuthError(
          "Your email is not verified yet. Please check your Gmail.",
        ),
      );
    }
  }

  // Gửi lại email
  Future<void> resendEmail() async {
    try {
      await _repo.resendVerificationEmail();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
