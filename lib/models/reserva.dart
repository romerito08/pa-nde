import 'package:cloud_firestore/cloud_firestore.dart';

/// Flujo de estados mutables de una reserva (RF05/RF08):
/// Solicitado → Aceptado → Pagado → Disfrutado.
class EstadosReserva {
  EstadosReserva._();

  static const String solicitado = 'Solicitado';
  static const String aceptado = 'Aceptado';
  static const String pagado = 'Pagado';
  static const String disfrutado = 'Disfrutado';

  static const List<String> flujo = [solicitado, aceptado, pagado, disfrutado];

  /// Posición del estado dentro del flujo lineal (para pintar la línea de
  /// progreso en la UI). Estados desconocidos se tratan como el inicio.
  static int indiceDe(String estado) {
    final indice = flujo.indexOf(estado);
    return indice == -1 ? 0 : indice;
  }
}

/// Documento de la colección `reservas` en Firestore. Se denormalizan el
/// nombre/imagen del servicio y el nombre del explorador para que los
/// listados no requieran lecturas adicionales.
class Reserva {
  final String id;
  final String servicioId;
  final String servicioNombre;
  final String servicioImagen;
  final String servicioCiudad;
  final String aliadoId;
  final String usuarioId;
  final String usuarioNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int huespedes;
  final double total;
  final String estado;
  final String metodoPago;

  const Reserva({
    required this.id,
    required this.servicioId,
    required this.servicioNombre,
    required this.servicioImagen,
    required this.servicioCiudad,
    required this.aliadoId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.huespedes,
    required this.total,
    required this.estado,
    required this.metodoPago,
  });

  int get noches => fechaFin.difference(fechaInicio).inDays;

  factory Reserva.fromFirestore(Map<String, dynamic> data, String id) {
    return Reserva(
      id: id,
      servicioId: data['servicioId'] ?? '',
      servicioNombre: data['servicioNombre'] ?? '',
      servicioImagen: data['servicioImagen'] ?? '',
      servicioCiudad: data['servicioCiudad'] ?? '',
      aliadoId: data['aliadoId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? '',
      fechaInicio:
          (data['fechaInicio'] as Timestamp? ?? Timestamp.now()).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp? ?? Timestamp.now()).toDate(),
      huespedes: (data['huespedes'] ?? 1).toInt(),
      total: (data['total'] ?? 0).toDouble(),
      estado: data['estado'] ?? EstadosReserva.solicitado,
      metodoPago: data['metodoPago'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'servicioNombre': servicioNombre,
      'servicioImagen': servicioImagen,
      'servicioCiudad': servicioCiudad,
      'aliadoId': aliadoId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'huespedes': huespedes,
      'total': total,
      'estado': estado,
      'metodoPago': metodoPago,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }
}
