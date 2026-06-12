import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/admin_dashboard_controller.dart';

/// Panel analítico del Administrador (RF12): tarjetas con totales globales
/// y gráficos fl_chart — tendencia de búsquedas (línea), destinos más
/// buscados (barras) y demanda de reservas por rango de precio (pastel).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!(auth.usuario?.esAdministrador ?? false)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel del Administrador')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.verdeClaro, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Acceso restringido: esta sección es solo para Administradores.',
                textAlign: TextAlign.center,
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

    return ChangeNotifierProvider(
      create: (_) => AdminDashboardController(),
      child: const _ContenidoAdmin(),
    );
  }
}

class _ContenidoAdmin extends StatelessWidget {
  const _ContenidoAdmin();

  @override
  Widget build(BuildContext context) {
    final panel = context.watch<AdminDashboardController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/admin') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/admin', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/admin', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: panel.cargando
                          ? const SizedBox(
                              height: 320,
                              child:
                                  Center(child: CircularProgressIndicator()),
                            )
                          : panel.error != null
                              ? _vistaError(context, panel)
                              : _contenido(context, panel, esMovil),
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

  Widget _vistaError(BuildContext context, AdminDashboardController panel) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AppColors.verdeClaro, size: 48),
            const SizedBox(height: 12),
            Text(panel.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.blanco)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<AdminDashboardController>().cargar(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(
      BuildContext context, AdminDashboardController panel, bool esMovil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text('Panel del Administrador',
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            IconButton(
              tooltip: 'Actualizar datos',
              icon: const Icon(Icons.refresh, color: AppColors.amarillo),
              onPressed: () =>
                  context.read<AdminDashboardController>().cargar(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _tarjetasTotales(panel, esMovil),
        const SizedBox(height: 32),
        Text('Tendencia de búsquedas (últimos 7 días)',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _graficoTendencia(panel),
        const SizedBox(height: 32),
        esMovil
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _seccionDestinos(context, panel),
                  const SizedBox(height: 32),
                  _seccionRangos(context, panel),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _seccionDestinos(context, panel)),
                  const SizedBox(width: 24),
                  Expanded(child: _seccionRangos(context, panel)),
                ],
              ),
        const SizedBox(height: 40),
        AppFooter(esMovil: esMovil),
      ],
    );
  }

  Widget _tarjetasTotales(AdminDashboardController panel, bool esMovil) {
    final totales = [
      (titulo: 'Usuarios registrados', valor: '${panel.totalUsuarios}'),
      (titulo: 'Servicios publicados', valor: '${panel.totalServicios}'),
      (titulo: 'Búsquedas (30 días)', valor: '${panel.totalBusquedas}'),
      (titulo: 'Reservas totales', valor: '${panel.totalReservas}'),
      (
        titulo: 'Volumen transado',
        valor: '\$${panel.volumenTransado.toStringAsFixed(2)}'
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: esMovil ? 2 : 5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: esMovil ? 1.4 : 1.1,
      children: totales
          .map(
            (total) => Container(
              padding: const EdgeInsets.all(14),
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
                    total.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.blanco, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    child: Text(
                      total.valor,
                      style: const TextStyle(
                          color: AppColors.amarillo,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// LineChart (fl_chart) con la tendencia diaria de búsquedas.
  Widget _graficoTendencia(AdminDashboardController panel) {
    final datos = panel.busquedasPorDia;
    final etiquetas = panel.etiquetasDias;
    final maximo =
        datos.fold<int>(0, (max, v) => v > max ? v : max).toDouble();

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maximo == 0 ? 5 : maximo * 1.3,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (valor) => FlLine(
              color: AppColors.verdeClaro.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (valor, meta) => Text(
                  valor.toInt().toString(),
                  style: const TextStyle(
                      color: AppColors.verdeClaro, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (valor, meta) {
                  final indice = valor.toInt();
                  if (indice < 0 || indice >= etiquetas.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      etiquetas[indice],
                      style: const TextStyle(
                          color: AppColors.verdeClaro, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                datos.length,
                (i) => FlSpot(i.toDouble(), datos[i].toDouble()),
              ),
              isCurved: true,
              color: AppColors.amarillo,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.amarillo.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionDestinos(
      BuildContext context, AdminDashboardController panel) {
    final destinos = panel.destinosMasBuscados;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Destinos más buscados',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 260,
          padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
          decoration: BoxDecoration(
            color: AppColors.verde,
            borderRadius: BorderRadius.circular(16),
          ),
          child: destinos.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay búsquedas con ciudad registradas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.verdeClaro),
                  ),
                )
              : BarChart(
                  BarChartData(
                    maxY: destinos.first.value.toDouble() * 1.3,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (valor, meta) => Text(
                            valor.toInt().toString(),
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
                            if (indice < 0 || indice >= destinos.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                destinos[indice].key,
                                style: const TextStyle(
                                    color: AppColors.blanco, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(destinos.length, (indice) {
                      return BarChartGroupData(
                        x: indice,
                        barRods: [
                          BarChartRodData(
                            toY: destinos[indice].value.toDouble(),
                            width: 22,
                            color: AppColors.amarillo,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _seccionRangos(BuildContext context, AdminDashboardController panel) {
    final rangos = panel.reservasPorRangoPrecio;
    final totalReservas =
        rangos.values.fold<int>(0, (acumulado, v) => acumulado + v);
    const coloresRangos = [
      AppColors.amarillo,
      AppColors.estadoAceptado,
      AppColors.exito,
      AppColors.advertencia,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demanda por rango de precio',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.verde,
            borderRadius: BorderRadius.circular(16),
          ),
          child: totalReservas == 0
              ? const Center(
                  child: Text(
                    'Aún no hay reservas registradas para graficar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.verdeClaro),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          sections: List.generate(
                            RangoPrecio.rangos.length,
                            (indice) {
                              final rango = RangoPrecio.rangos[indice];
                              final cantidad = rangos[rango] ?? 0;
                              return PieChartSectionData(
                                value: cantidad.toDouble(),
                                color: coloresRangos[
                                    indice % coloresRangos.length],
                                radius: 56,
                                title: cantidad == 0
                                    ? ''
                                    : '${(cantidad * 100 / totalReservas).round()}%',
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          RangoPrecio.rangos.length,
                          (indice) {
                            final rango = RangoPrecio.rangos[indice];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: coloresRangos[
                                          indice % coloresRangos.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${rango.etiqueta}: ${rangos[rango] ?? 0}',
                                      style: const TextStyle(
                                          color: AppColors.blanco,
                                          fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
