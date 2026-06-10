// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/login/login_screen.dart';
import 'package:paonde_app/screens/alojamientos_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/experiencias_screens.dart';
import 'screens/destinos_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/perfil_screen.dart'; // Perfil del Explorador / Usuario común

// --- IMPORTACIONES DE PARTNER (ALIADOS) ---
import 'features/partner/partner_register_screen.dart';
import 'features/partner/partner_dashboard_screen.dart';
import 'features/partner/mis_servicios_aliado_screen.dart';
import 'features/partner/partner_quotes_screen.dart';
import 'features/partner/partner_reservations_screen.dart';
import 'features/partner/partner_profile_screen.dart'; // NUEVA IMPORTACIÓN CORREGIDA
import 'features/partner/create_hotel_screen.dart';
import 'features/partner/edit_hotel_screen.dart';

// Importación del proveedor de favoritos
import 'providers/favoritos_provider.dart'; 

// Instancia global accesible desde cualquier pantalla del proyecto
final favoritosProvider = FavoritosProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pa\'onde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff1A1F16),
      ),
      initialRoute: '/',
      
      builder: (context, child) {
        return ListenableBuilder(
          listenable: favoritosProvider,
          builder: (context, _) => child!,
        );
      },

      routes: {
        // --- RUTAS PÚBLICAS / EXPLORADOR ---
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/inicio': (context) => const InicioScreen(),
        '/alojamientos': (context) => const AlojamientosScreen(),
        '/experiencias': (context) => const ExperienciaScreen(),
        '/destino': (context) => const DestinoScreen(),
        '/reservas': (context) => const ReservaScreen(),
        '/perfil': (context) => const PerfilScreen(), // Vista de perfil para el cliente final
        
        // --- RUTAS DE MANAGEMENT DE ALIADOS ---
        '/partner-register': (context) => const PartnerRegisterScreen(),
        '/partner-dashboard': (context) => const DashboardAliadoScreen(),
        '/partner-quotes': (context) => const CotizacionesAliadoScreen(),
        '/partner-reservations': (context) => const ReservasAliadoScreen(),
        '/partner-services': (context) => const MisServiciosAliadoScreen(),
        '/partner-profile': (context) => const PerfilAliadoScreen(), // NUEVA RUTA INTEGRADA PARA EL ALIADO
        
        // --- ACCIONES ESPECÍFICAS ---
        '/create-hotel': (context) => const CreateHotelScreen(),
      },
      
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-hotel') {
          final hotelId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EditHotelScreen(hotelId: hotelId),
          );
        }
        return null;
      },
    );
  }
}