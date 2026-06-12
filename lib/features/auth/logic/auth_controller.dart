import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/usuario.dart';
import '../data/auth_repository.dart';

/// Controlador de estado global de sesión (Provider/ChangeNotifier).
/// Mantiene el perfil del usuario autenticado y notifica a toda la UI
/// (header, drawer, pantallas protegidas) cuando la sesión cambia.
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<User?>? _suscripcionAuth;

  Usuario? _usuario;
  bool _cargando = false;
  bool _sesionVerificada = false;
  String? _error;

  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    // Reacciona a inicios/cierres de sesión externos (p. ej. otra pestaña web)
    // y restaura la sesión persistida al abrir la app.
    _suscripcionAuth = _repository.authStateChanges.listen(_alCambiarSesion);
  }

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  bool get sesionVerificada => _sesionVerificada;
  bool get autenticado => _usuario != null;
  String? get error => _error;

  bool get esAliado => _usuario?.esAliado ?? false;
  bool get esAdministrador => _usuario?.esAdministrador ?? false;

  Future<void> _alCambiarSesion(User? user) async {
    if (user == null) {
      _usuario = null;
      _sesionVerificada = true;
      notifyListeners();
      return;
    }
    try {
      _usuario = await _repository.obtenerPerfil(user.uid);
    } on AppException catch (e) {
      _error = e.mensaje;
      _usuario = null;
    }
    _sesionVerificada = true;
    notifyListeners();
  }

  /// Inicia sesión. Devuelve `true` si fue exitoso; en caso contrario deja
  /// el mensaje amigable en [error] para que la UI lo muestre en un SnackBar.
  Future<bool> iniciarSesion(String correo, String contrasena) async {
    _iniciarCarga();
    try {
      _usuario = await _repository.iniciarSesion(correo.trim(), contrasena);
      _finalizarCarga();
      return true;
    } on AppException catch (e) {
      _error = e.mensaje;
      _finalizarCarga();
      return false;
    }
  }

  /// Registra una cuenta nueva con su rol y deja la sesión iniciada.
  Future<bool> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    required String estado,
    required String municipio,
    required String rol,
  }) async {
    _iniciarCarga();
    try {
      _usuario = await _repository.registrar(
        correo: correo.trim(),
        contrasena: contrasena,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        estado: estado.trim(),
        municipio: municipio.trim(),
        rol: rol,
      );
      _finalizarCarga();
      return true;
    } on AppException catch (e) {
      _error = e.mensaje;
      _finalizarCarga();
      return false;
    }
  }

  Future<bool> cerrarSesion() async {
    try {
      await _repository.cerrarSesion();
      _usuario = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  /// Ruta inicial según el rol autenticado (RF15).
  String get rutaSegunRol {
    if (esAdministrador) return '/admin';
    if (esAliado) return '/aliado';
    return '/';
  }

  void _iniciarCarga() {
    _cargando = true;
    _error = null;
    notifyListeners();
  }

  void _finalizarCarga() {
    _cargando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcionAuth?.cancel();
    super.dispose();
  }
}
