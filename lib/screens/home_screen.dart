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

                const Center(
                  child: Text(
                    'Descubre tu lugar en pa\'onde',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(0.1),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 129, 129, 124),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 7 ),
                          decoration: BoxDecoration(
                            color:primaryYellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Explorardor',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical:7 ),
                          child: const Text(
                            'Anfitrión',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ]
                    )
                  )
                ),
                const SizedBox(height: 30),

                
                

                GridView.count(
                  shrinkWrap: true, // Permite que el GridView viva dentro del SliverList
                  physics: const NeverScrollableScrollPhysics(), // Deja que el scroll lo maneje el CustomScrollView
                  crossAxisCount: 3, // 3 columnas en horizontal
                  crossAxisSpacing: 16, // Espacio horizontal entre tarjetas
                  mainAxisSpacing: 10, // Espacio vertical (por si cambian de fila en pantallas chicas)
                  childAspectRatio: 1.03, // Ajusta esta relación (Ancho / Alto) para controlar la altura total
                  children: [
                    _buildOfferCard2(
                      icon: Icons.explore_outlined,
                      title: 'Exploración Inteligente',
                      description: 'Busca por destino, fechas y presupuesto. Los filtros avanzados te llevan directo a lo que necesitas, sin perder tiempo.',
                    ),
                    _buildOfferCard2(
                      icon: Icons.stars_outlined,
                      title: 'Reserva con Confianza',
                      description: 'Cada Aliado está verificado por el equipo Pa\'onde. Lee reseñas reales antes de reservar y decide con información de verdad.',
                    ),
                    _buildOfferCard2(
                      icon: Icons.check_circle_outline,
                      title: 'Todo en un Solo Lugar',
                      description: 'Alojamiento, experiencias y traslados juntos. Organiza tu viaje completo sin salir de la plataforma.',
                    ),
                  ],
                ),
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
        borderRadius: BorderRadius.circular(10),
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

  

  Widget _buildOfferCard2({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1C241B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 226, 230, 0),
              shape: BoxShape.circle,
              
            ),
            child: Icon(icon, size: 50, color: const Color.fromARGB(221, 255, 255, 255)),
          ),
          
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffE2E600)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
