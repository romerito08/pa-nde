import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String servicioImagen;
  final String servicioUbicacion;
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
  final double precioBase;
  final bool esExperiencia;
  final DateTime creadoEn;

  /// turnoAliado: true = aliado debe responder, false = explorador debe responder.
  final bool turnoAliado;

  /// Contra-mensaje del explorador en respuesta a una Contrapropuesta.
  final String mensajeExplorador;

  /// ID de la Reserva creada desde esta cotización. Vacío = aún sin reserva.
  final String reservaId;

  const Cotizacion({
    required this.id,
    required this.servicioId,
    required this.servicioNombre,
    required this.servicioImagen,
    required this.servicioUbicacion,
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
    required this.precioBase,
    required this.esExperiencia,
    required this.creadoEn,
    required this.turnoAliado,
    required this.mensajeExplorador,
    required this.reservaId,
  });

  /// true cuando el aliado ya respondió y hay feedback que mostrar al explorador.
  bool get respondida => !turnoAliado;

  /// true cuando la negociación terminó definitivamente.
  bool get esFinal =>
      estado == EstadosCotizacion.aceptada ||
      estado == EstadosCotizacion.rechazada;

  /// true cuando el explorador puede crear una Reserva directamente.
  bool get puedeReservar =>
      reservaId.isEmpty &&
      (estado == EstadosCotizacion.aceptada ||
          (estado == EstadosCotizacion.contrapropuesta &&
              precioPropuesto != null));

  /// Total a cobrar si el explorador reserva con esta cotización.
  double get totalReserva {
    if (precioPropuesto != null) return precioPropuesto!;
    final noches = (fechaFin != null && fechaInicio != null)
        ? fechaFin!.difference(fechaInicio!).inDays.clamp(1, 9999)
        : 1;
    return precioBase * (esExperiencia ? huespedes : noches);
  }

  factory Cotizacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Cotizacion(
      id: id,
      servicioId: data['servicioId'] ?? '',
      servicioNombre: data['servicioNombre'] ?? '',
      servicioImagen: data['servicioImagen'] ?? '',
      servicioUbicacion: data['servicioUbicacion'] ?? '',
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
      precioBase: (data['precioBase'] as num?)?.toDouble() ?? 0,
      esExperiencia: data['esExperiencia'] ?? false,
      creadoEn: (data['creadoEn'] as Timestamp? ?? Timestamp.now()).toDate(),
      turnoAliado: data['turnoAliado'] ?? true,
      mensajeExplorador: data['mensajeExplorador'] ?? '',
      reservaId: data['reservaId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'servicioNombre': servicioNombre,
      'servicioImagen': servicioImagen,
      'servicioUbicacion': servicioUbicacion,
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
      'precioBase': precioBase,
      'esExperiencia': esExperiencia,
      'creadoEn': FieldValue.serverTimestamp(),
      'turnoAliado': turnoAliado,
      'mensajeExplorador': mensajeExplorador,
      'reservaId': reservaId,
    };
  }
}
