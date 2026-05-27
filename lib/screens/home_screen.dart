import 'package:flutter/material.dart';
// import 'features/login/login_screen.dart';

//pagina uno, como en figma
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xffE2E600);
    const Color cardBgColor = Color(0xff1C241B);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xff1A1F16),
            //boton de iniciar sesion
            actions: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffE2E600), width: 2),
                  backgroundColor: const Color(0xff1A1F16),
                  foregroundColor: const Color(0xffE2E600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE2E600),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SizedBox.expand(
                    child: Image.asset(
                      'assets/Encabezado.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/Logo.png',
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),

                        Image.asset(
                          'assets/eslogandos.png',
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Center(
                  child: Text(
                    '¿Qué te ofrecemos?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildOfferCard(
                  icon: Icons.maps_home_work_outlined,
                  title: 'Alojamientos',
                  description: 'Encuentra el hospedaje perfecto para cada tipo de viaje. Filtra por ciudad, fechas, presupuesto y tipo de alojamiento: hoteles, posadas, apartamentos y más.',
                  cardBgColor: cardBgColor,
                  primaryYellow: primaryYellow,
                  ),
                const SizedBox(height: 16),

                _buildOfferCard(
                  icon: Icons.stars_outlined,
                  title: 'Experiencias',
                  description: 'Descubre actividades únicas con operadores locales de confianza. Desde rutas de montaña hasta experiencias gastronómicas, siempre con reseñas verificadas.',
                  cardBgColor: cardBgColor,
                  primaryYellow: primaryYellow,
                ),
                const SizedBox(height: 16),

                _buildOfferCard(
                  icon: Icons.directions_car_outlined,
                  title: 'Logística y Traslados',
                  description: 'Viaja sin complicaciones. Encuentra experiencias y paquetes que ya incluyen el traslado al destino, asegurando que llegues de forma cómoda y segura a cada aventura.',
                  cardBgColor: cardBgColor,
                  primaryYellow: primaryYellow,
                ),
                const SizedBox(height: 40),
                
              ]),
            ),
          ),
        ],
      ),
    );

  }
  Widget _buildOfferCard({
    required IconData icon,
    required String title,
    required String description,
    required Color cardBgColor,
    required Color primaryYellow,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryYellow),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
