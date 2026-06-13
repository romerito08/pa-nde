import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/venezuela_geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../models/servicio.dart';
import '../../auth/logic/auth_controller.dart';
import '../../catalog/logic/catalog_controller.dart';
import '../../catalog/ui/widgets/servicio_card.dart';

/// Landing Page principal, fiel al prototipo de Figma:
/// hero a sangre completa con el wordmark y los botones de sesión arriba a
/// la derecha, "¿Qué te ofrecemos?" (3 filas), "Descubre tu lugar en
/// paonde" con el toggle Explorador/Aliado, buscador central, "Descubre
/// Venezuela", "Servicios destacados" (alojamientos en grid y experiencias
/// horizontales con tarjetas blancas) y el footer con "Sé un Aliado" —
/// único punto de entrada al registro de Aliados.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _buscadorController = TextEditingController();

  /// Toggle de la sección "Descubre tu lugar": 0 = Explorador, 1 = Aliado.
  int _vistaSeleccionada = 0;

  static const _ofertas = [
    (
      icono: Icons.apartment_outlined,
      titulo: 'Alojamientos',
      detalle:
          'Encuentra el hospedaje perfecto para cada tipo de viaje. Filtra '
          'por ubicación, fechas, presupuesto y tipo de alojamiento: '
          'hoteles, posadas, apartamentos y más.',
    ),
    (
      icono: Icons.explore_outlined,
      titulo: 'Experiencias',
      detalle:
          'Descubre actividades únicas con operadores locales de confianza. '
          'Desde rutas de montaña hasta experiencias gastronómicas, siempre '
          'con reseñas verificadas.',
    ),
    (
      icono: Icons.directions_car_outlined,
      titulo: 'Logística y Traslados',
      detalle:
          'Viaja sin complicaciones. Encuentra experiencias y paquetes que '
          'ya incluyen el traslado al destino, asegurando que llegues de '
          'forma cómoda y segura a cada aventura.',
    ),
  ];

  static const _pilaresExplorador = [
    (
      icono: Icons.search,
      titulo: 'Exploración Inteligente',
      detalle:
          'Busca por destino, fechas y presupuesto. Los filtros avanzados '
          'te llevan directo a lo que necesitas, sin perder tiempo.',
    ),
    (
      icono: Icons.star_border,
      titulo: 'Reserva con Confianza',
      detalle:
          'Cada Aliado está verificado por el equipo Pa\'onde. Lee reseñas '
          'reales antes de reservar y decide con información de verdad.',
    ),
    (
      icono: Icons.check,
      titulo: 'Todo en un Solo Lugar',
      detalle:
          'Alojamiento, experiencias y traslados juntos. Organiza tu viaje '
          'completo sin salir de la plataforma.',
    ),
  ];

  static const _pilaresAliado = [
    (
      icono: Icons.storefront_outlined,
      titulo: 'Vitrina para tu Negocio',
      detalle:
          'Publica tus alojamientos y experiencias en minutos y llega a '
          'toda la comunidad de exploradores de Pa\'onde.',
    ),
    (
      icono: Icons.event_available_outlined,
      titulo: 'Reservas Automáticas',
      detalle:
          'Tu calendario se gestiona solo: las fechas se bloquean al '
          'reservar y los pagos se confirman al instante.',
    ),
    (
      icono: Icons.query_stats_outlined,
      titulo: 'Métricas Reales',
      detalle:
          'Sigue tus ganancias, reservas y reseñas desde tu dashboard, y '
          'responde cotizaciones desde tu bandeja de entrada.',
    ),
  ];

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  /// El buscador de la Landing intenta resolver el texto contra la
  /// estructura geográfica oficial (estado o municipio); si hay match deja
  /// el filtro aplicado y siempre navega al catálogo.
  void _buscarDesdeLanding() {
    final consulta = _buscadorController.text.trim().toLowerCase();
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
        catalogo.buscar();
      } else if (municipioEncontrado != null) {
        catalogo.actualizarUbicacion(estadoDelMunicipio, municipioEncontrado);
        catalogo.buscar();
      } else {
        catalogo.limpiarFiltros();
      }
    }
    Navigator.of(context).pushNamed('/explorar');
  }

  void _irADestino(String estado) {
    final catalogo = context.read<CatalogController>();
    catalogo.actualizarUbicacion(estado, null);
    catalogo.buscar();
    Navigator.of(context).pushNamed('/explorar');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/') : null,
          appBar:
              esMovil ? const AppHeader(rutaActual: '/', esMovil: true) : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _hero(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _seccionQueTeOfrecemos(esMovil),
                          const SizedBox(height: 64),
                          _seccionDescubreTuLugar(esMovil),
                          const SizedBox(height: 72),
                          _seccionAventura(esMovil),
                          const SizedBox(height: 56),
                          _seccionDescubreVenezuela(esMovil),
                          const SizedBox(height: 40),
                          _seccionServiciosDestacados(
                              esMovil, constraints.maxWidth),
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

  // ---------------------------------------------------------------- HERO
  Widget _hero(bool esMovil) {
    final auth = context.watch<AuthController>();
    return Stack(
      children: [
        SizedBox(
          height: esMovil ? 300 : 420,
          width: double.infinity,
          child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
        ),
        Container(
          height: esMovil ? 300 : 420,
          color: Colors.black.withValues(alpha: 0.25),
        ),
        // Wordmark centrado + eslogan, como en el prototipo. El FittedBox
        // escala el bloque hacia abajo en cualquier viewport (incluido el
        // primer frame diminuto de Flutter Web), evitando overflows que
        // congelan el árbol de render con pantalla negra.
        Positioned.fill(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Logo.png',
                      width: esMovil ? 220 : 360, fit: BoxFit.contain),
                  const SizedBox(height: 10),
                  Text(
                    'Pa\'onde quieras te llevamos',
                    style: TextStyle(
                      color: AppColors.amarillo,
                      fontSize: esMovil ? 14 : 17,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black87)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Botones de sesión arriba a la derecha.
        Positioned(
          top: 16,
          right: esMovil ? 12 : 28,
          child: auth.autenticado
              ? Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/perfil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amarillo,
                        side: const BorderSide(
                            color: AppColors.amarillo, width: 1.5),
                        backgroundColor: Colors.black26,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Mi Perfil'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(auth.rutaSegunRol == '/'
                              ? '/explorar'
                              : auth.rutaSegunRol),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Mi Panel'),
                    ),
                  ],
                )
              : Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amarillo,
                        side: const BorderSide(
                            color: AppColors.amarillo, width: 1.5),
                        backgroundColor: Colors.black26,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/registro'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Registrarse'),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ------------------------------------------- ¿QUÉ TE OFRECEMOS? (3 filas)
  Widget _seccionQueTeOfrecemos(bool esMovil) {
    return Column(
      children: [
        Text('¿Qué te ofrecemos?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 28),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: _ofertas
                  .map(
                    (oferta) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.verde,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(oferta.icono,
                              size: 38, color: AppColors.blanco),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  oferta.titulo,
                                  style: const TextStyle(
                                      color: AppColors.amarillo,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  oferta.detalle,
                                  style: const TextStyle(
                                      color: AppColors.blanco,
                                      fontSize: 13,
                                      height: 1.45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------- DESCUBRE TU LUGAR (toggle Explorador/Aliado)
  Widget _seccionDescubreTuLugar(bool esMovil) {
    final pilares =
        _vistaSeleccionada == 0 ? _pilaresExplorador : _pilaresAliado;

    final tarjetas = pilares
        .map(
          (pilar) => Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.blanco, width: 1.6),
                  ),
                  child:
                      Icon(pilar.icono, size: 24, color: AppColors.blanco),
                ),
                const SizedBox(height: 16),
                Text(
                  pilar.titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.amarillo,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  pilar.detalle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.blanco, fontSize: 12.5, height: 1.5),
                ),
              ],
            ),
          ),
        )
        .toList();

    return Column(
      children: [
        Text('Descubre tu lugar en paonde',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        // Toggle segmentado Explorador / Aliado del prototipo.
        Center(
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.verdeClaro.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _opcionToggle('Explorador', 0),
                _opcionToggle('Aliado', 1),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        esMovil
            ? Column(
                children: [
                  for (final tarjeta in tarjetas) ...[
                    tarjeta,
                    const SizedBox(height: 16),
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < tarjetas.length; i++) ...[
                    Expanded(child: tarjetas[i]),
                    if (i < tarjetas.length - 1) const SizedBox(width: 20),
                  ],
                ],
              ),
        if (_vistaSeleccionada == 1) ...[
          const SizedBox(height: 16),
          const Text(
            '¿Listo para unirte? Encuentra "Sé un Aliado" en el pie de página.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.verdeClaro, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _opcionToggle(String titulo, int indice) {
    final seleccionado = _vistaSeleccionada == indice;
    return InkWell(
      onTap: () => setState(() => _vistaSeleccionada = indice),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.amarillo : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: seleccionado ? Colors.black : AppColors.verdeOscuro,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ------------------------------- TU PRÓXIMA AVENTURA + BUSCADOR CENTRAL
  Widget _seccionAventura(bool esMovil) {
    return Column(
      children: [
        Text(
          'Tu próxima aventura comienza aquí',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.amarillo,
            fontSize: esMovil ? 26 : 36,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¿Pa\'onde quieres ir?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.blanco, fontSize: 16),
        ),
        const SizedBox(height: 14),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _buscadorController,
                      onSubmitted: (_) => _buscarDesdeLanding(),
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 13),
                      cursorColor: Colors.black54,
                      decoration: InputDecoration(
                        hintText: 'Escribe un destino, experiencia o servicio...',
                        hintStyle: const TextStyle(
                            color: Colors.black38, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.black38, size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.amarillo),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _buscarDesdeLanding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Icon(Icons.tune, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------- DESCUBRE VENEZUELA
  Widget _seccionDescubreVenezuela(bool esMovil) {
    final catalogo = context.watch<CatalogController>();

    // Destinos reales derivados del catálogo (un servicio representativo por
    // estado); si aún no hay suficientes, se completan con destinos curados.
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
          (destino) => InkWell(
            onTap: () => _irADestino(destino.key),
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
                  if (destino.value.isNotEmpty)
                    Image.network(
                      destino.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) =>
                          Container(color: const Color(0xFFD9D9D9)),
                    ),
                  Container(color: Colors.black.withValues(alpha: 0.25)),
                  Center(
                    child: Text(
                      destino.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
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
        Text('Descubre Venezuela',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
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
                    if (i < tarjetas.length - 1) const SizedBox(width: 16),
                  ],
                ],
              ),
      ],
    );
  }

  // --------------------------------------------- SERVICIOS DESTACADOS
  Widget _seccionServiciosDestacados(bool esMovil, double anchoPantalla) {
    final catalogo = context.watch<CatalogController>();

    if (catalogo.cargando) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (catalogo.error != null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.verde,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(catalogo.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.blanco)),
        ),
      );
    }

    final alojamientos = catalogo.resultados
        .where((s) => s.tipo == TiposServicio.alojamiento)
        .take(4)
        .toList();
    final experiencias = catalogo.resultados
        .where((s) => s.tipo == TiposServicio.experiencia)
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
          'Servicios destacados',
          style: TextStyle(
            color: AppColors.amarillo,
            fontSize: esMovil ? 22 : 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text('Alojamientos', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        if (alojamientos.isEmpty)
          _sinServicios('Aún no hay alojamientos publicados.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 300 / 350,
            ),
            itemCount: alojamientos.length.clamp(0, columnas),
            itemBuilder: (context, indice) => ServicioCard(
              servicio: alojamientos[indice],
              alReservar: () => Navigator.of(context)
                  .pushNamed('/servicio', arguments: alojamientos[indice].id),
            ),
          ),
        const SizedBox(height: 28),
        Text('Experiencias', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        if (experiencias.isEmpty)
          _sinServicios('Aún no hay experiencias publicadas.')
        else if (esMovil)
          Column(
            children: experiencias
                .map(
                  (experiencia) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SizedBox(
                      height: 170,
                      child: ServicioCard(
                        servicio: experiencia,
                        horizontal: true,
                        alReservar: () => Navigator.of(context)
                            .pushNamed('/servicio', arguments: experiencia.id),
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        else
          Row(
            children: [
              for (var i = 0; i < experiencias.length; i++) ...[
                Expanded(
                  child: SizedBox(
                    height: 190,
                    child: ServicioCard(
                      servicio: experiencias[i],
                      horizontal: true,
                      alReservar: () => Navigator.of(context).pushNamed(
                          '/servicio',
                          arguments: experiencias[i].id),
                    ),
                  ),
                ),
                if (i < experiencias.length - 1) const SizedBox(width: 16),
              ],
            ],
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
