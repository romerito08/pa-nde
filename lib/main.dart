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
import 'firebase_options.dart';

Future<void> main() async {
  // Inicialización asíncrona de Firebase antes de montar la UI.
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const PaondeApp());
  } catch (_) {
    // Resiliencia (RNF03): si Firebase no pudo inicializar (sin red, mala
    // configuración), se muestra una pantalla amigable con reintento en
    // lugar de congelar la app en blanco.
    runApp(const ArranqueFallidoApp());
  }
}

class PaondeApp extends StatelessWidget {
  const PaondeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyección de Providers globales: sesión, catálogo con filtros,
    // favoritos y acciones de reservas del explorador.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CatalogController()),
        ChangeNotifierProvider(create: (_) => FavoritosController()),
        ChangeNotifierProvider(create: (_) => MisReservasController()),
      ],
      child: MaterialApp(
        title: "Pa'onde",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRoutes.explorar,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

/// Pantalla de contingencia cuando la inicialización de Firebase falla.
class ArranqueFallidoApp extends StatelessWidget {
  const ArranqueFallidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pa'onde",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  onPressed: main,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
