import 'package:cloud_firestore/cloud_firestore.dart';

/// Estados del ciclo de vida de una cotización (módulo de cotizaciones y
/// feedback): el Aliado responde aceptando, rechazando o proponiendo
/// cambios de precio/fecha.
class EstadosCotizacion {
  EstadosCotizacion._();

  static const String pendiente = 'Pendiente';
  static const String aceptada = 'Aceptada';
  static const String rechazada = 'Rechazada';
  static const String contrapropuesta = 'Contrapropuesta';

  static const List<String> respuestasAliado = [
    aceptada,
    contrapropuesta,
    rechazada,
  ];
}

/// Documento de la colección `cotizaciones` en Firestore.
class Cotizacion {
  final String id;
  final String servicioId;
  final String servicioNombre;
  final String aliadoId;
  final String usuarioId;
  final String usuarioNombre;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int huespedes;
  final String mensaje;
  final String estado;
  final String feedback;
  final double? precioPropuesto;
  final DateTime creadoEn;

  const Cotizacion({
    required this.id,
    required this.servicioId,
    required this.servicioNombre,
    required this.aliadoId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.huespedes,
    required this.mensaje,
    required this.estado,
    required this.feedback,
    required this.precioPropuesto,
    required this.creadoEn,
  });

  bool get respondida => estado != EstadosCotizacion.pendiente;

  factory Cotizacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Cotizacion(
      id: id,
      servicioId: data['servicioId'] ?? '',
      servicioNombre: data['servicioNombre'] ?? '',
      aliadoId: data['aliadoId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? '',
      fechaInicio: (data['fechaInicio'] as Timestamp?)?.toDate(),
      fechaFin: (data['fechaFin'] as Timestamp?)?.toDate(),
      huespedes: (data['huespedes'] ?? 1).toInt(),
      mensaje: data['mensaje'] ?? '',
      estado: data['estado'] ?? EstadosCotizacion.pendiente,
      feedback: data['feedback'] ?? '',
      precioPropuesto: (data['precioPropuesto'] as num?)?.toDouble(),
      creadoEn: (data['creadoEn'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'servicioNombre': servicioNombre,
      'aliadoId': aliadoId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fechaInicio':
          fechaInicio == null ? null : Timestamp.fromDate(fechaInicio!),
      'fechaFin': fechaFin == null ? null : Timestamp.fromDate(fechaFin!),
      'huespedes': huespedes,
      'mensaje': mensaje,
      'estado': estado,
      'feedback': feedback,
      'precioPropuesto': precioPropuesto,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }
}
