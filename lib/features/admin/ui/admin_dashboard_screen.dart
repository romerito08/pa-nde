import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/imagen_servicio.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/admin_dashboard_controller.dart';
import '../logic/admin_gestion_controller.dart';

/// Panel del Administrador. Cada sección tiene su propia ruta y se navega
/// desde el [AppHeader], igual que el flujo del Aliado.
///   tabInicial 0 → Métricas   (/admin/metricas)
///   tabInicial 1 → Usuarios   (/admin/usuarios)
///   tabInicial 2 → Publicaciones (/admin/publicaciones)
class AdminDashboardScreen extends StatelessWidget {
  final int tabInicial;

  const AdminDashboardScreen({super.key, this.tabInicial = 0});

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminDashboardController()),
        ChangeNotifierProvider(create: (_) => AdminGestionController()),
      ],
      child: _ContenidoAdmin(tabInicial: tabInicial),
    );
  }
}

// ─────────────────────────── SHELL ──────────────────────────────────────────

class _ContenidoAdmin extends StatelessWidget {
  final int tabInicial;

  const _ContenidoAdmin({required this.tabInicial});

  String get _rutaActual {
    switch (tabInicial) {
      case 1:
        return '/admin/usuarios';
      case 2:
        return '/admin/publicaciones';
      default:
        return '/admin/metricas';
    }
  }

  String get _tituloSeccion {
    switch (tabInicial) {
      case 1:
        return 'Usuarios';
      case 2:
        return 'Publicaciones';
      default:
        return 'Métricas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? AppDrawer(rutaActual: _rutaActual) : null,
          appBar: esMovil
              ? AppBar(
                  title: Text(_tituloSeccion),
                  centerTitle: true,
                )
              : null,
          body: Column(
            children: [
              if (!esMovil)
                AppHeader(rutaActual: _rutaActual, esMovil: false),
              Expanded(child: _seccion()),
            ],
          ),
        );
      },
    );
  }

  Widget _seccion() {
    switch (tabInicial) {
      case 1:
        return const _TabUsuarios();
      case 2:
        return const _TabPublicaciones();
      default:
        return const _TabMetricas();
    }
  }
}

// ═══════════════════════════ TAB 0 — MÉTRICAS ════════════════════════════════

class _TabMetricas extends StatelessWidget {
  const _TabMetricas();

  @override
  Widget build(BuildContext context) {
    final panel = context.watch<AdminDashboardController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: esMovil ? 16 : 40, vertical: 32),
                child: panel.cargando
                    ? const SizedBox(
                        height: 320,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : panel.error != null
                        ? _error(context, panel)
                        : _contenido(context, panel, esMovil),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _error(BuildContext context, AdminDashboardController panel) {
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
              child: Text('Métricas del Sistema',
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
                    style:
                        const TextStyle(color: AppColors.blanco, fontSize: 12),
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
                  style:
                      const TextStyle(color: AppColors.verdeClaro, fontSize: 10),
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
      AppColors.informacion,
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

// ═══════════════════════════ TAB 1 — USUARIOS ════════════════════════════════

class _TabUsuarios extends StatelessWidget {
  const _TabUsuarios();

  @override
  Widget build(BuildContext context) {
    final gestion = context.watch<AdminGestionController>();

    if (gestion.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (gestion.error != null) {
      return Center(
        child: Text(gestion.error!,
            style: const TextStyle(color: AppColors.blanco)),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Gestión de Usuarios',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  '${gestion.usuarios.length} usuarios registrados en el sistema.',
                  style: const TextStyle(
                      color: AppColors.verdeClaro, fontSize: 13),
                ),
                const SizedBox(height: 28),
                _SeccionUsuarios(
                  titulo: 'Exploradores',
                  icono: Icons.explore_outlined,
                  usuarios: gestion.exploradores,
                ),
                const SizedBox(height: 28),
                _SeccionUsuarios(
                  titulo: 'Aliados',
                  icono: Icons.storefront_outlined,
                  usuarios: gestion.aliados,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeccionUsuarios extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Usuario> usuarios;

  const _SeccionUsuarios({
    required this.titulo,
    required this.icono,
    required this.usuarios,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: AppColors.amarillo, size: 20),
            const SizedBox(width: 8),
            Text(
              '$titulo (${usuarios.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (usuarios.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No hay $titulo registrados todavía.',
              style: const TextStyle(color: AppColors.verdeClaro),
            ),
          )
        else
          ...usuarios.map((u) => _FilaUsuario(usuario: u)),
      ],
    );
  }
}

/// Fila de usuario con su propio estado de carga para el botón
/// bloquear/desbloquear, evitando pulsaciones múltiples.
class _FilaUsuario extends StatefulWidget {
  final Usuario usuario;
  const _FilaUsuario({required this.usuario});

  @override
  State<_FilaUsuario> createState() => _FilaUsuarioState();
}

class _FilaUsuarioState extends State<_FilaUsuario> {
  bool _cargando = false;

  Future<void> _toggleBloqueo() async {
    final gestion = context.read<AdminGestionController>();
    final bloqueado = widget.usuario.bloqueado;
    final nombre = widget.usuario.nombre;

    // Confirmación solo al bloquear (acción irreversible para el usuario)
    if (!bloqueado) {
      final confirmado = await FeedbackHelper.confirmar(
        context,
        titulo: 'Bloquear usuario',
        mensaje:
            '¿Confirmas que deseas bloquear a $nombre? '
            'No podrá iniciar sesión hasta que lo desbloquees.',
        textoConfirmar: 'Sí, bloquear',
      );
      if (!confirmado || !mounted) return;
    }

    setState(() => _cargando = true);
    final error = bloqueado
        ? await gestion.desbloquear(widget.usuario.uid)
        : await gestion.bloquear(widget.usuario.uid);
    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
    } else {
      FeedbackHelper.mostrarExito(
        context,
        bloqueado
            ? '$nombre fue desbloqueado y puede iniciar sesión.'
            : '$nombre fue bloqueado y no podrá acceder a la app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloqueado = widget.usuario.bloqueado;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bloqueado
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.verde,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: bloqueado
              ? AppColors.error.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bloqueado
                  ? AppColors.error.withValues(alpha: 0.2)
                  : AppColors.verdeOscuro,
              shape: BoxShape.circle,
            ),
            child: Icon(
              bloqueado ? Icons.block : Icons.person_outline,
              color: bloqueado ? AppColors.error : AppColors.verdeClaro,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.usuario.nombreCompleto.isEmpty
                      ? '(sin nombre)'
                      : widget.usuario.nombreCompleto,
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(widget.usuario.correo,
                    style: const TextStyle(
                        color: AppColors.verdeClaro, fontSize: 12)),
                if (widget.usuario.telefono.isNotEmpty)
                  Text(widget.usuario.telefono,
                      style: const TextStyle(
                          color: AppColors.verdeClaro, fontSize: 12)),
                if (widget.usuario.estado.isNotEmpty)
                  Text(
                    '${widget.usuario.municipio.isNotEmpty ? '${widget.usuario.municipio}, ' : ''}${widget.usuario.estado}',
                    style: const TextStyle(
                        color: AppColors.verdeClaro, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Badge estado + botón
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bloqueado
                      ? AppColors.error.withValues(alpha: 0.2)
                      : AppColors.exito.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bloqueado ? 'Bloqueado' : 'Activo',
                  style: TextStyle(
                    color: bloqueado ? AppColors.error : AppColors.exito,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                width: 110,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _toggleBloqueo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        bloqueado ? AppColors.exito : AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        (bloqueado ? AppColors.exito : AppColors.error)
                            .withValues(alpha: 0.5),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(bloqueado ? 'Desbloquear' : 'Bloquear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════ TAB 2 — PUBLICACIONES ══════════════════════════════

class _TabPublicaciones extends StatefulWidget {
  const _TabPublicaciones();

  @override
  State<_TabPublicaciones> createState() => _TabPublicacionesState();
}

class _TabPublicacionesState extends State<_TabPublicaciones>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestion = context.watch<AdminGestionController>();

    if (gestion.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // ─── Barra de sub-tabs ────────────────────────────────────
        Container(
          color: AppColors.verdeOscuro,
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppColors.amarillo,
            labelColor: AppColors.amarillo,
            unselectedLabelColor: AppColors.verdeClaro,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700),
            tabs: [
              _subTab('Pendientes', gestion.pendientes.length,
                  AppColors.advertencia),
              _subTab('Aprobados', gestion.activos.length, AppColors.exito),
              _subTab('Rechazados', gestion.pausados.length, AppColors.error),
            ],
          ),
        ),
        // ─── Contenido ───────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: const [
              _ListaPendientes(),
              _ListaAprobados(),
              _ListaRechazados(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subTab(String titulo, int cantidad, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titulo),
          if (cantidad > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$cantidad',
                style: TextStyle(
                  color: badgeColor == AppColors.advertencia
                      ? Colors.black
                      : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Lista de pendientes ──────────────────────────────────────────────────────

class _ListaPendientes extends StatelessWidget {
  const _ListaPendientes();

  @override
  Widget build(BuildContext context) {
    final pendientes = context.watch<AdminGestionController>().pendientes;
    return _ListaServicios(
      servicios: pendientes,
      vacia: const _MensajeVacio(
        icono: Icons.check_circle_outline,
        color: AppColors.exito,
        texto: 'No hay publicaciones pendientes de revisión.',
      ),
      buildTarjeta: (s) => _TarjetaPendiente(servicio: s),
    );
  }
}

// ─── Lista de aprobados ───────────────────────────────────────────────────────

class _ListaAprobados extends StatelessWidget {
  const _ListaAprobados();

  @override
  Widget build(BuildContext context) {
    final activos = context.watch<AdminGestionController>().activos;
    return _ListaServicios(
      servicios: activos,
      vacia: const _MensajeVacio(
        icono: Icons.storefront_outlined,
        color: AppColors.verdeClaro,
        texto: 'Aún no hay publicaciones aprobadas.',
      ),
      buildTarjeta: (s) => _TarjetaAprobada(servicio: s),
    );
  }
}

// ─── Lista de rechazados ──────────────────────────────────────────────────────

class _ListaRechazados extends StatelessWidget {
  const _ListaRechazados();

  @override
  Widget build(BuildContext context) {
    final pausados = context.watch<AdminGestionController>().pausados;
    return _ListaServicios(
      servicios: pausados,
      vacia: const _MensajeVacio(
        icono: Icons.thumb_up_outlined,
        color: AppColors.verdeClaro,
        texto: 'No hay publicaciones rechazadas o pausadas.',
      ),
      buildTarjeta: (s) => _TarjetaRechazada(servicio: s),
    );
  }
}

// ─── Contenedor genérico de lista ─────────────────────────────────────────────

class _ListaServicios extends StatelessWidget {
  final List<Servicio> servicios;
  final Widget vacia;
  final Widget Function(Servicio) buildTarjeta;

  const _ListaServicios({
    required this.servicios,
    required this.vacia,
    required this.buildTarjeta,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: servicios.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: vacia,
                  )
                : Column(
                    children: servicios.map(buildTarjeta).toList(),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MensajeVacio extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;

  const _MensajeVacio({
    required this.icono,
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 48),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.blanco, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de publicación pendiente con estado de carga independiente
/// para los botones Aprobar y Rechazar.
class _TarjetaPendiente extends StatefulWidget {
  final Servicio servicio;
  const _TarjetaPendiente({required this.servicio});

  @override
  State<_TarjetaPendiente> createState() => _TarjetaPendienteState();
}

class _TarjetaPendienteState extends State<_TarjetaPendiente> {
  bool _aprobando = false;
  bool _rechazando = false;

  bool get _ocupado => _aprobando || _rechazando;

  Future<void> _aprobar() async {
    setState(() => _aprobando = true);
    final error =
        await context.read<AdminGestionController>().aprobar(widget.servicio.id);
    if (!mounted) return;
    setState(() => _aprobando = false);
    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
    } else {
      FeedbackHelper.mostrarExito(
          context,
          '"${widget.servicio.nombre}" fue aprobado '
          'y ya es visible en el catálogo.');
    }
  }

  Future<void> _rechazar() async {
    final confirmado = await FeedbackHelper.confirmar(
      context,
      titulo: 'Rechazar publicación',
      mensaje:
          '¿Confirmas que deseas rechazar "${widget.servicio.nombre}"? '
          'El servicio quedará pausado y no será visible.',
      textoConfirmar: 'Sí, rechazar',
    );
    if (!confirmado || !mounted) return;

    setState(() => _rechazando = true);
    final error = await context
        .read<AdminGestionController>()
        .rechazar(widget.servicio.id);
    if (!mounted) return;
    setState(() => _rechazando = false);
    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
    } else {
      FeedbackHelper.mostrarExito(
          context,
          '"${widget.servicio.nombre}" fue rechazado y no es visible en el catálogo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TarjetaServicioBase(
      servicio: widget.servicio,
      badgeColor: AppColors.advertencia,
      badgeTexto: 'Pendiente',
      accion: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.verdeOscuro.withValues(alpha: 0.4),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _ocupado ? null : _aprobar,
                icon: _aprobando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(_aprobando ? 'Aprobando…' : 'Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.exito,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.exito.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _ocupado ? null : _rechazar,
                icon: _rechazando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.error),
                      )
                    : const Icon(Icons.cancel_outlined, size: 18),
                label: Text(_rechazando ? 'Rechazando…' : 'Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                      color: _ocupado
                          ? AppColors.error.withValues(alpha: 0.4)
                          : AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta: servicio aprobado (con botón Suspender) ────────────────────────

class _TarjetaAprobada extends StatefulWidget {
  final Servicio servicio;
  const _TarjetaAprobada({required this.servicio});

  @override
  State<_TarjetaAprobada> createState() => _TarjetaAprobadaState();
}

class _TarjetaAprobadaState extends State<_TarjetaAprobada> {
  bool _suspendiendo = false;

  Future<void> _suspender() async {
    final confirmado = await FeedbackHelper.confirmar(
      context,
      titulo: 'Suspender publicación',
      mensaje:
          '¿Confirmas que deseas suspender "${widget.servicio.nombre}"? '
          'Dejará de ser visible en el catálogo hasta que la apruebes de nuevo.',
      textoConfirmar: 'Sí, suspender',
    );
    if (!confirmado || !mounted) return;

    setState(() => _suspendiendo = true);
    final error = await context
        .read<AdminGestionController>()
        .suspender(widget.servicio.id);
    if (!mounted) return;
    setState(() => _suspendiendo = false);
    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
    } else {
      FeedbackHelper.mostrarExito(
          context,
          '"${widget.servicio.nombre}" fue suspendido y ya no es visible en el catálogo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TarjetaServicioBase(
      servicio: widget.servicio,
      badgeColor: AppColors.exito,
      badgeTexto: 'Activo',
      accion: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.verdeOscuro.withValues(alpha: 0.4),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _suspendiendo ? null : _suspender,
            icon: _suspendiendo
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.advertencia),
                  )
                : const Icon(Icons.pause_circle_outline, size: 18),
            label: Text(_suspendiendo ? 'Suspendiendo…' : 'Suspender publicación'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.advertencia,
              side: BorderSide(
                  color: _suspendiendo
                      ? AppColors.advertencia.withValues(alpha: 0.4)
                      : AppColors.advertencia),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta: servicio rechazado/pausado (con botón Re-aprobar) ───────────────

class _TarjetaRechazada extends StatefulWidget {
  final Servicio servicio;
  const _TarjetaRechazada({required this.servicio});

  @override
  State<_TarjetaRechazada> createState() => _TarjetaRechazadaState();
}

class _TarjetaRechazadaState extends State<_TarjetaRechazada> {
  bool _aprobando = false;

  Future<void> _reaprobar() async {
    setState(() => _aprobando = true);
    final error = await context
        .read<AdminGestionController>()
        .aprobar(widget.servicio.id);
    if (!mounted) return;
    setState(() => _aprobando = false);
    if (error != null) {
      FeedbackHelper.mostrarError(context, error);
    } else {
      FeedbackHelper.mostrarExito(context,
          '"${widget.servicio.nombre}" fue aprobado y ya es visible en el catálogo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TarjetaServicioBase(
      servicio: widget.servicio,
      badgeColor: AppColors.error,
      badgeTexto: 'Pausado',
      accion: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.verdeOscuro.withValues(alpha: 0.4),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _aprobando ? null : _reaprobar,
            icon: _aprobando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle_outline, size: 18),
            label: Text(_aprobando ? 'Aprobando…' : 'Aprobar de nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.exito,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.exito.withValues(alpha: 0.5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widget base compartido por las 3 variantes de tarjeta ───────────────────

class _TarjetaServicioBase extends StatelessWidget {
  final Servicio servicio;
  final Color badgeColor;
  final String badgeTexto;
  final Widget accion;

  const _TarjetaServicioBase({
    required this.servicio,
    required this.badgeColor,
    required this.badgeTexto,
    required this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final s = servicio;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(14)),
                  child: SizedBox(
                    width: 130,
                    child: s.imagenPrincipal.isEmpty
                        ? Container(
                            color: AppColors.verdeOscuro,
                            child: const Center(
                              child: Icon(Icons.image_outlined,
                                  color: AppColors.verdeClaro, size: 36),
                            ),
                          )
                        : ImagenServicio(
                            url: s.imagenPrincipal,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.verdeOscuro,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.verdeClaro, size: 28),
                              ),
                            ),
                          ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          children: [
                            _chip(s.tipo.toUpperCase(), badgeColor),
                            if (s.tipoAlojamiento.isNotEmpty)
                              _chip(s.tipoAlojamiento, AppColors.verdeClaro),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeTexto,
                                style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(s.nombre,
                            style: const TextStyle(
                                color: AppColors.blanco,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.verdeClaro),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              s.ubicacion.isEmpty
                                  ? 'Ubicación no especificada'
                                  : s.ubicacion,
                              style: const TextStyle(
                                  color: AppColors.verdeClaro, fontSize: 12),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text(
                            '\$${s.precio.toStringAsFixed(0)} / ${s.unidadPrecio}',
                            style: const TextStyle(
                                color: AppColors.amarillo,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.people_outline,
                              size: 13, color: AppColors.verdeClaro),
                          const SizedBox(width: 3),
                          Text('Cap. ${s.capacidad}',
                              style: const TextStyle(
                                  color: AppColors.verdeClaro, fontSize: 12)),
                        ]),
                        const SizedBox(height: 6),
                        Text(
                          s.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.verdeClaro,
                              fontSize: 12,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          accion,
        ],
      ),
    );
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(texto,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
