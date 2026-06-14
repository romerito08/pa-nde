import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/imagen_servicio.dart';
import '../../../../models/servicio.dart';
import '../../logic/favoritos_controller.dart';

/// Tarjeta de servicio fiel al componente "Card" de Figma: fondo blanco,
/// imagen superior, fila pin + ubicación con las estrellas a la derecha,
/// título en negro, descripción gris y fila inferior con el botón oscuro
/// "Reservar", el corazón de favoritos y el precio "50$/noche".
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
    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: _imagen()),
          Expanded(flex: 6, child: _contenido(context)),
        ],
      ),
    );
  }

  /// Imagen del servicio gestionada por URL, con placeholder a cuadros
  /// claros como en el prototipo cuando no hay imagen o falla la carga.
  Widget _imagen() {
    if (servicio.imagenPrincipal.isEmpty) {
      return Container(
        color: const Color(0xFFEDEDED),
        child: const Center(
          child:
              Icon(Icons.landscape_outlined, size: 44, color: Colors.black26),
        ),
      );
    }
    return ImagenServicio(
      url: servicio.imagenPrincipal,
      fit: BoxFit.cover,
      loadingBuilder: (context, hijo, progreso) => progreso == null
          ? hijo
          : Container(
              color: const Color(0xFFEDEDED),
              child: const Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (context, _, _) => Container(
        color: const Color(0xFFEDEDED),
        child: const Center(
          child: Icon(Icons.broken_image_outlined,
              size: 36, color: Colors.black26),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    final favoritos = context.watch<FavoritosController>();
    final esFavorito = favoritos.esFavorito(servicio.id);
    final estrellas = servicio.calificacionPromedio.round().clamp(0, 5);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Pin + ubicación a la izquierda, estrellas a la derecha ---
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: Colors.black54),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  servicio.ubicacion.isEmpty ? 'Venezuela' : servicio.ubicacion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
              ...List.generate(5, (i) {
                return Icon(
                  i < estrellas ? Icons.star : Icons.star_border,
                  size: 12,
                  color: i < estrellas
                      ? const Color(0xFFE8B931)
                      : Colors.black26,
                );
              }),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            servicio.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              servicio.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, color: Colors.black54, height: 1.35),
            ),
          ),
          const SizedBox(height: 8),
          // --- Reservar + corazón + precio ---
          Row(
            children: [
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: alReservar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeOscuro,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(72, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Reservar'),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () =>
                    context.read<FavoritosController>().alternar(servicio.id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    esFavorito ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: esFavorito ? AppColors.amarillo : Colors.black54,
                  ),
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${servicio.precio.toStringAsFixed(0)}\$',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    TextSpan(
                      text: '/${servicio.unidadPrecio}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
