import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/logic/auth_controller.dart';
import '../theme/app_colors.dart';
import '../utils/feedback_helper.dart';
import 'app_header.dart';

/// Menú lateral para la vista móvil. Replica los mismos enlaces por rol que
/// el [AppHeader] de escritorio.
class AppDrawer extends StatelessWidget {
  final String rutaActual;

  const AppDrawer({super.key, required this.rutaActual});

  static const Map<String, IconData> _iconos = {
    'Explorar': Icons.travel_explore_outlined,
    'Mis Reservas': Icons.book_online_outlined,
    'Dashboard': Icons.dashboard_outlined,
    'Mis Servicios': Icons.hotel_outlined,
    'Reservas': Icons.event_available_outlined,
    'Panel Admin': Icons.insights_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final enlaces = AppHeader.enlacesPara(auth.usuario);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.verdeOscuro),
            child: Center(child: Image.asset('assets/Logo.png', width: 120)),
          ),
          ...enlaces.map((enlace) {
            final seleccionado = enlace.ruta == rutaActual;
            return ListTile(
              leading: Icon(
                _iconos[enlace.titulo] ?? Icons.circle_outlined,
                color: seleccionado ? AppColors.amarillo : AppColors.blanco,
              ),
              title: Text(
                enlace.titulo,
                style: TextStyle(
                  color: seleccionado ? AppColors.amarillo : AppColors.blanco,
                  fontWeight:
                      seleccionado ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (!seleccionado) {
                  Navigator.of(context).pushReplacementNamed(enlace.ruta);
                }
              },
            );
          }),
          const Divider(),
          if (auth.autenticado)
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.blanco),
              title: Text(
                'Cerrar sesión (${auth.usuario?.nombre ?? ''})',
                style: const TextStyle(color: AppColors.blanco),
              ),
              onTap: () async {
                Navigator.pop(context);
                final cerrada = await auth.cerrarSesion();
                if (!context.mounted) return;
                if (cerrada) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                } else {
                  FeedbackHelper.mostrarError(
                      context, auth.error ?? 'No fue posible cerrar sesión.');
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.amarillo),
              title: const Text('Acceder',
                  style: TextStyle(
                      color: AppColors.amarillo, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/login');
              },
            ),
        ],
      ),
    );
  }
}
