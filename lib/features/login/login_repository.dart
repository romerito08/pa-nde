import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar nuevo usuario
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String estado,
    required String municipio,
  }) async {
    try {
      // 1. Crear el usuario en Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = credential.user;

      // 2. Si el usuario se creó correctamente, guardamos sus datos en Firestore
      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nombre': nombre,
          'apellido': apellido,
          'correo': email,
          'estado': estado,
          'municipio': municipio,
          'createdAt': FieldValue.serverTimestamp(), // Fecha de creación automática
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en registro Auth: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error guardando en Firestore: $e');
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