import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/selector_geografico.dart';
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
  final _presupuestoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Repone el presupuesto cuando se regresa con filtros activos.
    final catalogo = context.read<CatalogController>();
    _presupuestoController.text = catalogo.presupuestoMaximo == null
        ? ''
        : catalogo.presupuestoMaximo!.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _presupuestoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final catalogo = context.read<CatalogController>();
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: catalogo.fecha ?? hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.amarillo,
            onPrimary: Colors.black,
            surface: AppColors.verde,
            onSurface: AppColors.blanco,
          ),
        ),
        child: child!,
      ),
    );
    if (seleccionada != null && mounted) {
      context.read<CatalogController>().actualizarFecha(seleccionada);
    }
  }

  void _buscar() {
    final catalogo = context.read<CatalogController>();
    catalogo.actualizarPresupuesto(_presupuestoController.text);
    catalogo.buscar();
  }

  void _limpiar() {
    _presupuestoController.clear();
    context.read<CatalogController>().limpiarFiltros();
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
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _barraFiltros(esMovil),
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
          // Escala el bloque en viewports diminutos (primer frame de Flutter
          // Web) para que el hero de altura fija nunca desborde.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "¿Pa'onde quieres ir?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blanco,
                    fontSize: esMovil ? 28 : 40,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(blurRadius: 10, color: Colors.black87)
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Turismo low-cost y sostenible por toda Venezuela',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blanco,
                    fontSize: esMovil ? 14 : 18,
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black87)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _barraFiltros(bool esMovil) {
    final catalogo = context.watch<CatalogController>();
    final formatoFecha = DateFormat('dd/MM/yyyy');

    // Dropdowns estandarizados de Estado y Municipio (nunca texto libre).
    final campoUbicacion = SelectorGeografico(
      estado: catalogo.estado,
      municipio: catalogo.municipio,
      permitirTodos: true,
      enFila: !esMovil,
      onChanged: (estado, municipio) => context
          .read<CatalogController>()
          .actualizarUbicacion(estado, municipio),
    );

    final campoFecha = InkWell(
      onTap: _seleccionarFecha,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.calendar_today_outlined,
              color: AppColors.verdeClaro, size: 20),
        ),
        child: Text(
          catalogo.fecha == null
              ? 'Cualquier fecha'
              : formatoFecha.format(catalogo.fecha!),
          style: TextStyle(
            color: catalogo.fecha == null
                ? AppColors.verdeClaro
                : AppColors.blanco,
            fontSize: 14,
          ),
        ),
      ),
    );

    final campoPresupuesto = TextField(
      controller: _presupuestoController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.blanco),
      onSubmitted: (_) => _buscar(),
      decoration: const InputDecoration(
        labelText: 'Presupuesto máx. (USD)',
        prefixIcon: Icon(Icons.attach_money_outlined,
            color: AppColors.verdeClaro, size: 20),
      ),
    );

    final botones = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _buscar,
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Buscar'),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: _limpiar,
          icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
          label: const Text('Limpiar Filtros'),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: esMovil
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                campoUbicacion,
                const SizedBox(height: 12),
                campoFecha,
                const SizedBox(height: 12),
                campoPresupuesto,
                const SizedBox(height: 16),
                botones,
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 5, child: campoUbicacion),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: campoFecha),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: campoPresupuesto),
                  ],
                ),
                const SizedBox(height: 14),
                botones,
              ],
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
                onPressed: _limpiar,
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
