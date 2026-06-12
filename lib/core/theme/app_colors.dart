import 'package:flutter/material.dart';

/// Paleta cromática oficial del design system de Figma
/// (archivo "pa'onde" → página "Componentes" → frame "Colors").
class AppColors {
  AppColors._();

  /// Amarillo de marca (#F2DE00): botones primarios, acentos y selección.
  static const Color amarillo = Color(0xFFF2DE00);

  /// Verde Oscuro (#1F261B): fondo principal de todas las pantallas.
  static const Color verdeOscuro = Color(0xFF1F261B);

  /// Verde (#293324): superficies elevadas (tarjetas, inputs, paneles).
  static const Color verde = Color(0xFF293324);

  /// Verde Claro (#5C6657): bordes, texto secundario y estados inactivos.
  static const Color verdeClaro = Color(0xFF5C6657);

  /// Blanco (#FFFFFF): texto principal sobre fondos oscuros.
  static const Color blanco = Color(0xFFFFFFFF);

  // --- Estados semánticos para feedback de la UI ---
  static const Color exito = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color advertencia = Color(0xFFFFA726);

  // --- Colores asociados al ciclo de vida de una reserva ---
  static const Color estadoSolicitado = advertencia;
  static const Color estadoAceptado = Color(0xFF42A5F5);
  static const Color estadoPagado = exito;
  static const Color estadoDisfrutado = amarillo;

  /// Devuelve el color identificador de un estado de reserva.
  static Color colorDeEstado(String estado) {
    switch (estado) {
      case 'Solicitado':
        return estadoSolicitado;
      case 'Aceptado':
        return estadoAceptado;
      case 'Pagado':
        return estadoPagado;
      case 'Disfrutado':
        return estadoDisfrutado;
      default:
        return verdeClaro;
    }
  }
}
