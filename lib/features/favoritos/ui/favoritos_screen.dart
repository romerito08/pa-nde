import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../catalog/logic/catalog_controller.dart';
import '../../catalog/logic/favoritos_controller.dart';
import '../../catalog/ui/widgets/servicio_card.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalogo = context.read<CatalogController>();
      if (catalogo.resultados.isEmpty && !catalogo.cargando) {
        catalogo.buscar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/favoritos') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/favoritos', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/favoritos', esMovil: false),
                _hero(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: esMovil ? 16 : 40,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _contenido(esMovil, constraints.maxWidth),
                          const SizedBox(height: 48),
                          AppFooter(esMovil: esMovil),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hero(bool esMovil) {
    return Container(
      color: AppColors.verdeOscuro,
      padding: EdgeInsets.symmetric(
        horizontal: esMovil ? 20 : 48,
        vertical: esMovil ? 32 : 48,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.favorite, color: AppColors.amarillo, size: 48),
            const SizedBox(height: 12),
            Text(
              'Mis favoritos',
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: esMovil ? 24 : 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Los servicios que guardaste para explorar después.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.verdeClaro, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(bool esMovil, double anchoPantalla) {
    final favoritos = context.watch<FavoritosController>();
    final catalogo = context.watch<CatalogController>();

    if (catalogo.cargando) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final serviciosFav = catalogo.resultados
        .where((s) => favoritos.esFavorito(s.id))
        .toList();

    if (favoritos.lista.isEmpty) {
      return _vacio(
        'Aún no tienes favoritos.',
        'Toca el corazón en cualquier servicio para guardarlo aquí.',
        Icons.favorite_border,
      );
    }

    if (serviciosFav.isEmpty) {
      return _vacio(
        'Tus favoritos no están disponibles.',
        'Es posible que algunos servicios hayan sido dados de baja.',
        Icons.cloud_off_outlined,
      );
    }

    int columnas = 3;
    if (anchoPantalla < 600) {
      columnas = 1;
    } else if (anchoPantalla < 900) {
      columnas = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${serviciosFav.length} servicio${serviciosFav.length != 1 ? 's' : ''} guardado${serviciosFav.length != 1 ? 's' : ''}',
          style: const TextStyle(
            color: AppColors.verdeClaro,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 300 / 350,
          ),
          itemCount: serviciosFav.length,
          itemBuilder: (context, i) => ServicioCard(
            servicio: serviciosFav[i],
            alReservar: () => Navigator.of(context)
                .pushNamed('/servicio', arguments: serviciosFav[i].id),
          ),
        ),
      ],
    );
  }

  Widget _vacio(String titulo, String subtitulo, IconData icono) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: AppColors.verdeClaro, size: 48),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.verdeClaro, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
