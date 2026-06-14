import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/cotizacion.dart';

class QuoteRepository {
  final FirebaseFirestore _firestore;

  QuoteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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

  Stream<List<Cotizacion>> cotizacionesDeAliado(String aliadoId) {
    return _firestore
        .collection('cotizaciones')
        .where('aliadoId', isEqualTo: aliadoId)
        .snapshots()
        .map(_mapearOrdenadas);
  }

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
    cotizaciones.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
    return cotizaciones;
  }

  /// Respuesta del Aliado: feedback + precio + estado. Pone turno en explorador.
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
        'turnoAliado': false,
        'mensajeExplorador': '',
      });
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos guardar tu respuesta. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// El explorador actualiza o agrega fechas a su cotización.
  Future<void> actualizarFechas({
    required String cotizacionId,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      await _firestore.collection('cotizaciones').doc(cotizacionId).update({
        'fechaInicio': Timestamp.fromDate(fechaInicio),
        'fechaFin': fechaFin == null ? null : Timestamp.fromDate(fechaFin),
      });
    } catch (_) {
      throw const AppException(
          'No pudimos actualizar las fechas. Revisa tu conexión.');
    }
  }

  /// Vincula el ID de la Reserva generada a la cotización para impedir re-reserva.
  Future<void> vincularReserva({
    required String cotizacionId,
    required String reservaId,
  }) async {
    try {
      await _firestore.collection('cotizaciones').doc(cotizacionId).update({
        'reservaId': reservaId,
      });
    } catch (_) {
      // Best-effort: the reservation was already created successfully
    }
  }

  /// Contra-respuesta del Explorador a una Contrapropuesta. Devuelve el turno al aliado.
  Future<void> responderExplorador({
    required String cotizacionId,
    required String mensajeExplorador,
  }) async {
    if (mensajeExplorador.trim().isEmpty) {
      throw const AppException('Escribe tu mensaje antes de continuar.');
    }
    try {
      await _firestore.collection('cotizaciones').doc(cotizacionId).update({
        'mensajeExplorador': mensajeExplorador.trim(),
        'turnoAliado': true,
      });
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos enviar tu respuesta. Revisa tu conexión e intenta de nuevo.');
    }
  }
}
