import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/venezuela_geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/barra_buscadora.dart';
import '../../catalog/logic/catalog_controller.dart';

class DestinosScreen extends StatefulWidget {
  const DestinosScreen({super.key});

  @override
  State<DestinosScreen> createState() => _DestinosScreenState();
}

class _DestinosScreenState extends State<DestinosScreen> {
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

  void _irADestino(String estado) {
    final catalogo = context.read<CatalogController>();
    catalogo.actualizarUbicacion(estado, null);
    catalogo.buscar();
    Navigator.of(context).pushNamed('/explorar');
  }

  void _buscar(String _) => Navigator.of(context).pushNamed('/explorar');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/destinos') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/destinos', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/destinos', esMovil: false),
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
              'Destinos',
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
                '¿A qué estado quieres ir?',
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

    final imagenPorEstado = <String, String>{};
    for (final s in catalogo.resultados) {
      if (s.estado.isNotEmpty) {
        imagenPorEstado.putIfAbsent(s.estado, () => s.imagenPrincipal);
      }
    }

    final estados = VenezuelaGeo.estados;

    int columnas = 3;
    if (anchoPantalla < 600) {
      columnas = 2;
    } else if (anchoPantalla < 900) {
      columnas = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descubre Venezuela',
          style: TextStyle(
            color: AppColors.amarillo,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
          ),
          itemCount: estados.length,
          itemBuilder: (context, i) {
            final estado = estados[i];
            final imagen = imagenPorEstado[estado] ?? '';
            return InkWell(
              onTap: () => _irADestino(estado),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imagen.isNotEmpty)
                      Image.network(
                        imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
                      ),
                    Container(color: Colors.black.withValues(alpha: 0.30)),
                    Center(
                      child: Text(
                        estado,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
            );
          },
        ),
      ],
    );
  }
}
