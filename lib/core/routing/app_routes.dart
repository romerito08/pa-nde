import 'package:flutter/material.dart';

import '../../features/admin/ui/admin_dashboard_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/registro_aliado_screen.dart';
import '../../features/auth/ui/registro_screen.dart';
import '../../features/bookings/ui/checkout_screen.dart';
import '../../features/bookings/ui/mis_reservas_screen.dart';
import '../../features/catalog/ui/detalle_servicio_screen.dart';
import '../../features/catalog/ui/explorar_screen.dart';
import '../../features/landing/ui/landing_screen.dart';
import '../../features/partner/ui/mis_servicios_screen.dart';
import '../../features/partner/ui/partner_dashboard_screen.dart';
import '../../features/partner/ui/partner_reservas_screen.dart';
import '../../features/partner/ui/publicar_servicio_screen.dart';
import '../../features/profile/ui/perfil_screen.dart';
import '../../features/quotes/ui/aliado_cotizaciones_screen.dart';
import '../../models/reserva.dart';
import '../../models/servicio.dart';

/// Diccionario centralizado de rutas desacopladas: ninguna pantalla navega
/// instanciando widgets de otra feature, solo usa estos nombres.
class AppRoutes {
  AppRoutes._();

  static const String landing = '/';
  static const String explorar = '/explorar';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String seAliado = '/se-aliado';
  static const String perfil = '/perfil';
  static const String detalleServicio = '/servicio';
  static const String misReservas = '/mis-reservas';
  static const String checkout = '/checkout';
  static const String aliadoDashboard = '/aliado';
  static const String aliadoServicios = '/aliado/servicios';
  static const String aliadoPublicar = '/aliado/publicar';
  static const String aliadoCotizaciones = '/aliado/cotizaciones';
  static const String aliadoReservas = '/aliado/reservas';
  static const String adminDashboard = '/admin';

  /// Generador único de rutas: resuelve también las rutas con argumentos
  /// (detalle de servicio, checkout y edición de servicio).
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return _ruta(const LandingScreen(), settings);
      case explorar:
        return _ruta(const ExplorarScreen(), settings);
      case login:
        return _ruta(const LoginScreen(), settings);
      case registro:
        return _ruta(const RegistroScreen(), settings);
      case seAliado:
        return _ruta(const RegistroAliadoScreen(), settings);
      case perfil:
        return _ruta(const PerfilScreen(), settings);
      case misReservas:
        return _ruta(const MisReservasScreen(), settings);
      case aliadoDashboard:
        return _ruta(const PartnerDashboardScreen(), settings);
      case aliadoServicios:
        return _ruta(const MisServiciosScreen(), settings);
      case aliadoCotizaciones:
        return _ruta(const AliadoCotizacionesScreen(), settings);
      case aliadoReservas:
        return _ruta(const PartnerReservasScreen(), settings);
      case adminDashboard:
        return _ruta(const AdminDashboardScreen(), settings);

      case detalleServicio:
        final servicioId = settings.arguments;
        if (servicioId is String && servicioId.isNotEmpty) {
          return _ruta(DetalleServicioScreen(servicioId: servicioId), settings);
        }
        return _rutaInvalida(settings);

      case checkout:
        final reserva = settings.arguments;
        if (reserva is Reserva) {
          return _ruta(CheckoutScreen(reserva: reserva), settings);
        }
        return _rutaInvalida(settings);

      case aliadoPublicar:
        final servicio = settings.arguments;
        return _ruta(
          PublicarServicioScreen(
              servicio: servicio is Servicio ? servicio : null),
          settings,
        );

      default:
        return _rutaInvalida(settings);
    }
  }

  static MaterialPageRoute<dynamic> _ruta(
      Widget pantalla, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => pantalla, settings: settings);
  }

  /// Pantalla defensiva para rutas desconocidas o argumentos inválidos:
  /// evita pantallas en blanco o crashes de navegación.
  static MaterialPageRoute<dynamic> _rutaInvalida(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Página no encontrada')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text('No encontramos la ruta "${settings.name}".'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(landing, (route) => false),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
