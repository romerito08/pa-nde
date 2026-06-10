import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking.dart';
import 'price_strategy.dart';

class BookingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Comprueba si el hotel está libre en el rango de fechas seleccionado
  Future<bool> verificarDisponibilidad({
    required String hotelId,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('reservas')
          .where('hotelId', isEqualTo: hotelId)
          .where('estado', isEqualTo: 'confirmada')
          .get();

      for (var doc in snapshot.docs) {
        final reservaExistente = Booking.fromFirestore(doc);
        
        // Algoritmo de solapamiento de fechas
        bool seSolapa = (inicio.isBefore(reservaExistente.fechaFin) && 
                         fin.isAfter(reservaExistente.fechaInicio));
        
        if (seSolapa) return false; // Bloqueado, ya está ocupado
      }
      return true; // Disponible
    } catch (e) {
      return false;
    }
  }

  /// Crea la reserva aplicando el Patrón Strategy según el día de la semana
  Future<bool> procesarReserva({
    required String hotelId,
    required DateTime inicio,
    required DateTime fin,
    required int huespedes,
    required double precioBasePorNoche,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // 1. Verificar disponibilidad de último minuto
    final disponible = await verificarDisponibilidad(hotelId: hotelId, inicio: inicio, fin: fin);
    if (!disponible) return false;

    // 2. Calcular noches ganadas
    final noches = fin.difference(inicio).inDays;
    if (noches <= 0) return false;

    // 3. Determinar Estrategia (Si empieza viernes o sábado es WeekendStrategy)
    PriceStrategy estrategia;
    if (inicio.weekday == DateTime.friday || inicio.weekday == DateTime.saturday) {
      estrategia = WeekendPriceStrategy();
    } else {
      estrategia = RegularPriceStrategy();
    }

    final totalFinal = estrategia.calcularTotal(precioBasePorNoche, noches);

    // 4. Guardar en la base de datos NoSQL
    try {
      final nuevaReserva = Booking(
        hotelId: hotelId,
        usuarioId: user.uid,
        fechaInicio: inicio,
        fechaFin: fin,
        huespedes: huespedes,
        totalPagar: totalFinal,
      );

      await _firestore.collection('reservas').add(nuevaReserva.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- NUEVO MÉTODO AGREGADO PARA INTEGRAR CON RESERVA SCREEN ---
  /// Obtiene el historial de reservas de Firestore asociadas al usuario autenticado actual
  Future<List<Booking>> obtenerReservasUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return []; // Si no hay sesión iniciada, retorna una lista vacía de inmediato

    try {
      final snapshot = await _firestore
          .collection('reservas')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      // Transforma cada documento de la colección 'reservas' en un objeto del modelo Booking
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error al obtener reservas desde Firestore: $e");
      return [];
    }
  }
}