import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String hotelId;
  final String usuarioId;
  final String nombreUsuario;
  final int calificacion;
  final String texto;
  final DateTime fecha;

  Review({
    required this.id,
    required this.hotelId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.calificacion,
    required this.texto,
    required this.fecha,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      hotelId: data['hotelId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? '',
      calificacion: data['calificacion'] ?? 0,
      texto: data['texto'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }
}