import 'package:flutter/material.dart';

class AlojamientoCard extends StatelessWidget {
  final String hotelId;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String imagenUrl;
  final VoidCallback? onReservar;
  final VoidCallback? onFavorito;

  const AlojamientoCard({
    super.key,
    required this.hotelId,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.imagenUrl,
    this.onReservar,
    this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: imagenUrl.isNotEmpty
                  ? Image.network(
                      imagenUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
            ),
          ),
          // Detalles
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            ubicacion,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Estrellas (placeholder, después podrías cargar calificación)
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(Icons.star, size: 12, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Descubre este alojamiento único',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: onReservar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1A1F16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Reservar', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onFavorito,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.favorite_border, size: 16, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\$${precio.toStringAsFixed(0)}/noche',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}