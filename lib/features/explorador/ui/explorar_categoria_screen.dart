import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/barra_buscadora.dart';
import '../../../models/servicio.dart';
import '../../catalog/logic/catalog_controller.dart';
import '../../catalog/ui/widgets/servicio_card.dart';

enum CategoriaExploracion { alojamientos, experiencias }

class ExplorarCategoriaScreen extends StatefulWidget {
  final CategoriaExploracion categoria;

  const ExplorarCategoriaScreen({super.key, required this.categoria});

  @override
  State<ExplorarCategoriaScreen> createState() =>
      _ExplorarCategoriaScreenState();
}

class _ExplorarCategoriaScreenState extends State<ExplorarCategoriaScreen> {
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

  String get _titulo => widget.categoria == CategoriaExploracion.alojamientos
      ? 'Alojamientos'
      : 'Experiencias';

  String get _ruta => widget.categoria == CategoriaExploracion.alojamientos
      ? '/alojamientos'
      : '/experiencias';

  String get _tipoFiltro =>
      widget.categoria == CategoriaExploracion.alojamientos
          ? TiposServicio.alojamiento
          : TiposServicio.experiencia;

  int get _columnasBase =>
      widget.categoria == CategoriaExploracion.alojamientos ? 4 : 3;

  void _buscar(String texto) {
    final catalogo = context.read<CatalogController>();
    catalogo.actualizarTexto(texto.trim().toLowerCase());
    catalogo.buscarLocalmente();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? AppDrawer(rutaActual: _ruta) : null,
          appBar: esMovil
              ? AppHeader(rutaActual: _ruta, esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!esMovil) AppHeader(rutaActual: _ruta, esMovil: false),
                _hero(esMovil),
                _buscador(esMovil),
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
                          _grilla(esMovil, constraints.maxWidth),
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
              _titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: esMovil ? 28 : 44,
                fontWeight: FontWeight.w700,
                shadows: const [Shadow(blurRadius: 12, color: Colors.black87)],
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

  Widget _grilla(bool esMovil, double anchoPantalla) {
    final catalogo = context.watch<CatalogController>();

    if (catalogo.cargando) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final servicios = catalogo.resultados
        .where((s) => s.tipo == _tipoFiltro)
        .toList();

    if (servicios.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.verde,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'Aún no hay $_titulo publicados.',
            style: const TextStyle(color: AppColors.verdeClaro),
          ),
        ),
      );
    }

    int columnas = _columnasBase;
    if (anchoPantalla < 600) {
      columnas = 1;
    } else if (anchoPantalla < 900) {
      columnas = 2;
    } else if (anchoPantalla < 1100 && _columnasBase == 4) {
      columnas = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 300 / 350,
      ),
      itemCount: servicios.length,
      itemBuilder: (context, i) => ServicioCard(
        servicio: servicios[i],
        alReservar: () => Navigator.of(context)
            .pushNamed('/servicio', arguments: servicios[i].id),
      ),
    );
  }
}
