import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import 'package:flutter/foundation.dart';


class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'hoteles';

  // Obtener un hotel por ID
  Future<Hotel?> getHotelById(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (doc.exists) {
        return Hotel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener hotel: $e');
      return null;
    }
  }

  // Actualizar hotel
  Future<void> updateHotel(String id, Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).doc(id).update(data);
  }

  // (Opcional) Listar hoteles para el home
  Stream<QuerySnapshot> getHoteles() {
    return _firestore.collection(collectionName).snapshots();
  }
}