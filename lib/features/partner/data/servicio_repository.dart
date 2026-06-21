import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/servicio.dart';

/// Capa de datos del panel del Aliado (RF04/RF13/RF14): CRUD completo de la
/// colección `servicios`, incluida la administración de las URLs de imágenes.
class ServicioRepository {
  final FirebaseFirestore _firestore;

  ServicioRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream en tiempo real de los servicios publicados por un aliado.
  Stream<List<Servicio>> serviciosDe(String aliadoId) {
    return _firestore
        .collection('servicios')
        .where('creadoPor', isEqualTo: aliadoId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Servicio.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Crea el servicio y devuelve su id.
  Future<String> crear(Servicio servicio) async {
    try {
      final referencia =
          await _firestore.collection('servicios').add(servicio.toMap());
      return referencia.id;
    } catch (_) {
      throw const AppException(
          'No pudimos publicar el servicio. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// Actualiza un servicio existente (modo edición del stepper).
  Future<void> actualizar(Servicio servicio) async {
    try {
      await _firestore
          .collection('servicios')
          .doc(servicio.id)
          .update(servicio.toMap());
    } catch (_) {
      throw const AppException(
          'No pudimos guardar los cambios. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// Alterna entre "Activo" y "Pausado" en el catálogo.
  Future<void> cambiarEstadoPublicacion(
      String servicioId, String nuevoEstado) async {
    try {
      await _firestore.collection('servicios').doc(servicioId).update({
        'estadoPublicacion': nuevoEstado,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw const AppException(
          'No pudimos cambiar el estado de publicación. Intenta de nuevo.');
    }
  }

  /// Elimina el servicio junto con sus reseñas y entradas de calendario,
  /// para no dejar documentos huérfanos.
  Future<void> eliminar(String servicioId) async {
    try {
      // Resenas: se borran antes del batch (permiso aparte del dueño del servicio).
      final resenas = await _firestore
          .collection('servicios')
          .doc(servicioId)
          .collection('resenas')
          .get();
      for (final doc in resenas.docs) {
        await doc.reference.delete();
      }

      // Calendarios + servicio en un batch atómico.
      final batch = _firestore.batch();
      final ocupaciones = await _firestore
          .collection('calendarios')
          .where('servicioId', isEqualTo: servicioId)
          .get();
      for (final doc in ocupaciones.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection('servicios').doc(servicioId));
      await batch.commit();
    } catch (_) {
      throw const AppException(
          'No pudimos eliminar el servicio. Revisa tu conexión e intenta de nuevo.');
    }
  }
}
