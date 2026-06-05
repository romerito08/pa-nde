import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';  // para debugPrint
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

    debugPrint('📝 Agregando review - hotelId: $hotelId, user: ${user.uid}');
    try {
      await _firestore.collection(collectionName).add({
        'hotelId': hotelId,
        'usuarioId': user.uid,
        'nombreUsuario': user.displayName ?? user.email,
        'calificacion': calificacion,
        'texto': texto,
        'fecha': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Review agregado correctamente');
    } catch (e) {
      debugPrint('❌ Error al agregar review: $e');
      rethrow;
    }
  }

  // Obtener comentarios de un hotel en tiempo real
  Stream<List<Review>> getReviewsForHotel(String hotelId) {
    debugPrint('📡 getReviewsForHotel llamado con hotelId: $hotelId');
    return _firestore
        .collection(collectionName)
        .where('hotelId', isEqualTo: hotelId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
          // Asegurarse de que siempre devolvemos una lista (nunca null)
          final List<Review> reviews = snapshot.docs
              .map((doc) => Review.fromFirestore(doc))
              .toList();
          debugPrint('📡 Stream emite ${reviews.length} comentarios para hotel $hotelId');
          return reviews;
        })
        .handleError((error) {
          debugPrint('❌ Error en stream de reviews: $error');
          return <Review>[]; // En caso de error, devolver lista vacía
        });
  }
}