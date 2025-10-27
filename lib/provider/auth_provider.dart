import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

final securePasswordProvider = StateProvider<bool>((ref) => true);
final rememberMeProvider = StateProvider<bool>((ref) => false);

final authNotifierProvider =
AsyncNotifierProvider<AuthNotifier, User?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<User?> {
  late final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSub;

  @override
  Future<User?> build() async {
    _auth = FirebaseAuth.instance;

    _authSub = _auth.authStateChanges().listen((user) {
      state = AsyncData(user);
    });

    return _auth.currentUser;
  }

  Future<void> signInManual(
      String email,
      String password,
      {
        void Function(String message)? onSuccess,
        void Function(String message)? onError,
      }
  ) async {
    state = const AsyncLoading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      state = AsyncData(credential.user);
      onSuccess?.call('Login berhasil');
    } on FirebaseAuthException catch (e, st) {
      final message = e.message ?? 'Login gagal';
      state = AsyncError(Exception(message), st);
      onError?.call(message);
    }
  }

  Future<void> signUpManual(
      String email,
      String password
  ) async {
    state = const AsyncLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncData(credential.user);
    } on FirebaseAuthException catch (e, st) {
      String message = switch (e.code) {
        'email-already-in-use' => 'Email sudah digunakan',
        'invalid-email' => 'Format email tidak valid',
        'weak-password' => 'Password terlalu lemah',
        _ => e.message ?? 'Registrasi gagal',
      };
      state = AsyncError(Exception(message), st);
    }
  }

  Future<void> saveUserProfile(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await doc.set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> signOut() async {
    await _auth.signOut();

    state = const AsyncData(null);
  }

}
