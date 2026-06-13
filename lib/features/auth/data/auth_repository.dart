import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/data/venezuela_geo.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/validadores.dart';
import '../../../models/usuario.dart';

/// Capa de datos del módulo de autenticación (RF01/RF15).
/// Encapsula Firebase Auth + la colección `usuarios` de Firestore, valida
/// el correo institucional UNIMET de los Exploradores antes de tocar
/// Firebase Authentication y traduce los errores técnicos a mensajes
/// amigables (RNF03).
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
  /// segregando el rol (Explorador desde /registro, Aliado desde la página
  /// "Sé un Aliado" de la Landing).
  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    required String telefono,
    required String estado,
    required String municipio,
    required String rol,
  }) async {
    // Guardas de servidor: se ejecutan SIEMPRE antes de llamar a Firebase
    // Authentication, aunque el cliente haya sido manipulado.
    if (!RolesUsuario.registrables.contains(rol)) {
      throw const AppException('El rol seleccionado no es válido.');
    }
    if (rol == RolesUsuario.explorador &&
        !Validadores.esCorreoUnimet(correo)) {
      // Bloqueo del envío a Firebase Auth (validación institucional).
      throw const AppException(
          'Los Exploradores deben registrarse con su correo institucional '
          'UNIMET: debe terminar en @unimet.edu.ve o @correo.unimet.edu.ve.');
    }
    if (!Validadores.esCorreoValido(correo)) {
      throw const AppException('El formato del correo electrónico no es válido.');
    }
    if (!VenezuelaGeo.esUbicacionValida(estado, municipio)) {
      throw const AppException(
          'Selecciona un Estado y Municipio válidos de la lista oficial.');
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
        telefono: telefono,
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
        telefono: '',
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

  /// Modificación real del perfil (Explorador y Aliado): impacta el
  /// documento de la colección `usuarios` y devuelve el perfil actualizado.
  Future<Usuario> actualizarPerfil(Usuario usuario) async {
    if (usuario.nombre.trim().isEmpty || usuario.apellido.trim().isEmpty) {
      throw const AppException('El nombre y el apellido son obligatorios.');
    }
    if (usuario.telefono.trim().isNotEmpty &&
        !Validadores.esTelefonoValido(usuario.telefono)) {
      throw const AppException(
          'El teléfono no es válido. Usa el formato 0414-1234567 o +58 414 1234567.');
    }
    if (!VenezuelaGeo.esUbicacionValida(usuario.estado, usuario.municipio)) {
      throw const AppException(
          'Selecciona un Estado y Municipio válidos de la lista oficial.');
    }
    try {
      await _firestore.collection('usuarios').doc(usuario.uid).update({
        'nombre': usuario.nombre.trim(),
        'apellido': usuario.apellido.trim(),
        'telefono': usuario.telefono.trim(),
        'estado': usuario.estado,
        'municipio': usuario.municipio,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      return usuario;
    } catch (_) {
      throw const AppException(
          'No pudimos guardar los cambios de tu perfil. Intenta de nuevo.');
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
