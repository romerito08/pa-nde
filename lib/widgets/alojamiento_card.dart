import 'package:flutter/material.dart';

class AlojamientoCard extends StatelessWidget {
  final String hotelId;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String imagenUrl;
  final VoidCallback? onReservar;
  final VoidCallback? onFavorito;
  final bool isFavorito; 

  const AlojamientoCard({
    super.key,
    required this.hotelId,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.imagenUrl,
    this.onReservar,
    this.onFavorito,
    this.isFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    // Generamos la separación lateral para el carrusel
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGEN: Con márgenes independientes arriba, izquierda y derecha
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
              child: SizedBox(
                height: 120, // Altura exacta de la imagen del diseño
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18), 
                  child: imagenUrl.isNotEmpty
                      ? Image.network(
                          imagenUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xffeaeaea),
                            child: const Icon(Icons.broken_image, size: 30, color: Colors.black26),
                          ),
                        )
                      : Container(
                          color: const Color(0xffeaeaea),
                          width: double.infinity,
                          child: const Icon(Icons.image_not_supported_outlined, size: 30, color: Colors.black26),
                        ),
                ),
              ),
            ),
            
            // 2. CONTENIDO INFERIOR: Con sus paddings exactos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila de Ubicación y Estrellas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff666666)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ubicacion,
                                  style: const TextStyle(color: Color(0xff666666), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(Icons.star, size: 12, color: Color(0xffFFD200)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Título del servicio
                    Text(
                      nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1A1A1A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Descripción corta
                    Text(
                      'Descripción del servicio que se se esta presentando',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: const Color(0xff555555).withOpacity(0.9), height: 1.2),
                    ),
                    
                    // OBLIGA A LOS BOTONES A IRSE AL FONDO DE LA TARJETA
                    const Spacer(), 
                    
                    // Fila de acciones (Botón, Favorito, Precio)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 36,
                            child: TextButton(
                              onPressed: onReservar,
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xff182016),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Reservar', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        
                        // Botón Favorito
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
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${precio.toStringAsFixed(0)}\$/noche',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xff444444)),
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
      ),
    );
  }
}