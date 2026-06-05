import 'package:flutter/material.dart';


class AlojamientoCard extends StatelessWidget {
  final VoidCallback onReservar;
  final VoidCallback onFavorito;
  const AlojamientoCard({
    super.key, 
    required this.onReservar,
    required this.onFavorito,
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
          // Zona superior: Cuadrícula transparente (Placeholder de imagen)
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                // fondo transparente
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[200]!, Colors.grey[400]!],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.black26,
                  size: 32,
                ),
              ),
            ),
          ),
          // Zona inferior: Detalles del Servicio
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              key: UniqueKey(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ubicación y Estrellas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Place',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Título del servicio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Descripción del servicio que se esta presentando',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      height: 1.2,
                    ),
                  ),
                  // Botón Reservar, Favorito e Importe
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: onReservar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1A1F16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Reservar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 30,
                          width: 10,
                          child: ElevatedButton(
                            onPressed: onFavorito,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '50\$/noche',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.black87,
                        ),
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
