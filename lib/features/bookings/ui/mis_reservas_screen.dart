import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/imagen_servicio.dart';
import '../../../models/cotizacion.dart';
import '../../../models/reserva.dart';
import '../../auth/logic/auth_controller.dart';
import '../../catalog/logic/catalog_controller.dart';
import '../../catalog/logic/favoritos_controller.dart';
import '../../catalog/ui/widgets/servicio_card.dart';
import '../../quotes/logic/quotes_controller.dart';
import '../logic/mis_reservas_controller.dart';

/// "Mis Reservas" del Explorador, con tres pestañas:
/// - Reservas: flujo Pendiente de Pago → Pagado → Disfrutado.
/// - Cotizaciones: solicitudes enviadas y feedback del Aliado.
/// - Favoritos: servicios guardados con corazón (fusionado aquí).
class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalogo = context.read<CatalogController>();
      if (catalogo.resultados.isEmpty && !catalogo.cargando) {
        catalogo.buscarLocalmente();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/mis-reservas') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/mis-reservas', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/mis-reservas', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Mis Reservas',
                              style:
                                  Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 24),
                          if (!auth.autenticado)
                            _sinSesion(context)
                          else
                            _pestanas(context, auth.usuario!.uid, esMovil,
                                constraints.maxWidth),
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

  Widget _sinSesion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.verdeClaro, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Inicia sesión para ver tus reservas.',
            style: TextStyle(color: AppColors.blanco, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            child: const Text('Acceder'),
          ),
        ],
      ),
    );
  }

  Widget _pestanas(BuildContext context, String usuarioId, bool esMovil,
      double anchoPantalla) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TabBar(
              indicatorColor: AppColors.amarillo,
              labelColor: AppColors.amarillo,
              unselectedLabelColor: AppColors.verdeClaro,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                    icon: Icon(Icons.book_online_outlined, size: 18),
                    text: 'Reservas'),
                Tab(
                    icon: Icon(Icons.request_quote_outlined, size: 18),
                    text: 'Cotizaciones'),
                Tab(
                    icon: Icon(Icons.favorite_outline, size: 18),
                    text: 'Favoritos'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 620,
            child: TabBarView(
              children: [
                _listadoReservas(context, usuarioId, esMovil),
                _listadoCotizaciones(context, usuarioId),
                _listadoFavoritos(context, anchoPantalla),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pestaña Reservas ──────────────────────────────────────────────────────

  Widget _listadoReservas(
      BuildContext context, String usuarioId, bool esMovil) {
    final controlador = context.watch<MisReservasController>();

    return StreamBuilder<List<Reserva>>(
      stream: controlador.reservasDe(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'No pudimos cargar tus reservas. Verifica tu conexión.',
              style: TextStyle(color: AppColors.blanco),
            ),
          );
        }
        final reservas = snapshot.data ?? [];
        if (reservas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.travel_explore_outlined,
                    color: AppColors.verdeClaro, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Aún no tienes reservas. ¡Explora el catálogo y reserva tu próxima aventura!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.blanco, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/alojamientos'),
                  child: const Text('Explorar'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: reservas.length,
          separatorBuilder: (context, _) => const SizedBox(height: 16),
          itemBuilder: (context, indice) =>
              _TarjetaReserva(reserva: reservas[indice], esMovil: esMovil),
        );
      },
    );
  }

  // ── Pestaña Cotizaciones ──────────────────────────────────────────────────

  Widget _listadoCotizaciones(BuildContext context, String usuarioId) {
    final quotes = context.watch<QuotesController>();

    return StreamBuilder<List<Cotizacion>>(
      stream: quotes.cotizacionesDeUsuario(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'No pudimos cargar tus cotizaciones. Verifica tu conexión.',
              style: TextStyle(color: AppColors.blanco),
            ),
          );
        }
        final cotizaciones = snapshot.data ?? [];
        if (cotizaciones.isEmpty) {
          return const Center(
            child: Text(
              'No has solicitado cotizaciones todavía.\nEn el detalle de un servicio pulsa "Solicitar una Cotización".',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.verdeClaro, fontSize: 15),
            ),
          );
        }
        return ListView.separated(
          itemCount: cotizaciones.length,
          separatorBuilder: (context, _) => const SizedBox(height: 14),
          itemBuilder: (context, indice) =>
              _TarjetaCotizacionExplorador(cotizacion: cotizaciones[indice]),
        );
      },
    );
  }

  // ── Pestaña Favoritos ─────────────────────────────────────────────────────

  Widget _listadoFavoritos(BuildContext context, double anchoPantalla) {
    final favoritos = context.watch<FavoritosController>();
    final catalogo = context.watch<CatalogController>();

    if (catalogo.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoritos.lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border,
                color: AppColors.verdeClaro, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Aún no tienes favoritos.\nToca el corazón en cualquier servicio para guardarlo aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.blanco, fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/alojamientos'),
              child: const Text('Explorar'),
            ),
          ],
        ),
      );
    }

    final serviciosFav = catalogo.resultados
        .where((s) => favoritos.esFavorito(s.id))
        .toList();

    if (serviciosFav.isEmpty) {
      return const Center(
        child: Text(
          'Tus favoritos no están disponibles actualmente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.verdeClaro, fontSize: 15),
        ),
      );
    }

    int columnas = 2;
    if (anchoPantalla < 600) columnas = 1;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 300 / 320,
      ),
      itemCount: serviciosFav.length,
      itemBuilder: (context, i) => ServicioCard(
        servicio: serviciosFav[i],
        alReservar: () => Navigator.of(context)
            .pushNamed('/servicio', arguments: serviciosFav[i].id),
      ),
    );
  }
}

// ── Tarjeta de reserva ────────────────────────────────────────────────────────

class _TarjetaReserva extends StatelessWidget {
  final Reserva reserva;
  final bool esMovil;

  const _TarjetaReserva({required this.reserva, required this.esMovil});

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<MisReservasController>();
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final procesando = controlador.estaProcesando(reserva.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: reserva.servicioImagen.isEmpty
                    ? Container(
                        width: 72,
                        height: 72,
                        color: AppColors.verdeOscuro,
                        child: const Icon(Icons.landscape_outlined,
                            color: AppColors.verdeClaro),
                      )
                    : ImagenServicio(
                        url: reserva.servicioImagen,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.verdeOscuro,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppColors.verdeClaro),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reserva.servicioNombre,
                      style: const TextStyle(
                          color: AppColors.blanco,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reserva.servicioUbicacion} · ${formatoFecha.format(reserva.fechaInicio)} → ${formatoFecha.format(reserva.fechaFin)} · ${reserva.huespedes} huésped(es)',
                      style: const TextStyle(
                          color: AppColors.verdeClaro, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${reserva.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: AppColors.amarillo,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _lineaDeEstados(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (procesando)
                const SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator())
              else ...[
                if (reserva.estado == EstadosReserva.pendientePago) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmado = await FeedbackHelper.confirmar(
                        context,
                        titulo: 'Cancelar reserva',
                        mensaje:
                            '¿Seguro que quieres cancelar tu reserva en "${reserva.servicioNombre}"? Las fechas quedarán liberadas.',
                        textoConfirmar: 'Sí, cancelar',
                        textoCancelar: 'Volver',
                      );
                      if (!confirmado || !context.mounted) return;
                      final mensajeError = await context
                          .read<MisReservasController>()
                          .cancelar(reserva);
                      if (!context.mounted) return;
                      if (mensajeError == null) {
                        FeedbackHelper.mostrarExito(
                            context, 'Reserva cancelada y fechas liberadas.');
                      } else {
                        FeedbackHelper.mostrarError(context, mensajeError);
                      }
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/checkout', arguments: reserva),
                    icon: const Icon(Icons.payment_outlined, size: 18),
                    label: const Text('Pagar ahora'),
                  ),
                ],
                if (reserva.estado == EstadosReserva.pagado)
                  const Text(
                    'Pago confirmado. ¡Disfruta tu experiencia!',
                    style: TextStyle(color: AppColors.exito, fontSize: 13),
                  ),
                if (reserva.estado == EstadosReserva.disfrutado)
                  const Text(
                    '¡Gracias por viajar con Pa\'onde! Deja tu reseña en el servicio.',
                    style: TextStyle(color: AppColors.amarillo, fontSize: 13),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineaDeEstados() {
    final indiceActual = EstadosReserva.indiceDe(reserva.estado);
    return Row(
      children: [
        for (var i = 0; i < EstadosReserva.flujo.length; i++) ...[
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= indiceActual
                      ? AppColors.colorDeEstado(EstadosReserva.flujo[i])
                      : AppColors.verdeOscuro,
                  border: Border.all(
                    color: i <= indiceActual
                        ? AppColors.colorDeEstado(EstadosReserva.flujo[i])
                        : AppColors.verdeClaro,
                  ),
                ),
                child: i < indiceActual
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                EstadosReserva.flujo[i],
                style: TextStyle(
                  fontSize: esMovil ? 10 : 12,
                  fontWeight:
                      i == indiceActual ? FontWeight.w700 : FontWeight.w400,
                  color: i <= indiceActual
                      ? AppColors.blanco
                      : AppColors.verdeClaro,
                ),
              ),
            ],
          ),
          if (i < EstadosReserva.flujo.length - 1)
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
                decoration: BoxDecoration(
                  color: i < indiceActual
                      ? AppColors.amarillo
                      : AppColors.verdeOscuro,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// ── Tarjeta de cotización (vista del Explorador) ──────────────────────────────

class _TarjetaCotizacionExplorador extends StatefulWidget {
  final Cotizacion cotizacion;

  const _TarjetaCotizacionExplorador({required this.cotizacion});

  @override
  State<_TarjetaCotizacionExplorador> createState() =>
      _TarjetaCotizacionExploradorState();
}

class _TarjetaCotizacionExploradorState
    extends State<_TarjetaCotizacionExplorador> {
  final _respuestaController = TextEditingController();
  bool _enviando = false;
  bool _reservando = false;
  bool _actualizandoFechas = false;

  Cotizacion get c => widget.cotizacion;

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  Future<void> _enviarRespuesta() async {
    final texto = _respuestaController.text.trim();
    if (texto.isEmpty) {
      FeedbackHelper.mostrarAdvertencia(context, 'Escribe tu respuesta primero.');
      return;
    }
    setState(() => _enviando = true);
    final error = await context
        .read<QuotesController>()
        .contraResponder(cotizacion: c, mensaje: texto);
    if (!mounted) return;
    setState(() => _enviando = false);
    if (error == null) {
      _respuestaController.clear();
      FeedbackHelper.mostrarExito(
          context, 'Respuesta enviada. El aliado la revisará en breve.');
    } else {
      FeedbackHelper.mostrarError(context, error);
    }
  }

  /// Abre el selector de fechas (rango para alojamiento, día único para experiencia).
  Future<DateTimeRange?> _mostrarSelectorFechas() async {
    if (c.esExperiencia) {
      final fecha = await showDatePicker(
        context: context,
        initialDate:
            c.fechaInicio ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 730)),
      );
      if (fecha == null) return null;
      return DateTimeRange(start: fecha, end: fecha);
    } else {
      return showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 730)),
        initialDateRange: c.fechaInicio != null
            ? DateTimeRange(
                start: c.fechaInicio!,
                end: c.fechaFin ??
                    c.fechaInicio!.add(const Duration(days: 1)),
              )
            : null,
      );
    }
  }

  /// Edita solo las fechas sin crear reserva.
  Future<void> _editarFechas() async {
    final rango = await _mostrarSelectorFechas();
    if (rango == null || !mounted) return;
    setState(() => _actualizandoFechas = true);
    final error = await context.read<QuotesController>().actualizarFechas(
          cotizacion: c,
          fechaInicio: rango.start,
          fechaFin: c.esExperiencia ? null : rango.end,
        );
    if (!mounted) return;
    setState(() => _actualizandoFechas = false);
    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
    } else {
      FeedbackHelper.mostrarExito(context, 'Fechas actualizadas.');
    }
  }

  /// Reserva con las fechas ya guardadas en la cotización.
  Future<void> _reservar() => _procesarReserva(null, null);

  /// Primero pide fechas y luego crea la reserva (cuando la cotización no tiene fechas).
  Future<void> _elegirFechasYReservar() async {
    final rango = await _mostrarSelectorFechas();
    if (rango == null || !mounted) return;
    await _procesarReserva(
      rango.start,
      c.esExperiencia ? null : rango.end,
    );
  }

  Future<void> _procesarReserva(
      DateTime? fechaInicioManual, DateTime? fechaFinManual) async {
    final auth = context.read<AuthController>();
    setState(() => _reservando = true);
    final (_, error) = await context.read<QuotesController>().reservarDesdeCotizacion(
          cotizacion: c,
          usuario: auth.usuario,
          fechaInicioManual: fechaInicioManual,
          fechaFinManual: fechaFinManual,
        );
    if (!mounted) return;
    setState(() => _reservando = false);
    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
      return;
    }
    DefaultTabController.of(context).animateTo(0);
    FeedbackHelper.mostrarExito(
        context, 'Reserva creada. Pulsa "Pagar ahora" para confirmar tu pago.');
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final colorEstado = AppColors.colorDeCotizacion(c.estado);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Row(
            children: [
              Expanded(
                child: Text(
                  c.servicioNombre,
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorEstado),
                ),
                child: Text(
                  c.estado,
                  style: TextStyle(
                      color: colorEstado,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Fechas con botón de edición (solo si la reserva aún no fue generada)
          Row(
            children: [
              Expanded(
                child: Text(
                  '${c.huespedes} persona(s)'
                  '${c.fechaInicio == null ? '' : ' · ${formatoFecha.format(c.fechaInicio!)}'}'
                  '${c.fechaFin == null || c.esExperiencia ? '' : ' → ${formatoFecha.format(c.fechaFin!)}'}',
                  style: const TextStyle(
                      color: AppColors.verdeClaro, fontSize: 13),
                ),
              ),
              if (c.reservaId.isEmpty)
                _actualizandoFechas
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(
                        onPressed: _editarFechas,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.amarillo,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          c.fechaInicio == null
                              ? 'Agregar fechas'
                              : 'Cambiar fechas',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
            ],
          ),
          const SizedBox(height: 10),

          // Mensaje inicial
          Text(
            'Tu solicitud: "${c.mensaje}"',
            style: const TextStyle(
                color: AppColors.verdeClaro,
                fontSize: 13,
                fontStyle: FontStyle.italic),
          ),

          // Feedback del aliado
          if (c.respondida) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorEstado.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorEstado),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Respuesta del aliado:',
                    style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.feedback,
                    style: const TextStyle(
                        color: AppColors.blanco,
                        fontSize: 14,
                        height: 1.4),
                  ),
                  if (c.precioPropuesto != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Precio propuesto: \$${c.precioPropuesto!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.amarillo,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),

            // Contra-respuesta anterior ya enviada
            if (c.mensajeExplorador.isNotEmpty && c.turnoAliado) ...[
              const SizedBox(height: 8),
              Text(
                'Tu respuesta enviada: "${c.mensajeExplorador}"',
                style: const TextStyle(
                    color: AppColors.verdeClaro,
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              ),
            ],

            // ── Ya se generó reserva desde esta cotización ──
            if (c.reservaId.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Ya tienes una reserva generada. Revísala en la pestaña Reservas.',
                style: TextStyle(color: AppColors.exito, fontSize: 13),
              ),
            ],

            // ── Botón de reserva: visible en Aceptada o Contrapropuesta con precio ──
            if (c.puedeReservar) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _reservando
                    ? const Center(child: CircularProgressIndicator())
                    : c.fechaInicio == null
                        // Sin fechas: el usuario debe elegirlas antes de reservar
                        ? ElevatedButton.icon(
                            onPressed: _elegirFechasYReservar,
                            icon: const Icon(Icons.date_range_outlined,
                                size: 18),
                            label: const Text('Seleccionar fechas y reservar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amarillo,
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(46),
                            ),
                          )
                        // Con fechas: reservar directamente
                        : ElevatedButton.icon(
                            onPressed: _reservar,
                            icon: const Icon(Icons.bolt_outlined, size: 18),
                            label: Text(
                                'Reservar ahora · \$${c.totalReserva.toStringAsFixed(2)}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amarillo,
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(46),
                            ),
                          ),
              ),
            ],

            // ── Estado final ──
            if (c.estado == EstadosCotizacion.aceptada) ...[
              const SizedBox(height: 10),
              const Text(
                'El aliado aceptó tu solicitud. Reserva con el precio acordado.',
                style: TextStyle(color: AppColors.exito, fontSize: 13),
              ),
            ] else if (c.estado == EstadosCotizacion.rechazada) ...[
              const SizedBox(height: 10),
              const Text(
                'Esta cotización fue rechazada por el aliado.',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),

            // ── Negociación activa (contrapropuesta) ──
            ] else if (!c.esFinal) ...[
              if (!c.turnoAliado) ...[
                const SizedBox(height: 14),
                const Divider(color: AppColors.verdeOscuro),
                const SizedBox(height: 10),
                const Text(
                  'Responder al aliado:',
                  style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _respuestaController,
                  maxLines: 3,
                  enabled: !_enviando,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(
                    hintText: 'Ej.: Acepto el precio si incluyes el desayuno…',
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _enviando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _enviarRespuesta,
                          icon: const Icon(Icons.send_outlined, size: 16),
                          label: const Text('Enviar respuesta'),
                        ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                const Text(
                  'Esperando la nueva respuesta del aliado…',
                  style: TextStyle(
                      color: AppColors.advertencia, fontSize: 13),
                ),
              ],
            ],
          ] else ...[
            const SizedBox(height: 10),
            const Text(
              'Esperando la respuesta del aliado…',
              style: TextStyle(color: AppColors.advertencia, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
