import 'package:flutter/material.dart';

class DestinoCard extends StatelessWidget {
  final String estado;
  final String imagenUrl;

  const DestinoCard({
    super.key,
    required this.estado,
    required this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xff2A2E24), // Color de respaldo mientras carga la imagen
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imagenUrl), // Usa imágenes de internet directamente
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Sombreado oscuro degradado para garantizar legibilidad del texto blanco
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
          // Nombre del estado centrado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                estado,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}