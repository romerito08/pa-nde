import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/resena.dart';

/// Capa de datos de reseñas (RF06). Las reseñas viven en la subcolección
/// `servicios/{servicioId}/resenas` y el promedio agregado se mantiene en el
/// documento padre dentro de una transacción atómica.
class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _subcoleccion(String servicioId) =>
      _firestore.collection('servicios').doc(servicioId).collection('resenas');

  /// Stream en tiempo real de las reseñas del servicio, más recientes primero.
  Stream<List<Resena>> resenasDe(String servicioId) {
    return _subcoleccion(servicioId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resena.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Cuántas reseñas ha dejado este usuario para el servicio dado.
  Future<int> contarResenasDeUsuario(
      String servicioId, String usuarioId) async {
    try {
      final snapshot = await _subcoleccion(servicioId)
          .where('usuarioId', isEqualTo: usuarioId)
          .get();
      return snapshot.docs.length;
    } catch (_) {
      return 0;
    }
  }

  /// Guarda la reseña en la subcolección y recalcula el promedio general de
  /// estrellas del servicio en la misma transacción, para que la cabecera de
  /// la pantalla se actualice de inmediato vía stream.
  Future<void> agregarResena({
    required String servicioId,
    required Resena resena,
  }) async {
    try {
      final servicioRef = _firestore.collection('servicios').doc(servicioId);
      final resenaRef = _subcoleccion(servicioId).doc();

      await _firestore.runTransaction((transaccion) async {
        final servicioDoc = await transaccion.get(servicioRef);
        if (!servicioDoc.exists) {
          throw const AppException('El servicio ya no existe.');
        }
        final datos = servicioDoc.data() ?? {};
        final promedioActual = (datos['calificacionPromedio'] ?? 0).toDouble();
        final totalActual = (datos['totalResenas'] ?? 0).toInt();

        // Promedio incremental: evita releer toda la subcolección.
        final nuevoTotal = totalActual + 1;
        final nuevoPromedio =
            ((promedioActual * totalActual) + resena.calificacion) / nuevoTotal;

        transaccion.set(resenaRef, resena.toMap());
        transaccion.update(servicioRef, {
          'calificacionPromedio': double.parse(nuevoPromedio.toStringAsFixed(2)),
          'totalResenas': nuevoTotal,
        });
      });
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
          'No pudimos publicar tu reseña. Revisa tu conexión e intenta de nuevo.');
    }
  }
}
