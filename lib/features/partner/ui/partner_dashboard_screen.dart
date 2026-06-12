import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/partner_dashboard_controller.dart';

/// Dashboard del Aliado (RF07): tarjetas con métricas reales calculadas
/// desde Firestore — las ganancias suman únicamente reservas en estado
/// "Pagado" o "Disfrutado" — más el gráfico de ingresos de la semana
/// (fl_chart) y las próximas reservas.
class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final usuario = auth.usuario;

    if (usuario == null || !usuario.esAliado) {
      return _accesoRestringido(context);
    }

    return ChangeNotifierProvider(
      create: (_) => PartnerDashboardController(aliadoId: usuario.uid),
      child: const _ContenidoDashboard(),
    );
  }

  Widget _accesoRestringido(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard del Aliado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                color: AppColors.verdeClaro, size: 48),
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
      ),
    );
  }
}

class _ContenidoDashboard extends StatelessWidget {
  const _ContenidoDashboard();

  @override
  Widget build(BuildContext context) {
    final panel = context.watch<PartnerDashboardController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/aliado') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/aliado', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/aliado', esMovil: false),
                _hero(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: panel.cargando
                          ? const SizedBox(
                              height: 300,
                              child:
                                  Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (panel.error != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: AppColors.error),
                                    ),
                                    child: Text(panel.error!,
                                        style: const TextStyle(
                                            color: AppColors.blanco)),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                _tarjetasMetricas(panel, esMovil),
                                const SizedBox(height: 32),
                                Text('Ingresos de la semana',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                                const SizedBox(height: 16),
                                _graficoSemana(panel),
                                const SizedBox(height: 32),
                                Text('Próximas reservas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                                const SizedBox(height: 16),
                                _proximasReservas(panel),
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
          height: esMovil ? 150 : 240,
          width: double.infinity,
          child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
        ),
        Container(
          height: esMovil ? 150 : 240,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Conectando tus rutas con nuevos exploradores',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: esMovil ? 20 : 32,
              fontWeight: FontWeight.w700,
              shadows: const [Shadow(blurRadius: 10, color: Colors.black87)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjetasMetricas(PartnerDashboardController panel, bool esMovil) {
    final metricas = [
      (
        titulo: 'Ganancias (Pagado/Disfrutado)',
        valor: '\$${panel.gananciasTotales.toStringAsFixed(2)}'
      ),
      (titulo: 'Por cobrar', valor: '\$${panel.porCobrar.toStringAsFixed(2)}'),
      (
        titulo: 'Reservas confirmadas',
        valor: '${panel.reservasConfirmadas}'
      ),
      (titulo: 'Nuevas solicitudes', valor: '${panel.solicitudesNuevas}'),
      (
        titulo: 'Satisfacción del cliente',
        valor: panel.satisfaccionPromedio == 0
            ? '—'
            : panel.satisfaccionPromedio.toStringAsFixed(1)
      ),
      (titulo: 'Servicios publicados', valor: '${panel.servicios.length}'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: esMovil ? 2 : 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: esMovil ? 1.3 : 1.8,
      children: metricas
          .map(
            (metrica) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verde,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.amarillo.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    metrica.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.blanco, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metrica.valor,
                    style: const TextStyle(
                        color: AppColors.amarillo,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Gráfico de barras (fl_chart) con los ingresos cobrados por día de la
  /// semana en curso.
  Widget _graficoSemana(PartnerDashboardController panel) {
    final ingresos = panel.ingresosSemana;
    final maximo = ingresos.fold<double>(0, (max, v) => v > max ? v : max);
    const dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maximo == 0 ? 100 : maximo * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (valor, meta) => Text(
                  '\$${valor.toInt()}',
                  style: const TextStyle(
                      color: AppColors.verdeClaro, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (valor, meta) {
                  final indice = valor.toInt();
                  if (indice < 0 || indice >= dias.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dias[indice],
                      style: const TextStyle(
                          color: AppColors.verdeClaro, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (indice) {
            return BarChartGroupData(
              x: indice,
              barRods: [
                BarChartRodData(
                  toY: ingresos[indice],
                  width: 18,
                  color: AppColors.amarillo,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _proximasReservas(PartnerDashboardController panel) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    if (panel.proximasReservas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.verde,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No tienes reservas próximas todavía.',
            style: TextStyle(color: AppColors.verdeClaro),
          ),
        ),
      );
    }
    return Column(
      children: panel.proximasReservas
          .map(
            (reserva) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.verde,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.colorDeEstado(reserva.estado),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reserva.servicioNombre,
                          style: const TextStyle(
                              color: AppColors.blanco,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${reserva.usuarioNombre} · ${formatoFecha.format(reserva.fechaInicio)} → ${formatoFecha.format(reserva.fechaFin)}',
                          style: const TextStyle(
                              color: AppColors.verdeClaro, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    reserva.estado,
                    style: TextStyle(
                      color: AppColors.colorDeEstado(reserva.estado),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '\$${reserva.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.amarillo,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
