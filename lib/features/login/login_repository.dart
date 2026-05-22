import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar nuevo usuario
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en registro: ${e.message}');
      return null;
    }
  }

  // Iniciar sesión
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en login: ${e.message}');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}