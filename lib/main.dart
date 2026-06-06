import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paonde_app/features/login/login_screen.dart';
import 'package:paonde_app/screens/alojamientos_screen.dart';
//import 'features/login/login_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/inicio_screen.dart';
//import 'screens/alojamientos_screen.dart';
import 'screens/experiencias_screens.dart';
import 'screens/destinos_screen.dart';
import 'screens/reservas_screen.dart';
import 'features/partner/partner_register_screen.dart';
import 'features/partner/partner_dashboard_screen.dart';
import 'features/partner/partner_hotels_screen.dart';
import 'features/partner/create_hotel_screen.dart';
import 'features/partner/edit_hotel_screen.dart';

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
      routes: {
        '/': (context) => const HomeScreen(), // ← cambiar a LoginScreen
        '/login': (context) => const LoginScreen(),
        '/inicio': (context) => const InicioScreen(),
        '/alojamientos': (context) => const AlojamientosScreen(),
        '/experiencias': (context) => const ExperienciaScreen(),
        '/destino': (context) => const DestinoScreen(), // ← pantalla de destinos
        '/reservas': (context) => const ReservaScreen(), // 
        '/partner-register': (context) => const PartnerRegisterScreen(),
        '/partner-dashboard': (context) => const PartnerDashboardScreen(),
        '/partner-hotels': (context) => const PartnerHotelsScreen(),
        '/create-hotel': (context) => const CreateHotelScreen(),
        '/edit-hotel': (context) => const EditHotelScreen(hotelId: ''), // No podemos pasar argumentos así
      },
    );
  }
}
