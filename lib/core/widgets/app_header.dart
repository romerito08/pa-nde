import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/logic/auth_controller.dart';
import '../../models/usuario.dart';
import '../theme/app_colors.dart';
import '../utils/feedback_helper.dart';

/// Encabezado responsivo global. En escritorio muestra la barra de
/// navegación del prototipo (logo + enlaces + perfil); en móvil se reduce a
/// un AppBar con menú hamburguesa que abre el [Drawer] del Scaffold.
/// Los enlaces visibles dependen del rol autenticado (RF15).
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String rutaActual;
  final bool esMovil;

  const AppHeader({super.key, required this.rutaActual, required this.esMovil});

  @override
  Size get preferredSize => Size.fromHeight(esMovil ? kToolbarHeight : 72);

  /// Enlaces de navegación según el rol del usuario.
  static List<({String titulo, String ruta})> enlacesPara(Usuario? usuario) {
    if (usuario?.esAliado ?? false) {
      return [
        (titulo: 'Dashboard', ruta: '/aliado'),
        (titulo: 'Mis Servicios', ruta: '/aliado/servicios'),
        (titulo: 'Cotizaciones', ruta: '/aliado/cotizaciones'),
        (titulo: 'Reservas', ruta: '/aliado/reservas'),
      ];
    }
    if (usuario?.esAdministrador ?? false) {
      return [
        (titulo: 'Métricas', ruta: '/admin/metricas'),
        (titulo: 'Usuarios', ruta: '/admin/usuarios'),
        (titulo: 'Publicaciones', ruta: '/admin/publicaciones'),
      ];
    }
    if (usuario != null) {
      // Explorador autenticado
      return [
        (titulo: 'Inicio', ruta: '/inicio'),
        (titulo: 'Alojamientos', ruta: '/alojamientos'),
        (titulo: 'Experiencias', ruta: '/experiencias'),
        (titulo: 'Destinos', ruta: '/destinos'),
        (titulo: 'Reservas', ruta: '/mis-reservas'),
      ];
    }
    // Sin autenticar
    return [
      (titulo: 'Inicio', ruta: '/'),
      (titulo: 'Explorar', ruta: '/explorar'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (esMovil) {
      return AppBar(
        title: Image.asset('assets/Logo.png', width: 100),
        centerTitle: true,
      );
    }

    final auth = context.watch<AuthController>();
    final enlaces = enlacesPara(auth.usuario);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      color: AppColors.verdeOscuro,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false),
            child: Image.asset('assets/Logo.png', width: 120),
          ),
          Row(
            children: enlaces
                .map((enlace) => _enlace(context, enlace.titulo, enlace.ruta))
                .toList(),
          ),
          _accionesSesion(context, auth),
        ],
      ),
    );
  }

  Widget _enlace(BuildContext context, String titulo, String ruta) {
    final seleccionado = ruta == rutaActual;
    return InkWell(
      onTap: () {
        if (!seleccionado) Navigator.of(context).pushReplacementNamed(ruta);
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          titulo,
          style: TextStyle(
            color: seleccionado ? AppColors.amarillo : AppColors.blanco,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _accionesSesion(BuildContext context, AuthController auth) {
    if (!auth.autenticado) {
      return ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed('/login'),
        child: const Text('Acceder'),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Mi perfil',
      color: AppColors.verde,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (accion) async {
        if (accion == 'perfil') {
          Navigator.of(context).pushNamed('/perfil');
          return;
        }
        if (accion == 'salir') {
          final cerrada = await auth.cerrarSesion();
          if (!context.mounted) return;
          if (cerrada) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          } else {
            FeedbackHelper.mostrarError(
                context, auth.error ?? 'No fue posible cerrar sesión.');
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            '${auth.usuario?.nombreCompleto ?? ''}\n${auth.usuario?.rol ?? ''}',
            style: const TextStyle(color: AppColors.verdeClaro, fontSize: 13),
          ),
        ),
        const PopupMenuItem(
          value: 'perfil',
          child: Row(
            children: [
              Icon(Icons.manage_accounts_outlined,
                  color: AppColors.blanco, size: 18),
              SizedBox(width: 8),
              Text('Editar perfil', style: TextStyle(color: AppColors.blanco)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'salir',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColors.blanco, size: 18),
              SizedBox(width: 8),
              Text('Cerrar sesión', style: TextStyle(color: AppColors.blanco)),
            ],
          ),
        ),
      ],
      child: Row(
        children: [
          Text(
            auth.usuario?.nombre ?? 'Mi perfil',
            style: const TextStyle(
                color: AppColors.amarillo, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.account_circle_outlined, color: AppColors.amarillo),
        ],
      ),
    );
  }
}
