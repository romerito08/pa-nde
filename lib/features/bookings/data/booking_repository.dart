import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/ocupacion.dart';
import '../../../models/reserva.dart';

/// Capa de datos de reservas (RF05/RF08). Gestiona las colecciones
/// `reservas` y `calendarios`: cada reserva crea su rango de ocupación en un
/// batch atómico para que la disponibilidad siempre sea coherente.
class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ocupaciones registradas de un servicio (alimenta el calendario
  /// interactivo de la vista de detalle).
  Future<List<Ocupacion>> ocupacionesDe(String servicioId) async {
    try {
      final snapshot = await _firestore
          .collection('calendarios')
          .where('servicioId', isEqualTo: servicioId)
          .get();
      return snapshot.docs
          .map((doc) => Ocupacion.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      throw const AppException(
          'No pudimos consultar el calendario de disponibilidad. Intenta de nuevo.');
    }
  }

  /// Verifica contra `calendarios` que el rango solicitado tenga cupos
  /// disponibles en todos sus días (RF05). Un día está lleno solo cuando la
  /// cantidad de reservas existentes iguala o supera [cuposPorDia].
  Future<bool> estaDisponible({
    required String servicioId,
    required DateTime inicio,
    required DateTime fin,
    required int cuposPorDia,
  }) async {
    final ocupaciones = await ocupacionesDe(servicioId);
    var dia = DateTime(inicio.year, inicio.month, inicio.day);
    final limite = DateTime(fin.year, fin.month, fin.day);
    while (dia.isBefore(limite)) {
      final count = ocupaciones.where((o) => o.contieneDia(dia)).length;
      if (count >= cuposPorDia) return false;
      dia = dia.add(const Duration(days: 1));
    }
    return true;
  }

  /// Crea la reserva en estado "Pendiente de Pago" y registra la ocupación en
  /// `calendarios` en el mismo batch atómico. Devuelve el id de la reserva.
  Future<String> crearReserva(Reserva reserva, {required int cuposPorDia}) async {
    try {
      final disponible = await estaDisponible(
        servicioId: reserva.servicioId,
        inicio: reserva.fechaInicio,
        fin: reserva.fechaFin,
        cuposPorDia: cuposPorDia,
      );
      if (!disponible) {
        throw const AppException(
            'No quedan cupos disponibles para las fechas elegidas. Elige otras.');
      }

      final batch = _firestore.batch();
      final reservaRef = _firestore.collection('reservas').doc();
      final ocupacionRef = _firestore.collection('calendarios').doc();

      batch.set(reservaRef, reserva.toMap());
      batch.set(
        ocupacionRef,
        Ocupacion(
          id: ocupacionRef.id,
          servicioId: reserva.servicioId,
          reservaId: reservaRef.id,
          inicio: reserva.fechaInicio,
          fin: reserva.fechaFin,
        ).toMap(),
      );
      await batch.commit();
      return reservaRef.id;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos registrar tu reserva. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// Stream de reservas del explorador autenticado.
  Stream<List<Reserva>> reservasDeUsuario(String usuarioId) {
    return _firestore
        .collection('reservas')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map(_mapearReservasOrdenadas);
  }

  /// Stream de reservas recibidas por un aliado sobre sus servicios.
  Stream<List<Reserva>> reservasDeAliado(String aliadoId) {
    return _firestore
        .collection('reservas')
        .where('aliadoId', isEqualTo: aliadoId)
        .snapshots()
        .map(_mapearReservasOrdenadas);
  }

  List<Reserva> _mapearReservasOrdenadas(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final reservas = snapshot.docs
        .map((doc) => Reserva.fromFirestore(doc.data(), doc.id))
        .toList();
    // Orden en memoria para no exigir un índice compuesto en Firestore.
    reservas.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
    return reservas;
  }

  /// Muta el estado del documento siguiendo el flujo
  /// Solicitado → Aceptado → Pagado → Disfrutado (RF08).
  Future<void> actualizarEstado({
    required String reservaId,
    required String nuevoEstado,
    String? metodoPago,
    String? codigoAutorizacion,
  }) async {
    try {
      await _firestore.collection('reservas').doc(reservaId).update({
        'estado': nuevoEstado,
        'metodoPago': ?metodoPago,
        'codigoAutorizacion': ?codigoAutorizacion,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw const AppException(
          'No pudimos actualizar el estado de la reserva. Intenta de nuevo.');
    }
  }

  /// Cancela una reserva aún no aceptada: elimina el documento y libera sus
  /// fechas en `calendarios`.
  Future<void> cancelarReserva(String reservaId) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('reservas').doc(reservaId));

      final ocupaciones = await _firestore
          .collection('calendarios')
          .where('reservaId', isEqualTo: reservaId)
          .get();
      for (final doc in ocupaciones.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {
      throw const AppException(
          'No pudimos cancelar la reserva. Revisa tu conexión e intenta de nuevo.');
    }
  }
}
