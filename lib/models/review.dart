import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String hotelId;
  final String nombreUsuario;
  final String texto;
  final int calificacion;

  Review({
    required this.hotelId,
    required this.nombreUsuario,
    required this.texto,
    required this.calificacion,
  });

  // Constructor Factory para mapear los documentos NoSQL de Firebase
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      hotelId: data['hotelId'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? 'Explorador Anónimo',
      texto: data['texto'] ?? data['comentario'] ?? '',
      calificacion: (data['calificacion'] ?? 5).toInt(),
    );
  }
}