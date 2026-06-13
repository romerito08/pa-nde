import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../models/cotizacion.dart';
import '../../../models/reserva.dart';
import '../../auth/logic/auth_controller.dart';
import '../../quotes/logic/quotes_controller.dart';
import '../logic/mis_reservas_controller.dart';

/// "Mis Reservas" del Explorador, con dos pestañas:
/// - Reservas: línea de progreso Pendiente de Pago → Pagado → Disfrutado,
///   con pago inmediato y cancelación (libera fechas) mientras no se pague.
/// - Cotizaciones: solicitudes enviadas y el feedback del Aliado
///   (aceptada, rechazada o contrapropuesta con precio sugerido).
class MisReservasScreen extends StatelessWidget {
  const MisReservasScreen({super.key});

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
                            _pestanas(context, auth.usuario!.uid, esMovil),
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

  Widget _pestanas(BuildContext context, String usuarioId, bool esMovil) {
    return DefaultTabController(
      length: 2,
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Altura propia por pestaña dentro del scroll de la página.
          SizedBox(
            height: 600,
            child: TabBarView(
              children: [
                _listadoReservas(context, usuarioId, esMovil),
                _listadoCotizaciones(context, usuarioId),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                      Navigator.of(context).pushReplacementNamed('/explorar'),
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

  Widget _listadoCotizaciones(BuildContext context, String usuarioId) {
    final quotes = context.watch<QuotesController>();
    final formatoFecha = DateFormat('dd/MM/yyyy');

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
          itemBuilder: (context, indice) {
            final cotizacion = cotizaciones[indice];
            final colorEstado = AppColors.colorDeCotizacion(cotizacion.estado);
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
                      Expanded(
                        child: Text(
                          cotizacion.servicioNombre,
                          style: const TextStyle(
                              color: AppColors.blanco,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorEstado.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorEstado),
                        ),
                        child: Text(
                          cotizacion.estado,
                          style: TextStyle(
                              color: colorEstado,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${cotizacion.huespedes} persona(s)'
                    '${cotizacion.fechaInicio == null ? '' : ' · ${formatoFecha.format(cotizacion.fechaInicio!)}'}'
                    '${cotizacion.fechaFin == null ? '' : ' → ${formatoFecha.format(cotizacion.fechaFin!)}'}',
                    style: const TextStyle(
                        color: AppColors.verdeClaro, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tu mensaje: "${cotizacion.mensaje}"',
                    style: const TextStyle(
                        color: AppColors.verdeClaro,
                        fontSize: 13,
                        fontStyle: FontStyle.italic),
                  ),
                  if (cotizacion.respondida) ...[
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
                            'Feedback del aliado:',
                            style: TextStyle(
                                color: AppColors.blanco,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cotizacion.feedback,
                            style: const TextStyle(
                                color: AppColors.blanco,
                                fontSize: 14,
                                height: 1.4),
                          ),
                          if (cotizacion.precioPropuesto != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Precio propuesto: \$${cotizacion.precioPropuesto!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.amarillo,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (cotizacion.estado != EstadosCotizacion.rechazada) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(
                              '/servicio',
                              arguments: cotizacion.servicioId),
                          icon: const Icon(Icons.bolt_outlined, size: 16),
                          label: const Text('Ir a reservar'),
                        ),
                      ),
                    ],
                  ] else ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Esperando la respuesta del aliado…',
                      style: TextStyle(
                          color: AppColors.advertencia, fontSize: 13),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

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
                    : Image.network(
                        reserva.servicioImagen,
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

  /// Línea de progreso del flujo Pendiente de Pago → Pagado → Disfrutado.
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
