import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/cotizacion.dart';

/// Capa de datos del módulo de cotizaciones y feedback: colección
/// `cotizaciones` en Firestore.
class QuoteRepository {
  final FirebaseFirestore _firestore;

  QuoteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Crea la solicitud de cotización del Explorador.
  Future<String> crear(Cotizacion cotizacion) async {
    try {
      final referencia =
          await _firestore.collection('cotizaciones').add(cotizacion.toMap());
      return referencia.id;
    } catch (_) {
      throw const AppException(
          'No pudimos enviar tu solicitud de cotización. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// Bandeja de entrada del Aliado: cotizaciones sobre sus servicios.
  Stream<List<Cotizacion>> cotizacionesDeAliado(String aliadoId) {
    return _firestore
        .collection('cotizaciones')
        .where('aliadoId', isEqualTo: aliadoId)
        .snapshots()
        .map(_mapearOrdenadas);
  }

  /// Cotizaciones enviadas por un Explorador (para ver el feedback).
  Stream<List<Cotizacion>> cotizacionesDeUsuario(String usuarioId) {
    return _firestore
        .collection('cotizaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map(_mapearOrdenadas);
  }

  List<Cotizacion> _mapearOrdenadas(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final cotizaciones = snapshot.docs
        .map((doc) => Cotizacion.fromFirestore(doc.data(), doc.id))
        .toList();
    // Orden en memoria (más recientes primero) para no exigir un índice
    // compuesto en Firestore.
    cotizaciones.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
    return cotizaciones;
  }

  /// Respuesta del Aliado: escribe el feedback, el precio propuesto opcional
  /// y muta el estado de la cotización (Aceptada/Rechazada/Contrapropuesta).
  Future<void> responder({
    required String cotizacionId,
    required String nuevoEstado,
    required String feedback,
    double? precioPropuesto,
  }) async {
    if (!EstadosCotizacion.respuestasAliado.contains(nuevoEstado)) {
      throw const AppException('La respuesta seleccionada no es válida.');
    }
    if (feedback.trim().isEmpty) {
      throw const AppException(
          'Escribe un feedback para el explorador antes de responder.');
    }
    try {
      await _firestore.collection('cotizaciones').doc(cotizacionId).update({
        'estado': nuevoEstado,
        'feedback': feedback.trim(),
        'precioPropuesto': precioPropuesto,
        'respondidoEn': FieldValue.serverTimestamp(),
      });
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos guardar tu respuesta. Revisa tu conexión e intenta de nuevo.');
    }
  }
}
