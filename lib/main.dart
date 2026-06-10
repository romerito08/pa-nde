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
import 'features/partner/partner_register_screen.dart';
import 'features/partner/partner_dashboard_screen.dart';
import 'features/partner/partner_hotels_screen.dart';
import 'features/partner/create_hotel_screen.dart';
import 'features/partner/edit_hotel_screen.dart';
import 'screens/perfil_screen.dart'; 

// 1. NUEVO: Importamos el cerebro de los favoritos
import 'providers/favoritos_provider.dart'; 

// 2. NUEVO: Instancia global accesible desde cualquier pantalla del proyecto
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
      
      // 3. NUEVO: Envolvemos con el builder global para escuchar los favoritos en toda la app
      builder: (context, child) {
        return ListenableBuilder(
          listenable: favoritosProvider,
          builder: (context, _) => child!,
        );
      },

      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/inicio': (context) => const InicioScreen(),
        '/alojamientos': (context) => const AlojamientosScreen(),
        '/experiencias': (context) => const ExperienciaScreen(),
        '/destino': (context) => const DestinoScreen(),
        '/reservas': (context) => const ReservaScreen(),
        '/partner-register': (context) => const PartnerRegisterScreen(),
        '/partner-dashboard': (context) => const PartnerDashboardScreen(),
        '/partner-hotels': (context) => const PartnerHotelsScreen(),
        '/create-hotel': (context) => const CreateHotelScreen(),
        '/perfil': (context) => const PerfilScreen(), 
      },
      onGenerateRoute: (settings) {
        // Ruta que recibe argumentos (hotelId)
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