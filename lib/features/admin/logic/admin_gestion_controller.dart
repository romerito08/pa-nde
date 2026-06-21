import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../data/admin_repository.dart';

/// Controlador en tiempo real para gestión de usuarios y publicaciones
/// pendientes de aprobación. Usa streams de Firestore para mantenerse
/// actualizado sin recargas manuales.
class AdminGestionController extends ChangeNotifier {
  final AdminRepository _repository;

  StreamSubscription<List<Usuario>>? _usuariosSub;
  StreamSubscription<List<Servicio>>? _pendientesSub;
  StreamSubscription<List<Servicio>>? _activosSub;
  StreamSubscription<List<Servicio>>? _pausadosSub;

  List<Usuario> _usuarios = [];
  List<Servicio> _pendientes = [];
  List<Servicio> _activos = [];
  List<Servicio> _pausados = [];
  bool _cargando = true;
  String? _error;

  AdminGestionController({AdminRepository? repository})
      : _repository = repository ?? AdminRepository() {
    _escuchar();
  }

  List<Usuario> get usuarios => _usuarios;
  List<Servicio> get pendientes => _pendientes;
  List<Servicio> get activos => _activos;
  List<Servicio> get pausados => _pausados;
  bool get cargando => _cargando;
  String? get error => _error;

  List<Usuario> get exploradores =>
      _usuarios.where((u) => u.rol == RolesUsuario.explorador).toList();

  List<Usuario> get aliados =>
      _usuarios.where((u) => u.rol == RolesUsuario.aliado).toList();

  void _escuchar() {
    _cargando = true;
    _usuariosSub = _repository.todosLosUsuarios().listen(
      (lista) {
        _usuarios = lista;
        _cargando = false;
        notifyListeners();
      },
      onError: (_) {
        _cargando = false;
        _error = 'No pudimos cargar los usuarios. Verifica tu conexión.';
        notifyListeners();
      },
    );
    _pendientesSub = _repository.serviciosPendientes().listen(
      (lista) { _pendientes = lista; notifyListeners(); },
      onError: (_) {},
    );
    _activosSub = _repository.serviciosActivos().listen(
      (lista) { _activos = lista; notifyListeners(); },
      onError: (_) {},
    );
    _pausadosSub = _repository.serviciosPausados().listen(
      (lista) { _pausados = lista; notifyListeners(); },
      onError: (_) {},
    );
  }

  Future<String?> bloquear(String uid) async {
    try {
      await _repository.bloquearUsuario(uid, bloqueado: true);
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    }
  }

  Future<String?> desbloquear(String uid) async {
    try {
      await _repository.bloquearUsuario(uid, bloqueado: false);
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    }
  }

  Future<String?> aprobar(String servicioId) async {
    try {
      await _repository.aprobarPublicacion(servicioId);
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    }
  }

  Future<String?> rechazar(String servicioId, {String motivo = ''}) async {
    try {
      await _repository.rechazarPublicacion(servicioId, motivo: motivo);
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    }
  }

  Future<String?> suspender(String servicioId, {String motivo = ''}) async {
    try {
      await _repository.suspenderPublicacion(servicioId, motivo: motivo);
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    }
  }

  @override
  void dispose() {
    _usuariosSub?.cancel();
    _pendientesSub?.cancel();
    _activosSub?.cancel();
    _pausadosSub?.cancel();
    super.dispose();
  }
}
