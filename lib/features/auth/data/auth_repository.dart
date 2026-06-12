import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/usuario.dart';

/// Capa de datos del módulo de autenticación (RF01/RF15).
/// Encapsula Firebase Auth + la colección `usuarios` de Firestore y traduce
/// los códigos de error técnicos a mensajes amigables (RNF03).
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get usuarioFirebase => _auth.currentUser;

  /// Inicia sesión y devuelve el perfil completo leído de `usuarios`.
  Future<Usuario> iniciarSesion(String correo, String contrasena) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      final user = credencial.user;
      if (user == null) {
        throw const AppException('No fue posible iniciar sesión. Intenta de nuevo.');
      }
      return await obtenerPerfil(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AppException(_traducirErrorAuth(e.code));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'Ocurrió un problema de conexión al iniciar sesión. Revisa tu internet e intenta otra vez.');
    }
  }

  /// Registra el usuario en Auth y crea su documento en `usuarios`
  /// segregando el rol elegido (Explorador o Aliado).
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    required String estado,
    required String municipio,
    required String rol,
  }) async {
    // Validación de servidor adicional: nunca permitir crear administradores
    // desde el formulario público, aunque el cliente haya sido manipulado.
    if (!RolesUsuario.registrables.contains(rol)) {
      throw const AppException('El rol seleccionado no es válido.');
    }
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      final user = credencial.user;
      if (user == null) {
        throw const AppException('No fue posible crear la cuenta. Intenta de nuevo.');
      }

      final usuario = Usuario(
        uid: user.uid,
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        estado: estado,
        municipio: municipio,
        rol: rol,
      );
      await _firestore.collection('usuarios').doc(user.uid).set(usuario.toMap());
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AppException(_traducirErrorAuth(e.code));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'Ocurrió un problema guardando tu perfil. Revisa tu conexión e intenta otra vez.');
    }
  }

  /// Lee el perfil de la colección `usuarios`. Si el documento no existe
  /// (cuentas antiguas), devuelve un perfil Explorador básico para no
  /// bloquear el acceso.
  Future<Usuario> obtenerPerfil(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Usuario.fromFirestore(doc.data()!, uid);
      }
      final user = _auth.currentUser;
      return Usuario(
        uid: uid,
        nombre: user?.displayName ?? 'Explorador',
        apellido: '',
        correo: user?.email ?? '',
        estado: '',
        municipio: '',
        rol: RolesUsuario.explorador,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos cargar tu perfil. Verifica tu conexión a internet.');
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw const AppException('No fue posible cerrar la sesión. Intenta de nuevo.');
    }
  }

  String _traducirErrorAuth(String codigo) {
    switch (codigo) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado. Inicia sesión o usa otro correo.';
      case 'weak-password':
        return 'La contraseña es muy débil: usa al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisa tu red e intenta otra vez.';
      default:
        return 'No fue posible completar la operación. Intenta nuevamente.';
    }
  }
}
