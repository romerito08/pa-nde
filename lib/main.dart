import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/logic/auth_controller.dart';
import 'features/bookings/logic/mis_reservas_controller.dart';
import 'features/catalog/logic/catalog_controller.dart';
import 'features/catalog/logic/favoritos_controller.dart';
import 'features/quotes/logic/quotes_controller.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Un único runApp: el bootstrap muestra el splash, inicializa Firebase
  // con timeout y conmuta al sistema o a la pantalla de contingencia sin
  // reemplazar el árbol raíz (reemplazarlo a mitad del primer frame dejaba
  // el render de Flutter Web congelado en una pantalla oscura).
  runApp(const PaondeBootstrap());
}

enum _EstadoArranque { cargando, listo, fallido }

/// Raíz de la aplicación: gestiona el ciclo splash → app / contingencia.
class PaondeBootstrap extends StatefulWidget {
  const PaondeBootstrap({super.key});

  @override
  State<PaondeBootstrap> createState() => _PaondeBootstrapState();
}

class _PaondeBootstrapState extends State<PaondeBootstrap> {
  _EstadoArranque _estado = _EstadoArranque.cargando;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    setState(() => _estado = _EstadoArranque.cargando);
    try {
      // Inicialización asíncrona de Firebase con timeout defensivo (RNF03):
      // sin red, la app cae a la pantalla de contingencia con reintento.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 20));
      }
      if (mounted) setState(() => _estado = _EstadoArranque.listo);
    } catch (_) {
      if (mounted) setState(() => _estado = _EstadoArranque.fallido);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_estado) {
      case _EstadoArranque.cargando:
        return _envoltorio(const _PantallaSplash());
      case _EstadoArranque.fallido:
        return _envoltorio(_PantallaArranqueFallido(alReintentar: _inicializar));
      case _EstadoArranque.listo:
        return const PaondeApp();
    }
  }

  Widget _envoltorio(Widget hijo) {
    return MaterialApp(
      title: "Pa'onde",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: _guardiaViewport,
      home: hijo,
    );
  }
}

class _PantallaSplash extends StatelessWidget {
  const _PantallaSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Logo.png', width: 180),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantallaArranqueFallido extends StatelessWidget {
  final Future<void> Function() alReintentar;

  const _PantallaArranqueFallido({required this.alReintentar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Logo.png', width: 160),
              const SizedBox(height: 24),
              const Icon(Icons.wifi_off_outlined,
                  color: AppColors.verdeClaro, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No pudimos conectar con los servicios de Pa\'onde.\n'
                'Revisa tu conexión a internet y vuelve a intentarlo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blanco, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaondeApp extends StatelessWidget {
  const PaondeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyección de Providers globales: sesión, catálogo con filtros,
    // favoritos, reservas del explorador y módulo de cotizaciones.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CatalogController()),
        ChangeNotifierProvider(create: (_) => FavoritosController()),
        ChangeNotifierProvider(create: (_) => MisReservasController()),
        ChangeNotifierProvider(create: (_) => QuotesController()),
      ],
      child: MaterialApp(
        title: "Pa'onde",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        builder: _guardiaViewport,
        initialRoute: AppRoutes.landing,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

/// En Flutter Web el primer frame puede medir un viewport diminuto antes de
/// que el navegador asiente el tamaño real; construir la UI en ese instante
/// dispara overflows que dejan el render congelado en una pantalla oscura.
/// Este guard pinta solo el fondo hasta tener un tamaño utilizable.
Widget _guardiaViewport(BuildContext context, Widget? child) {
  final tamano = MediaQuery.sizeOf(context);
  if (tamano.width < 150 || tamano.height < 150) {
    return const ColoredBox(color: AppColors.verdeOscuro);
  }
  return child!;
}
