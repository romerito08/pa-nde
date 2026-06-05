import 'package:flutter/material.dart';

class DestinoCard extends StatelessWidget {
  const DestinoCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(
      color: const Color(0xff2A2E24),
      borderRadius: BorderRadius.circular(16),
      // Creación del patrón cuadriculado simulando la falta de imagen de Figma
      image: const DecorationImage(
        image: AssetImage(
          'assets/checkerboard.png',
        ), // Opcional si tienes el asset cuadriculado
        repeat: ImageRepeat.repeat,
        opacity: 0.05,
      ),
    ),
    child: Stack(
      children: [
        // Fondo Grisáceo transparente de Figma
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        const Center(
          child: Text(
            'Destino',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
  }
}
