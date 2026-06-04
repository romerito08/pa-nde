import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'reviews';

  // Agregar un comentario
  Future<void> addReview({
    required String hotelId,
    required int calificacion,
    required String texto,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Debes iniciar sesión');

    await _firestore.collection(collectionName).add({
      'hotelId': hotelId,
      'usuarioId': user.uid,
      'nombreUsuario': user.displayName ?? user.email,
      'calificacion': calificacion,
      'texto': texto,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  // Obtener comentarios de un hotel en tiempo real
  Stream<List<Review>> getReviewsForHotel(String hotelId) {
    return _firestore
        .collection(collectionName)
        .where('hotelId', isEqualTo: hotelId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList());
  }
}