// lib/modules/auth/data/data_sources/firebase_auth_data_source.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Vẫn cần Firestore cho các tác vụ lưu trữ data user

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<void> reloadCurrentUser();
  User? getCurrentUser();
  // Thêm các phương thức khác nếu cần (ví dụ: verifyPhoneNumber, confirmOTP)
}

class FirebaseAuthDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore; // Cần để lưu info user sau sign up

  FirebaseAuthDataSource(this._auth, this._firestore);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
