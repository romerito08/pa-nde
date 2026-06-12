import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/servicio.dart';
import '../../logic/favoritos_controller.dart';

/// Tarjeta de servicio fiel al componente "Card" de Figma (300×350):
/// imagen superior con esquinas redondeadas, fila pin + ubicación, título en
/// bold, descripción de dos líneas, estrellas con promedio, precio y botón
/// amarillo "Reservar" junto al corazón de favoritos.
class ServicioCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback alReservar;

  const ServicioCard({
    super.key,
    required this.servicio,
    required this.alReservar,
  });

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosController>();
    final esFavorito = favoritos.esFavorito(servicio.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Imagen del servicio (gestión por URL) ---
          Expanded(
            flex: 5,
            child: servicio.imagenPrincipal.isEmpty
                ? Container(
                    color: AppColors.verdeOscuro,
                    child: const Center(
                      child: Icon(Icons.landscape_outlined,
                          size: 48, color: AppColors.verdeClaro),
                    ),
                  )
                : Image.network(
                    servicio.imagenPrincipal,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, hijo, progreso) =>
                        progreso == null
                            ? hijo
                            : Container(
                                color: AppColors.verdeOscuro,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                    errorBuilder: (context, _, _) => Container(
                      color: AppColors.verdeOscuro,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 40, color: AppColors.verdeClaro),
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.verdeClaro),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          servicio.ciudad,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.verdeClaro),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.verdeOscuro,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          servicio.tipo,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.amarillo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    servicio.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blanco),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      servicio.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.verdeClaro),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < servicio.calificacionPromedio.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: AppColors.amarillo,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '(${servicio.totalResenas})',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.verdeClaro),
                      ),
                      const Spacer(),
                      Text(
                        '\$${servicio.precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amarillo),
                      ),
                      Text(
                        ' / ${servicio.unidadPrecio}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.verdeClaro),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: ElevatedButton(
                            onPressed: alReservar,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(67, 35),
                            ),
                            child: const Text('Reservar',
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context
                            .read<FavoritosController>()
                            .alternar(servicio.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            esFavorito
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 22,
                            color: esFavorito
                                ? AppColors.amarillo
                                : AppColors.verdeClaro,
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
  }
}
