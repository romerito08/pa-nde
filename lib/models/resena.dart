import 'package:cloud_firestore/cloud_firestore.dart';

/// Documento de la subcolección `servicios/{servicioId}/resenas` (RF06).
class Resena {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String texto;
  final int calificacion;
  final DateTime fecha;

  const Resena({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.texto,
    required this.calificacion,
    required this.fecha,
  });

  String get fechaFormateada {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  factory Resena.fromFirestore(Map<String, dynamic> data, String id) {
    return Resena(
      id: id,
      usuarioId: data['usuarioId'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? 'Explorador anónimo',
      texto: data['texto'] ?? '',
      calificacion: (data['calificacion'] ?? 5).toInt(),
      fecha: (data['fecha'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'texto': texto,
      'calificacion': calificacion,
      'fecha': FieldValue.serverTimestamp(),
    };
  }
}
