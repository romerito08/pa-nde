import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/imagen_servicio.dart';
import '../../../models/servicio.dart';
import '../../auth/logic/auth_controller.dart';
import '../../bookings/logic/booking_controller.dart';
import '../../bookings/ui/widgets/calendario_disponibilidad.dart';
import '../../quotes/logic/quotes_controller.dart';
import '../../quotes/ui/widgets/solicitar_cotizacion_dialog.dart';
import '../../reviews/logic/review_controller.dart';
import '../../reviews/ui/review_section.dart';
import '../data/catalog_repository.dart';

/// Vista detallada del servicio: galería por URL, cabecera con promedio de
/// estrellas recalculado en tiempo real (RF06), calendario interactivo que
/// consulta `calendarios` (RF05), selector de huéspedes y solicitud de
/// reserva. Responsiva: dos columnas en Web, una en móvil.
class DetalleServicioScreen extends StatefulWidget {
  final String servicioId;

  const DetalleServicioScreen({super.key, required this.servicioId});

  @override
  State<DetalleServicioScreen> createState() => _DetalleServicioScreenState();
}

class _DetalleServicioScreenState extends State<DetalleServicioScreen> {
  final _repositorio = CatalogRepository();
  late Future<Servicio> _futuroServicio;

  @override
  void initState() {
    super.initState();
    _futuroServicio = _repositorio.obtenerServicio(widget.servicioId);
  }

  void _reintentar() {
    setState(() {
      _futuroServicio = _repositorio.obtenerServicio(widget.servicioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Servicio>(
      future: _futuroServicio,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle del servicio')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      color: AppColors.verdeClaro, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error?.toString() ??
                        'No pudimos cargar el servicio.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.blanco),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _reintentar,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final servicio = snapshot.data!;
        // Providers con ámbito de pantalla: reseñas y flujo de reserva.
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => ReviewController(servicioId: servicio.id)),
            ChangeNotifierProvider(
                create: (_) => BookingController(servicio: servicio)),
          ],
          child: _Contenido(servicio: servicio),
        );
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  final Servicio servicio;

  const _Contenido({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 900;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/servicio') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/servicio', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/servicio', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _galeria(esMovil),
                          const SizedBox(height: 20),
                          _cabecera(context),
                          const SizedBox(height: 20),
                          esMovil
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _descripcion(context),
                                    const SizedBox(height: 24),
                                    _panelReserva(context),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 3, child: _descripcion(context)),
                                    const SizedBox(width: 32),
                                    Expanded(
                                        flex: 2, child: _panelReserva(context)),
                                  ],
                                ),
                          const SizedBox(height: 40),
                          const ReviewSection(),
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

  Widget _galeria(bool esMovil) {
    final imagenes = servicio.imagenes;
    final alturaTotal = esMovil ? 260.0 : 440.0;

    if (imagenes.isEmpty) {
      return Container(
        height: alturaTotal,
        decoration: BoxDecoration(
          color: AppColors.verde,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.landscape_outlined,
              size: 64, color: AppColors.verdeClaro),
        ),
      );
    }

    // 1 imagen: hero completo
    if (imagenes.length == 1) {
      return _tileImagen(
        imagenes[0],
        alturaTotal,
        BorderRadius.circular(16),
        0,
        imagenes.length,
      );
    }

    // 2 imágenes: dos columnas iguales
    if (imagenes.length == 2) {
      final h = alturaTotal * 0.65;
      return SizedBox(
        height: h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _tileImagen(
                imagenes[0], h,
                const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                0, imagenes.length,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _tileImagen(
                imagenes[1], h,
                const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                1, imagenes.length,
              ),
            ),
          ],
        ),
      );
    }

    // 3+ imágenes: hero izquierda + grid derecha (hasta 4 visibles en total)
    const maxVisibles = 4;
    final rightImages = imagenes.skip(1).take(maxVisibles - 1).toList();
    final extras = imagenes.length - maxVisibles; // imágenes ocultas

    return SizedBox(
      height: alturaTotal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero principal
          Expanded(
            flex: 3,
            child: _tileImagen(
              imagenes[0], alturaTotal,
              const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              0, imagenes.length,
            ),
          ),
          const SizedBox(width: 8),
          // Grid derecho
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < rightImages.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _tileImagen(
                          rightImages[i],
                          alturaTotal / rightImages.length,
                          _borderGrilla(i, rightImages.length),
                          i + 1, imagenes.length,
                        ),
                        // Badge "+N" en la última celda si hay más imágenes
                        if (i == rightImages.length - 1 && extras > 0)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: _borderGrilla(i, rightImages.length),
                              child: ColoredBox(
                                color: Colors.black54,
                                child: Center(
                                  child: Text(
                                    '+$extras',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileImagen(
    String url,
    double altura,
    BorderRadius radio,
    int indice,
    int total,
  ) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _verImagenAmpliada(context, indice),
        child: ClipRRect(
          borderRadius: radio,
          child: ImagenServicio(
            url: url,
            height: altura,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, _, _) => Container(
              color: AppColors.verde,
              child: const Center(
                child: Icon(Icons.broken_image_outlined,
                    size: 40, color: AppColors.verdeClaro),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius _borderGrilla(int indice, int total) {
    if (indice == 0 && total == 1) {
      return const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    }
    if (indice == 0) {
      return const BorderRadius.only(topRight: Radius.circular(16));
    }
    if (indice == total - 1) {
      return const BorderRadius.only(bottomRight: Radius.circular(16));
    }
    return BorderRadius.zero;
  }

  void _verImagenAmpliada(BuildContext context, int indiceInicial) {
    final imagenes = servicio.imagenes;
    showDialog<void>(
      context: context,
      builder: (_) => _DialogoGaleria(
        imagenes: imagenes,
        indiceInicial: indiceInicial,
      ),
    );
  }

  /// Cabecera con el promedio de estrellas reactivo: observa el
  /// [ReviewController], así cada comentario nuevo actualiza el valor al
  /// instante sin recargar la pantalla (RF06).
  Widget _cabecera(BuildContext context) {
    final resenas = context.watch<ReviewController>();
    final promedio =
        resenas.totalResenas > 0 ? resenas.promedio : servicio.calificacionPromedio;
    final total =
        resenas.totalResenas > 0 ? resenas.totalResenas : servicio.totalResenas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(servicio.nombre,
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.verde,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.amarillo, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    promedio.toStringAsFixed(1),
                    style: const TextStyle(
                        color: AppColors.blanco,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                  Text(
                    '  ($total reseñas)',
                    style: const TextStyle(
                        color: AppColors.verdeClaro, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 16, color: AppColors.verdeClaro),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${servicio.ubicacion}${servicio.direccion.isEmpty ? '' : ' — ${servicio.direccion}'}',
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: AppColors.verdeClaro, fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.verdeOscuro,
                border: Border.all(color: AppColors.verdeClaro),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(servicio.tipo,
                  style: const TextStyle(
                      color: AppColors.amarillo, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _descripcion(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sobre este servicio',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          servicio.descripcion,
          style: const TextStyle(
              color: AppColors.blanco, fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.group_outlined,
                color: AppColors.verdeClaro, size: 18),
            const SizedBox(width: 6),
            Text(
              'Capacidad: hasta ${servicio.capacidad} personas',
              style:
                  const TextStyle(color: AppColors.verdeClaro, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _panelReserva(BuildContext context) {
    final reserva = context.watch<BookingController>();
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.verdeOscuro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${servicio.precio.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: AppColors.amarillo,
                    fontSize: 32,
                    fontWeight: FontWeight.w700),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  '/ ${servicio.unidadPrecio}',
                  style: const TextStyle(
                      color: AppColors.verdeClaro, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            servicio.esExperiencia
                ? 'Elige el día de tu experiencia'
                : 'Elige tus fechas (entrada y salida)',
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const CalendarioDisponibilidad(),
          if (reserva.fechaInicio != null) ...[
            const SizedBox(height: 10),
            _chipCupos(reserva),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Huéspedes',
                  style: TextStyle(color: AppColors.blanco, fontSize: 15)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.verdeClaro),
                    onPressed: () => context
                        .read<BookingController>()
                        .cambiarHuespedes(reserva.huespedes - 1),
                  ),
                  Text('${reserva.huespedes}',
                      style: const TextStyle(
                          color: AppColors.blanco,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.amarillo),
                    onPressed: () => context
                        .read<BookingController>()
                        .cambiarHuespedes(reserva.huespedes + 1),
                  ),
                ],
              ),
            ],
          ),
          if (reserva.fechaInicio != null) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reserva.fechaFin == null
                      ? formatoFecha.format(reserva.fechaInicio!)
                      : '${formatoFecha.format(reserva.fechaInicio!)} → ${formatoFecha.format(reserva.fechaFin!)}',
                  style: const TextStyle(
                      color: AppColors.blanco, fontSize: 14),
                ),
                Text(
                  reserva.totalEstimado > 0
                      ? 'Total: \$${reserva.totalEstimado.toStringAsFixed(2)}'
                      : '',
                  style: const TextStyle(
                      color: AppColors.amarillo,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          reserva.procesando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reserva directa: valida disponibilidad en `calendarios`
                    // y abre la pasarela de pago de inmediato.
                    ElevatedButton.icon(
                      onPressed: () => _reservarDirecto(context),
                      icon: const Icon(Icons.bolt_outlined, size: 18),
                      label: const Text('Reservar'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _solicitarCotizacion(context),
                      icon: const Icon(Icons.request_quote_outlined, size: 18),
                      label: const Text('Solicitar una Cotización'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _chipCupos(BookingController reserva) {
    final dia = reserva.fechaInicio!;
    final cupos = reserva.cuposDisponiblesEn(dia);
    final total = servicio.cuposPorDia;
    final Color color;
    final IconData icono;
    if (cupos == 0) {
      color = AppColors.error;
      icono = Icons.event_busy_outlined;
    } else if (cupos <= (total / 2).ceil()) {
      color = AppColors.advertencia;
      icono = Icons.event_available_outlined;
    } else {
      color = AppColors.exito;
      icono = Icons.event_available_outlined;
    }
    final texto = cupos == 0
        ? 'Sin cupos para esa fecha'
        : cupos == 1
            ? '1 cupo disponible'
            : '$cupos cupos disponibles';

    return Row(
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Text(
          ' de $total',
          style:
              const TextStyle(color: AppColors.verdeClaro, fontSize: 13),
        ),
      ],
    );
  }

  /// Flujo de reserva directa: si `calendarios` confirma disponibilidad, la
  /// reserva se crea automáticamente en "Pendiente de Pago" y la interfaz de
  /// la pasarela aparece inmediatamente después del clic en "Reservar".
  Future<void> _reservarDirecto(BuildContext context) async {
    final auth = context.read<AuthController>();
    if (!auth.autenticado) {
      FeedbackHelper.mostrarAdvertencia(context, 'Inicia sesión para reservar.');
      Navigator.of(context).pushNamed('/login');
      return;
    }
    final (reservaCreada, mensajeError) =
        await context.read<BookingController>().reservarDirecto(auth.usuario);
    if (!context.mounted) return;
    if (reservaCreada != null) {
      Navigator.of(context).pushNamed('/checkout', arguments: reservaCreada);
    } else {
      FeedbackHelper.mostrarError(
          context, mensajeError ?? 'No fue posible procesar la reserva.');
    }
  }

  /// Abre el visor de imágenes en pantalla completa con navegación.
  // (declarado en _galeria como closure)

  /// Alternativa a la reserva directa: crea una solicitud en la colección
  /// `cotizaciones` para que el Aliado responda con su feedback.
  Future<void> _solicitarCotizacion(BuildContext context) async {
    final auth = context.read<AuthController>();
    if (!auth.autenticado) {
      FeedbackHelper.mostrarAdvertencia(
          context, 'Inicia sesión para solicitar una cotización.');
      Navigator.of(context).pushNamed('/login');
      return;
    }
    final reserva = context.read<BookingController>();
    final quotes = context.read<QuotesController>();
    final enviada = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: quotes,
        child: SolicitarCotizacionDialog(
          servicio: servicio,
          fechaInicio: reserva.fechaInicio,
          fechaFin: reserva.fechaFin,
          huespedes: reserva.huespedes,
        ),
      ),
    );
    if (enviada == true && context.mounted) {
      FeedbackHelper.mostrarExito(
          context,
          'Solicitud enviada. El aliado te responderá en "Mis Reservas → Cotizaciones".');
    }
  }
}

// ---------------------------------------------------------------------------
// Visor de galería a pantalla completa con PageView y contador
// ---------------------------------------------------------------------------

class _DialogoGaleria extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;

  const _DialogoGaleria({
    required this.imagenes,
    required this.indiceInicial,
  });

  @override
  State<_DialogoGaleria> createState() => _DialogoGaleriaState();
}

class _DialogoGaleriaState extends State<_DialogoGaleria> {
  late final PageController _pagCtrl;
  late int _actual;

  @override
  void initState() {
    super.initState();
    _actual = widget.indiceInicial;
    _pagCtrl = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    _pagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // Visor con PageView
          PageView.builder(
            controller: _pagCtrl,
            itemCount: widget.imagenes.length,
            onPageChanged: (i) => setState(() => _actual = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: ImagenServicio(
                  url: widget.imagenes[i],
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.verdeClaro,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),

          // Botón cerrar
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Contador "2 / 5"
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_actual + 1} / ${widget.imagenes.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),

          // Flechas de navegación (solo si hay más de 1 imagen)
          if (widget.imagenes.length > 1) ...[
            if (_actual > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 40),
                    onPressed: () =>
                        _pagCtrl.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),
              ),
            if (_actual < widget.imagenes.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 40),
                    onPressed: () =>
                        _pagCtrl.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
