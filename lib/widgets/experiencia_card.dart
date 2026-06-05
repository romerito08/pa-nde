import 'package:flutter/material.dart';


class ExperienciaCard extends StatelessWidget {
  final VoidCallback onReservar;
  final VoidCallback onFavorito;

  const ExperienciaCard(
    {super.key,
    required this.onReservar,
    required this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detectamos si la pantalla o el contenedor es muy pequeño (por ejemplo, menos de 340px)
        bool esPantallaPequena = constraints.maxWidth < 340;

        return Container(
          // Si no tienes un ancho fijo externo, puedes usar el double.infinity o dejarlo libre
          width: 350,
          height: 150,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // ZONA IZQUIERDA: Imagen (Se ajusta el ancho dinámicamente)
              Container(
                // Si la pantalla es pequeña, la imagen mide 90px; si no, 110px
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

              // ZONA DERECHA: Detalles del Servicio
              Expanded(
                child: Padding(
                  // Reducimos un poco el padding si el espacio es interno
                  padding: EdgeInsets.fromLTRB(
                    4,
                    12,
                    esPantallaPequena ? 8 : 12,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ubicación y Estrellas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    'Place',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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

                      // Título
                      const Text(
                        'Título del servicio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Descripción
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

                      // ACCIONES: Botón Reservar, Favorito e Importe (Optimizado para espacio)
                      Row(
                        children: [
                          // El botón ahora se expande para usar el espacio disponible de forma segura
                          Expanded(
                            flex: 3, // Le da prioridad de espacio al botón
                            child: SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                onPressed: onReservar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff1A1F16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ), // Padding mínimo interno
                                ),
                                // El FittedBox hace que el texto se encoja proporcionalmente si no cabe
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Reservar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Icono de favorito
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              width: 30,
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

                          const SizedBox(width: 4),

                          // Precio envuelto en Flexible para evitar desbordes
                          const Flexible(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '50\$/persona',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
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
