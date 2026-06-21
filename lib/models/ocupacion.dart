import 'package:cloud_firestore/cloud_firestore.dart';

/// Documento de la colección `calendarios` (RF05): cada entrada representa
/// un rango de fechas ocupado para un servicio. El calendario interactivo
/// consulta esta colección antes de permitir una reserva.
class Ocupacion {
  final String id;
  final String servicioId;
  final String reservaId;
  final DateTime inicio;
  final DateTime fin;

  const Ocupacion({
    required this.id,
    required this.servicioId,
    required this.reservaId,
    required this.inicio,
    required this.fin,
  });

  /// Verifica si un rango [desde, hasta) se solapa con esta ocupación.
  bool seSolapaCon(DateTime desde, DateTime hasta) {
    return desde.isBefore(fin) && hasta.isAfter(inicio);
  }

  /// Verifica si un día puntual cae dentro del rango ocupado.
  bool contieneDia(DateTime dia) {
    final normalizado = DateTime(dia.year, dia.month, dia.day);
    return !normalizado.isBefore(DateTime(inicio.year, inicio.month, inicio.day)) &&
        normalizado.isBefore(DateTime(fin.year, fin.month, fin.day));
  }

  factory Ocupacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Ocupacion(
      id: id,
      servicioId: data['servicioId'] ?? '',
      reservaId: data['reservaId'] ?? '',
      inicio: (data['inicio'] as Timestamp? ?? Timestamp.now()).toDate(),
      fin: (data['fin'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'reservaId': reservaId,
      'inicio': Timestamp.fromDate(inicio),
      'fin': Timestamp.fromDate(fin),
    };
  }
}
