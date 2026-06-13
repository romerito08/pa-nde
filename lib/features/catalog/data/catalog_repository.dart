import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/ocupacion.dart';
import '../../../models/servicio.dart';

/// Capa de datos del buscador y catálogo (RF02/RF03/RF10/RF11).
class CatalogRepository {
  final FirebaseFirestore _firestore;

  CatalogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream en tiempo real de los servicios publicados (estado "Activo").
  Stream<List<Servicio>> serviciosActivos() {
    return _firestore
        .collection('servicios')
        .where('estadoPublicacion', isEqualTo: EstadosPublicacion.activo)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Servicio.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Lee un servicio puntual para la vista de detalle.
  Future<Servicio> obtenerServicio(String id) async {
    try {
      final doc = await _firestore.collection('servicios').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw const AppException('El servicio ya no está disponible.');
      }
      return Servicio.fromFirestore(doc.data()!, doc.id);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos cargar el servicio. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// IDs de servicios ocupados en una fecha dada, consultando `calendarios`.
  /// Firestore solo admite un rango por campo, por lo que se filtra `fin` en
  /// el servidor y `inicio` en el cliente.
  Future<Set<String>> serviciosOcupadosEn(DateTime fecha) async {
    try {
      final dia = DateTime(fecha.year, fecha.month, fecha.day);
      final snapshot = await _firestore
          .collection('calendarios')
          .where('fin', isGreaterThan: Timestamp.fromDate(dia))
          .get();
      final ocupados = <String>{};
      for (final doc in snapshot.docs) {
        final ocupacion = Ocupacion.fromFirestore(doc.data(), doc.id);
        if (ocupacion.contieneDia(dia)) {
          ocupados.add(ocupacion.servicioId);
        }
      }
      return ocupados;
    } catch (_) {
      throw const AppException(
          'No pudimos verificar la disponibilidad por fecha. Intenta de nuevo.');
    }
  }

  /// Registra la búsqueda en la colección `busquedas` para alimentar las
  /// tendencias del dashboard del Administrador (RF12). Es "fire-and-forget":
  /// un fallo aquí jamás debe romper la experiencia del Explorador.
  Future<void> registrarBusqueda({
    String? estado,
    String? municipio,
    DateTime? fecha,
    double? presupuestoMaximo,
  }) async {
    try {
      await _firestore.collection('busquedas').add({
        'estado': estado,
        'municipio': municipio,
        'fecha': fecha == null ? null : Timestamp.fromDate(fecha),
        'presupuestoMaximo': presupuestoMaximo,
        'creadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Telemetría de búsqueda: se descarta silenciosamente si no hay red,
      // porque registrar la tendencia nunca puede bloquear los resultados.
    }
  }
}
