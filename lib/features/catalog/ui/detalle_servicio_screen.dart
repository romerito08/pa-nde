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
    final altura = esMovil ? 220.0 : 380.0;
    if (servicio.imagenes.isEmpty) {
      return Container(
        height: altura,
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
    return SizedBox(
      height: altura,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: servicio.imagenes.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, indice) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImagenServicio(
              url: servicio.imagenes[indice],
              height: altura,
              width: servicio.imagenes.length == 1
                  ? (esMovil ? 600 : 1020)
                  : (esMovil ? 320 : 560),
              fit: BoxFit.cover,
              errorBuilder: (context, _, _) => Container(
                width: esMovil ? 320 : 560,
                color: AppColors.verde,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: AppColors.verdeClaro),
                ),
              ),
            ),
          );
        },
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
