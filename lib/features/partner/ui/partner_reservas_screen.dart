import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../models/reserva.dart';
import '../../auth/logic/auth_controller.dart';
import '../../bookings/data/booking_repository.dart';

/// Gestión de reservas recibidas por el Aliado (RF08): lista en tiempo real
/// las solicitudes sobre sus servicios y ejecuta las transiciones del flujo
/// de estados — aceptar (Solicitado → Aceptado) y marcar como Disfrutado
/// cuando la estadía pagada concluye.
class PartnerReservasScreen extends StatefulWidget {
  const PartnerReservasScreen({super.key});

  @override
  State<PartnerReservasScreen> createState() => _PartnerReservasScreenState();
}

class _PartnerReservasScreenState extends State<PartnerReservasScreen> {
  final _repositorio = BookingRepository();
  final Set<String> _procesando = {};

  Future<void> _cambiarEstado(Reserva reserva, String nuevoEstado) async {
    setState(() => _procesando.add(reserva.id));
    try {
      await _repositorio.actualizarEstado(
          reservaId: reserva.id, nuevoEstado: nuevoEstado);
      if (!mounted) return;
      FeedbackHelper.mostrarExito(
          context, 'La reserva pasó a estado "$nuevoEstado".');
    } on AppException catch (e) {
      if (!mounted) return;
      FeedbackHelper.mostrarError(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _procesando.remove(reserva.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer:
              esMovil ? const AppDrawer(rutaActual: '/aliado/reservas') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/aliado/reservas', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(
                      rutaActual: '/aliado/reservas', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Reservas recibidas',
                              style:
                                  Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 8),
                          const Text(
                            'Acepta las solicitudes para que el explorador pueda pagar, y marca como "Disfrutado" las estadías concluidas.',
                            style: TextStyle(color: AppColors.verdeClaro),
                          ),
                          const SizedBox(height: 24),
                          if (!(auth.usuario?.esAliado ?? false))
                            _accesoRestringido(context)
                          else
                            _listado(auth.usuario!.uid),
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

  Widget _accesoRestringido(BuildContext context) {
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
            'Esta sección es solo para Aliados.',
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

  Widget _listado(String aliadoId) {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return StreamBuilder<List<Reserva>>(
      stream: _repositorio.reservasDeAliado(aliadoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No pudimos cargar las reservas. Verifica tu conexión.',
                style: TextStyle(color: AppColors.blanco),
              ),
            ),
          );
        }
        final reservas = snapshot.data ?? [];
        if (reservas.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Todavía no has recibido reservas sobre tus servicios.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blanco, fontSize: 16),
              ),
            ),
          );
        }
        return Column(
          children: reservas.map((reserva) {
            final procesando = _procesando.contains(reserva.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
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
                          reserva.servicioNombre,
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
                          color: AppColors.colorDeEstado(reserva.estado)
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.colorDeEstado(reserva.estado)),
                        ),
                        child: Text(
                          reserva.estado,
                          style: TextStyle(
                            color: AppColors.colorDeEstado(reserva.estado),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explorador: ${reserva.usuarioNombre} · ${formatoFecha.format(reserva.fechaInicio)} → ${formatoFecha.format(reserva.fechaFin)} · ${reserva.huespedes} huésped(es)',
                    style: const TextStyle(
                        color: AppColors.verdeClaro, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${reserva.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.amarillo,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      if (procesando)
                        const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator())
                      else if (reserva.estado == EstadosReserva.solicitado)
                        ElevatedButton.icon(
                          onPressed: () => _cambiarEstado(
                              reserva, EstadosReserva.aceptado),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Aceptar solicitud'),
                        )
                      else if (reserva.estado == EstadosReserva.aceptado)
                        const Text(
                          'Esperando el pago del explorador…',
                          style: TextStyle(
                              color: AppColors.estadoAceptado, fontSize: 13),
                        )
                      else if (reserva.estado == EstadosReserva.pagado)
                        OutlinedButton.icon(
                          onPressed: () => _cambiarEstado(
                              reserva, EstadosReserva.disfrutado),
                          icon: const Icon(Icons.emoji_events_outlined,
                              size: 16),
                          label: const Text('Marcar como Disfrutado'),
                        )
                      else
                        const Text(
                          'Estadía completada. ¡Buen trabajo!',
                          style: TextStyle(
                              color: AppColors.amarillo, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
