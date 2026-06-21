import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/venezuela_geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/barra_buscadora.dart';
import '../logic/catalog_controller.dart';
import 'widgets/servicio_card.dart';

/// Pantalla de exploración (RF02/RF03/RF10/RF11): hero con fotografía,
/// barra de filtros con dropdowns estandarizados de Estado/Municipio de
/// Venezuela, fecha y presupuesto máximo, banner de advertencia ante
/// búsquedas vacías, botón "Limpiar Filtros" y GridView dinámico fiel al
/// diseño de Figma.
class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
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

  void _buscar(String texto) {
    final consulta = texto.trim().toLowerCase();
    final catalogo = context.read<CatalogController>();

    if (consulta.isNotEmpty) {
      String? estadoEncontrado;
      String? municipioEncontrado;
      String? estadoDelMunicipio;

      for (final estado in VenezuelaGeo.estados) {
        if (estado.toLowerCase().contains(consulta)) {
          estadoEncontrado = estado;
          break;
        }
      }
      if (estadoEncontrado == null) {
        busqueda:
        for (final estado in VenezuelaGeo.estados) {
          for (final municipio in VenezuelaGeo.municipiosDe(estado)) {
            if (municipio.toLowerCase().contains(consulta)) {
              municipioEncontrado = municipio;
              estadoDelMunicipio = estado;
              break busqueda;
            }
          }
        }
      }

      if (estadoEncontrado != null) {
        catalogo.actualizarUbicacion(estadoEncontrado, null);
      } else if (municipioEncontrado != null) {
        catalogo.actualizarUbicacion(estadoDelMunicipio, municipioEncontrado);
      } else {
        catalogo.limpiarFiltros();
      }
    }
    catalogo.buscar();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/explorar') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/explorar', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/explorar', esMovil: false),
                _hero(esMovil),
                _buscador(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _bannerAdvertencia(),
                          const SizedBox(height: 24),
                          _cuadricula(constraints.maxWidth, esMovil),
                          const SizedBox(height: 40),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: esMovil ? 200 : 320,
          width: double.infinity,
          child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
        ),
        Container(
          height: esMovil ? 200 : 320,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Turismo low-cost y sostenible por toda Venezuela',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: esMovil ? 18 : 26,
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(blurRadius: 8, color: Colors.black87)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buscador(bool esMovil) {
    return Container(
      color: AppColors.verdeOscuro,
      padding:
          EdgeInsets.symmetric(horizontal: esMovil ? 20 : 48, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              const Text(
                "¿Pa'onde quieres ir?",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blanco, fontSize: 16),
              ),
              const SizedBox(height: 12),
              BarraBuscadora(onBuscar: _buscar),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner de advertencia visual cuando se intenta buscar con todos los
  /// campos vacíos (RF02).
  Widget _bannerAdvertencia() {
    final catalogo = context.watch<CatalogController>();
    if (catalogo.advertencia == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.advertencia.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.advertencia),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined,
              color: AppColors.advertencia, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              catalogo.advertencia!,
              style: const TextStyle(color: AppColors.blanco, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.advertencia, size: 18),
            onPressed: () => context.read<CatalogController>().cerrarAdvertencia(),
          ),
        ],
      ),
    );
  }

  Widget _cuadricula(double anchoPantalla, bool esMovil) {
    final catalogo = context.watch<CatalogController>();

    if (catalogo.cargando) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (catalogo.error != null) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  color: AppColors.verdeClaro, size: 40),
              const SizedBox(height: 12),
              Text(catalogo.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.blanco)),
            ],
          ),
        ),
      );
    }

    if (catalogo.resultados.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_outlined,
                  color: AppColors.verdeClaro, size: 40),
              const SizedBox(height: 12),
              const Text(
                'No encontramos servicios para tu búsqueda.',
                style: TextStyle(color: AppColors.blanco, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    context.read<CatalogController>().limpiarFiltros(),
                child: const Text('Limpiar filtros y ver todo el catálogo'),
              ),
            ],
          ),
        ),
      );
    }

    // Columnas dinámicas según ancho (Web y móvil), tarjetas con la
    // proporción 300×350 del componente "Card" de Figma.
    int columnas = 4;
    if (anchoPantalla < 600) {
      columnas = 1;
    } else if (anchoPantalla < 900) {
      columnas = 2;
    } else if (anchoPantalla < 1100) {
      columnas = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 300 / 350,
      ),
      itemCount: catalogo.resultados.length,
      itemBuilder: (context, indice) {
        final servicio = catalogo.resultados[indice];
        return ServicioCard(
          servicio: servicio,
          alReservar: () => Navigator.of(context)
              .pushNamed('/servicio', arguments: servicio.id),
        );
      },
    );
  }
}
