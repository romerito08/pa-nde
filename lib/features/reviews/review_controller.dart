import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/review.dart'; 

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream en tiempo real apuntando a 'reviews' sin alterar tu modelo global
  Stream<List<Review>> streamReviews(String hotelId) {
    return _firestore
        .collection('reviews')
        .where('hotelId', isEqualTo: hotelId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              
              // 1. Extraemos el Timestamp de Firestore de forma segura
              final Timestamp? timestamp = data['fecha'] as Timestamp?;
              final DateTime fechaDateTime = timestamp?.toDate() ?? DateTime.now();
              
              // 2. Formateamos la fecha a dd/mm/aaaa pasando el año a String correctamente
              final String dia = fechaDateTime.day.toString().padLeft(2, '0');
              final String mes = fechaDateTime.month.toString().padLeft(2, '0');
              final String anio = fechaDateTime.year.toString();
              final String fechaFormateada = "$dia/$mes/$anio";

              return Review(
                hotelId: data['hotelId'] ?? '',
                nombreUsuario: data['nombreUsuario'] ?? 'Explorador Anónimo',
                calificacion: (data['calificacion'] ?? 5).toInt(),
                // Almacenamos la fecha junto al comentario usando '|' como separador seguro
                texto: "$fechaFormateada|${data['texto'] ?? ''}",
              );
            }).toList());
  }

  /// Crear reseña guardando en 'reviews'
  Future<bool> crearResena({
    required String hotelId,
    required String comentario,
    required int calificacion,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore.collection('usuarios').doc(currentUser.uid).get();
      final String nombreCompleto = userDoc.exists 
          ? "${userDoc.data()?['nombre'] ?? 'Explorador'} ${userDoc.data()?['apellido'] ?? ''}".trim()
          : 'Explorador de Pa\'onde';

      await _firestore.collection('reviews').add({ 
        'hotelId': hotelId,
        'usuarioId': currentUser.uid,
        'nombreUsuario': nombreCompleto,
        'texto': comentario,
        'calificacion': calificacion,
        'fecha': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      debugPrint("Error al guardar reseña en el controlador: $e");
      return false;
    }
  }
}