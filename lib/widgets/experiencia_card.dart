import 'package:flutter/material.dart';

class ExperienciaCard extends StatelessWidget {
  final VoidCallback onReservar;
  final VoidCallback onFavorito;
  final bool isFavorito; // Propiedad para controlar el estado visual

  const ExperienciaCard({
    super.key,
    required this.onReservar,
    required this.onFavorito,
    this.isFavorito = false, 
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool esPantallaPequena = constraints.maxWidth < 340;

        return Container(
          width: 350,
          height: 150,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: esPantallaPequena ? 90 : 110,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[200]!, Colors.grey[300]!],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.black26,
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 12, esPantallaPequena ? 8 : 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    'Place',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (index) => const Icon(Icons.star, size: 12, color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Título del servicio',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Descripción del servicio que se esta presentando',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.2),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 36,
                              child: TextButton(
                                // ¡AQUÍ ESTÁ LA MAGIA! 
                                // Al presionar este botón, se ejecuta la función que viene desde fuera.
                                onPressed: onReservar, 
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xff1A1F16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.zero, // Evita que los márgenes del botón rompan el diseño chico
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Reservar',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // BOTÓN FAVORITO
                          GestureDetector(
                            onTap: onFavorito,
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: isFavorito ? const Color(0xffFFD200) : Colors.white, 
                                border: Border.all(
                                  color: isFavorito ? const Color(0xffFFD200) : const Color(0xff182016), 
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isFavorito ? Icons.favorite : Icons.favorite_border, 
                                size: 18, 
                                color: isFavorito ? Colors.white : const Color(0xff182016),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '50\$/persona',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                              ),
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
      },
    );
  }
}