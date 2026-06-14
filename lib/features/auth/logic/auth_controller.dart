import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/app_navigator.dart';
import '../../../models/usuario.dart';
import '../data/auth_repository.dart';

/// Controlador de estado global de sesión (Provider/ChangeNotifier).
/// Mantiene el perfil del usuario autenticado y notifica a toda la UI
/// (header, drawer, pantallas protegidas) cuando la sesión cambia.
///
/// Además, escucha en tiempo real el documento de Firestore del usuario
/// activo y lo fuerza a cerrar sesión si el administrador activa el
/// campo `bloqueado`, independientemente de si acababa de iniciar sesión
/// o llevaba horas en la app.
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<User?>? _suscripcionAuth;
  StreamSubscription<Usuario?>? _perfilSub;

  Usuario? _usuario;
  bool _cargando = false;
  bool _sesionVerificada = false;
  String? _error;
  bool _esBloqueado = false;

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
  bool get esBloqueado => _esBloqueado;

  bool get esAliado => _usuario?.esAliado ?? false;
  bool get esAdministrador => _usuario?.esAdministrador ?? false;

  Future<void> _alCambiarSesion(User? user) async {
    // Cancela el listener de perfil anterior (si existe) antes de procesar
    // el nuevo estado de sesión, para no dejar suscripciones huérfanas.
    await _perfilSub?.cancel();
    _perfilSub = null;

    if (user == null) {
      _usuario = null;
      _sesionVerificada = true;
      notifyListeners();
      return;
    }

    // Carga inicial del perfil (única llamada; a partir de aquí el stream
    // mantiene el perfil sincronizado en tiempo real).
    try {
      final perfil = await _repository.obtenerPerfil(user.uid);

      // Caso: usuario bloqueado mientras estaba offline o en otra sesión.
      // Se detecta aquí antes de siquiera mostrar la app.
      if (perfil.bloqueado) {
        await _forzarCierrePorBloqueo();
        return;
      }

      _usuario = perfil;
    } on AppException catch (e) {
      _error = e.mensaje;
      _usuario = null;
      _sesionVerificada = true;
      notifyListeners();
      return;
    }

    _sesionVerificada = true;
    notifyListeners();

    // Inicia el stream en tiempo real para detectar bloqueos mientras el
    // usuario está activo. La primera emisión repite el estado actual (sin
    // efecto porque aún no está bloqueado); las siguientes reflejan cambios
    // hechos por el administrador desde el panel.
    _perfilSub = _repository.perfilStream(user.uid).listen(
      (perfil) {
        if (perfil == null) return;
        if (perfil.bloqueado && _usuario != null) {
          // El administrador bloqueó la cuenta mientras estaba activa.
          _forzarCierrePorBloqueo();
        } else if (!perfil.bloqueado) {
          // Actualización normal del perfil (nombre, teléfono, etc.).
          _usuario = perfil;
          notifyListeners();
        }
      },
      onError: (_) {}, // Errores de red no cierran la sesión activa.
    );
  }

  /// Cierra la sesión de forma forzada cuando el administrador bloquea la
  /// cuenta. Cancela el stream de perfil antes de llamar a Firebase para
  /// evitar que el mismo evento dispare una segunda ejecución, y navega a
  /// la pantalla de login con un mensaje descriptivo.
  Future<void> _forzarCierrePorBloqueo() async {
    await _perfilSub?.cancel();
    _perfilSub = null;

    _error =
        'Tu cuenta ha sido suspendida por el administrador. '
        'Contacta a soporte para más información.';
    _usuario = null;
    _sesionVerificada = true;
    notifyListeners();

    try {
      await _repository.cerrarSesion();
    } catch (_) {}

    // Navega a la pantalla de cuenta bloqueada eliminando todo el historial
    // de rutas, de modo que el usuario no pueda volver atrás.
    appNavigatorKey.currentState
        ?.pushNamedAndRemoveUntil(AppRoutes.cuentaBloqueada, (route) => false);
  }

  /// Inicia sesión. Devuelve `true` si fue exitoso.
  /// Si la cuenta está bloqueada, [esBloqueado] queda en `true` para que
  /// la pantalla pueda navegar a la ruta correspondiente.
  /// Para cualquier otro error, [error] contiene el mensaje.
  Future<bool> iniciarSesion(String correo, String contrasena) async {
    _iniciarCarga();
    _esBloqueado = false;
    try {
      _usuario = await _repository.iniciarSesion(correo.trim(), contrasena);
      _finalizarCarga();
      return true;
    } on AppException catch (e) {
      _error = e.mensaje;
      _esBloqueado = e.esBloqueado;
      _finalizarCarga();
      return false;
    }
  }

  /// Registra una cuenta nueva con su rol y deja la sesión iniciada.
  /// Para Exploradores, el repositorio bloquea el envío a Firebase Auth si
  /// el correo no es institucional UNIMET (validación RegEx de servidor).
  Future<bool> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    required String telefono,
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
        telefono: telefono.trim(),
        estado: estado,
        municipio: municipio,
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

  /// Modificación de perfil (Explorador y Aliado): persiste en `usuarios`
  /// vía repositorio y refresca el estado global para toda la UI.
  Future<bool> actualizarPerfil({
    required String nombre,
    required String apellido,
    required String telefono,
    required String estado,
    required String municipio,
    String? paypalEmail,
  }) async {
    final actual = _usuario;
    if (actual == null) {
      _error = 'Inicia sesión para editar tu perfil.';
      notifyListeners();
      return false;
    }
    _iniciarCarga();
    try {
      _usuario = await _repository.actualizarPerfil(
        actual.copyWith(
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          estado: estado,
          municipio: municipio,
          paypalEmail: paypalEmail,
        ),
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
    return '/inicio';
  }

  void _iniciarCarga() {
    _cargando = true;
    _error = null;
    _esBloqueado = false;
    notifyListeners();
  }

  void _finalizarCarga() {
    _cargando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcionAuth?.cancel();
    _perfilSub?.cancel();
    super.dispose();
  }
}
