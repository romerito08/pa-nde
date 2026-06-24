import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/venezuela_geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/barra_buscadora.dart';
import '../../../core/widgets/imagen_servicio.dart';
import '../../../models/servicio.dart';
import '../../catalog/logic/catalog_controller.dart';
import '../../catalog/ui/widgets/servicio_card.dart';

/// Home del Explorador autenticado: hero con buscador, "Descubre Venezuela",
/// "Servicios destacados" y "Aprovecha las ofertas".
class ExploradorInicioScreen extends StatefulWidget {
  const ExploradorInicioScreen({super.key});

  @override
  State<ExploradorInicioScreen> createState() =>
      _ExploradorInicioScreenState();
}

class _ExploradorInicioScreenState extends State<ExploradorInicioScreen> {
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
    
    // CORRECCIÓN: Si la consulta está vacía, limpia filtros y restaura la data inicial
    if (consulta.isEmpty) {
      catalogo.limpiarFiltros();
      return;
    }

    catalogo.actualizarTexto(consulta);

    // 1. Coincide con un Estado → ir a Destinos con filtro geográfico.
    for (final estado in VenezuelaGeo.estados) {
      if (estado.toLowerCase().contains(consulta)) {
        catalogo.actualizarUbicacion(estado, null);
        catalogo.buscarLocalmente();
        Navigator.of(context).pushNamed('/destinos');
        return;
      }
    }

    // 2. Coincide con un Municipio → ir a Destinos con filtro geográfico.
    String? municipioEncontrado;
    String? estadoDelMunicipio;
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
    if (municipioEncontrado != null) {
      catalogo.actualizarUbicacion(estadoDelMunicipio, municipioEncontrado);
      catalogo.buscarLocalmente();
      Navigator.of(context).pushNamed('/destinos');
      return;
    }

    // 3. Búsqueda por nombre / descripción → ir a la categoría con más resultados.
    catalogo.buscarLocalmente();
    _navegarPorResultados(catalogo);
  }

  void _navegarPorResultados(CatalogController catalogo) {
    final experiencias = catalogo.resultados
        .where((s) => s.tipo == TiposServicio.experiencia)
        .length;
    final alojamientos = catalogo.resultados
        .where((s) => s.tipo == TiposServicio.alojamiento)
        .length;
    if (experiencias > alojamientos) {
      Navigator.of(context).pushNamed('/experiencias');
    } else {
      Navigator.of(context).pushNamed('/alojamientos');
    }
  }

  void _irADestino(String estado) {
    final catalogo = context.read<CatalogController>();
    catalogo.actualizarUbicacion(estado, null);
    catalogo.buscarLocalmente();
    Navigator.of(context).pushNamed('/destinos');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer:
              esMovil ? const AppDrawer(rutaActual: '/inicio') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/inicio', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/inicio', esMovil: false),
                _hero(esMovil),
                _buscador(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _descubreVenezuela(esMovil),
                          const SizedBox(height: 40),
                          _seccionServicios(
                            esMovil,
                            constraints.maxWidth,
                            titulo: 'Servicios destacados',
                            skipAlojamientos: 0,
                            skipExperiencias: 0,
                          ),
                          const SizedBox(height: 48),
                          _seccionServicios(
                            esMovil,
                            constraints.maxWidth,
                            titulo: 'Aprovecha las ofertas',
                            skipAlojamientos: 4,
                            skipExperiencias: 3,
                          ),
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

  // --------------------------------------------------------------- HERO
  Widget _hero(bool esMovil) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: esMovil ? 260 : 380,
          width: double.infinity,
          child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
        ),
        Container(
          height: esMovil ? 260 : 380,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Encuentra tu próxima aventura',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: esMovil ? 28 : 44,
                fontWeight: FontWeight.w700,
                shadows: const [
                  Shadow(blurRadius: 12, color: Colors.black87)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------- BUSCADOR
  Widget _buscador(bool esMovil) {
    return Container(
      color: AppColors.verdeOscuro,
      padding: EdgeInsets.symmetric(
          horizontal: esMovil ? 20 : 48, vertical: 24),
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
              BarraBuscadora(
                onBuscar: _buscar,
                onFiltrosAplicados: () =>
                    _navegarPorResultados(context.read<CatalogController>()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------- DESCUBRE VENEZUELA
  Widget _descubreVenezuela(bool esMovil) {
    final catalogo = context.watch<CatalogController>();

    final imagenPorEstado = <String, String>{};
    for (final servicio in catalogo.resultados) {
      if (servicio.estado.isEmpty) continue;
      imagenPorEstado.putIfAbsent(
          servicio.estado, () => servicio.imagenPrincipal);
    }
    const curados = ['Nueva Esparta', 'Mérida', 'Miranda', 'La Guaira'];
    for (final estado in curados) {
      if (imagenPorEstado.length >= 4) break;
      imagenPorEstado.putIfAbsent(estado, () => '');
    }
    final destinos = imagenPorEstado.entries.take(4).toList();

    final tarjetas = destinos
        .map(
          (d) => InkWell(
            onTap: () => _irADestino(d.key),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 140,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (d.value.isNotEmpty)
                    ImagenServicio(
                      url: d.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) =>
                          const ColoredBox(color: Color(0xFFD9D9D9)),
                    ),
                  Container(
                      color: Colors.black.withValues(alpha: 0.25)),
                  Center(
                    child: Text(
                      d.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black54)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descubre Venezuela',
          style: TextStyle(
              color: AppColors.blanco,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        esMovil
            ? GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: tarjetas,
              )
            : Row(
                children: [
                  for (var i = 0; i < tarjetas.length; i++) ...[
                    Expanded(child: tarjetas[i]),
                    if (i < tarjetas.length - 1) const SizedBox(width: 14),
                  ],
                ],
              ),
      ],
    );
  }

  // ---- SERVICIOS DESTACADOS + APROVECHA LAS OFERTAS (componente compartido)
  Widget _seccionServicios(
    bool esMovil,
    double anchoPantalla, {
    required String titulo,
    required int skipAlojamientos,
    required int skipExperiencias,
  }) {
    final catalogo = context.watch<CatalogController>();

    if (catalogo.cargando) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }

    final alojamientos = catalogo.resultados
        .where((s) => s.tipo == TiposServicio.alojamiento)
        .skip(skipAlojamientos)
        .take(4)
        .toList();
    final experiencias = catalogo.resultados
        .where((s) => s.tipo == TiposServicio.experiencia)
        .skip(skipExperiencias)
        .take(3)
        .toList();

    int columnas = 4;
    if (anchoPantalla < 600) {
      columnas = 1;
    } else if (anchoPantalla < 900) {
      columnas = 2;
    } else if (anchoPantalla < 1100) {
      columnas = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: AppColors.amarillo,
            fontSize: esMovil ? 20 : 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Alojamientos',
          style: TextStyle(
              color: AppColors.blanco,
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        alojamientos.isEmpty
            ? _sinServicios('Aún no hay alojamientos publicados.')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 300 / 350,
                ),
                itemCount: alojamientos.length.clamp(0, columnas),
                itemBuilder: (context, i) => ServicioCard(
                  servicio: alojamientos[i],
                  alReservar: () => Navigator.of(context).pushNamed(
                      '/servicio',
                      arguments: alojamientos[i].id),
                ),
              ),
        const SizedBox(height: 24),
        const Text(
          'Experiencias',
          style: TextStyle(
              color: AppColors.blanco,
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        experiencias.isEmpty
            ? _sinServicios('Aún no hay experiencias publicadas.')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas.clamp(1, 3),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 300 / 350,
                ),
                itemCount: experiencias.length,
                itemBuilder: (context, i) => ServicioCard(
                  servicio: experiencias[i],
                  alReservar: () => Navigator.of(context)
                      .pushNamed('/servicio', arguments: experiencias[i].id),
                ),
              ),
      ],
    );
  }

  Widget _sinServicios(String mensaje) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(mensaje,
            style: const TextStyle(color: AppColors.verdeClaro)),
      ),
    );
  }
}
