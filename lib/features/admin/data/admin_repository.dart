import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/reserva.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';

/// Registro de una búsqueda hecha por los exploradores (colección
/// `busquedas`), usado para las tendencias del panel del Administrador.
class RegistroBusqueda {
  final String? estado;
  final String? municipio;
  final double? presupuestoMaximo;
  final DateTime creadoEn;

  final String? _ciudadAntigua;

  const RegistroBusqueda({
    required this.estado,
    required this.municipio,
    required this.presupuestoMaximo,
    required this.creadoEn,
    String? ciudadAntigua,
  }) : _ciudadAntigua = ciudadAntigua;

  /// Destino legible para agrupar tendencias: municipio si existe, luego
  /// estado; los documentos antiguos con 'ciudad' libre también se leen.
  String? get destino {
    final municipioOCiudad = municipio ?? _ciudadAntigua;
    if (municipioOCiudad != null && municipioOCiudad.trim().isNotEmpty) {
      return municipioOCiudad.trim();
    }
    if (estado != null && estado!.trim().isNotEmpty) return estado!.trim();
    return null;
  }

  factory RegistroBusqueda.fromFirestore(Map<String, dynamic> data) {
    return RegistroBusqueda(
      estado: data['estado'] as String?,
      municipio: data['municipio'] as String?,
      ciudadAntigua: data['ciudad'] as String?,
      presupuestoMaximo: (data['presupuestoMaximo'] as num?)?.toDouble(),
      creadoEn:
          (data['creadoEn'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}

/// Capa de datos del panel analítico del Administrador (RF12).
class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Búsquedas registradas en los últimos [dias] días.
  Future<List<RegistroBusqueda>> busquedasRecientes({int dias = 30}) async {
    try {
      final desde = DateTime.now().subtract(Duration(days: dias));
      final snapshot = await _firestore
          .collection('busquedas')
          .where('creadoEn', isGreaterThan: Timestamp.fromDate(desde))
          .get();
      return snapshot.docs
          .map((doc) => RegistroBusqueda.fromFirestore(doc.data()))
          .toList();
    } catch (_) {
      throw const AppException(
          'No pudimos cargar las tendencias de búsqueda. Verifica tu conexión.');
    }
  }

  Future<List<Reserva>> todasLasReservas() async {
    try {
      final snapshot = await _firestore.collection('reservas').get();
      return snapshot.docs
          .map((doc) => Reserva.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      throw const AppException(
          'No pudimos cargar las reservas globales. Verifica tu conexión.');
    }
  }

  Future<List<Servicio>> todosLosServicios() async {
    try {
      final snapshot = await _firestore.collection('servicios').get();
      return snapshot.docs
          .map((doc) => Servicio.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      throw const AppException(
          'No pudimos cargar los servicios globales. Verifica tu conexión.');
    }
  }

  Future<int> totalUsuarios() async {
    try {
      final agregado = await _firestore.collection('usuarios').count().get();
      return agregado.count ?? 0;
    } catch (_) {
      throw const AppException(
          'No pudimos contar los usuarios registrados. Verifica tu conexión.');
    }
  }

  /// Stream en tiempo real de todos los usuarios registrados.
  Stream<List<Usuario>> todosLosUsuarios() {
    return _firestore.collection('usuarios').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Usuario.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Servicio>> _streamPorEstado(String estado) {
    return _firestore
        .collection('servicios')
        .where('estadoPublicacion', isEqualTo: estado)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Servicio.fromFirestore(d.data(), d.id)).toList());
  }

  Stream<List<Servicio>> serviciosPendientes() =>
      _streamPorEstado(EstadosPublicacion.pendiente);

  Stream<List<Servicio>> serviciosActivos() =>
      _streamPorEstado(EstadosPublicacion.activo);

  Stream<List<Servicio>> serviciosPausados() =>
      _streamPorEstado(EstadosPublicacion.pausado);

  Future<void> bloquearUsuario(String uid, {required bool bloqueado}) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({'bloqueado': bloqueado});
    } catch (_) {
      throw const AppException(
          'No pudimos actualizar el estado del usuario. Intenta de nuevo.');
    }
  }

  Future<void> aprobarPublicacion(String servicioId) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'estadoPublicacion': EstadosPublicacion.activo,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw const AppException(
          'No pudimos aprobar la publicación. Intenta de nuevo.');
    }
  }

  Future<void> _actualizarEstadoServicio(
      String servicioId, String estado, String mensajeError) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'estadoPublicacion': estado,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw AppException(mensajeError);
    }
  }

  Future<void> rechazarPublicacion(String servicioId) =>
      _actualizarEstadoServicio(servicioId, EstadosPublicacion.pausado,
          'No pudimos rechazar la publicación. Intenta de nuevo.');

  Future<void> suspenderPublicacion(String servicioId) =>
      _actualizarEstadoServicio(servicioId, EstadosPublicacion.pausado,
          'No pudimos suspender la publicación. Intenta de nuevo.');
}
