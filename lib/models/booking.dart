import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String hotelId;
  final String usuarioId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int huespedes;
  final double totalPagar;
  final String estado; // 'pendiente', 'confirmada', 'cancelada'

  Booking({
    this.id,
    required this.hotelId,
    required this.usuarioId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.huespedes,
    required this.totalPagar,
    this.estado = 'confirmada',
  });

  // Factory para leer de Firebase de forma segura
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      hotelId: data['hotelId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp).toDate(),
      huespedes: (data['huespedes'] ?? 1).toInt(),
      totalPagar: (data['totalPagar'] ?? 0.0).toDouble(),
      estado: data['estado'] ?? 'confirmada',
    );
  }

  // Convertir a Map NoSQL para guardar en Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'usuarioId': usuarioId,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'huespedes': huespedes,
      'totalPagar': totalPagar,
      'estado': estado,
    };
  }
}