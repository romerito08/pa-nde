import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Importamos el favoritosProvider global
import '../features/login/login_screen.dart';
import '../widgets/alojamiento_card.dart';
import '../widgets/experiencia_card.dart';
import '../widgets/destino_card.dart';
import '../widgets/footer.dart';
import '../widgets/carousel_section.dart';
import '../features/register/registro_screen.dart';
import 'hotel_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isExploradorActive = true;

  void _onReservarPressed(String hotelId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelDetailScreen(hotelId: hotelId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(hotelId: hotelId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xffE2E600);
    const Color cardBgColor = Color(0xff1C241B);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Ajuste de aspecto para dar más altura a las tarjetas
    double dynamicAspectRatio = 1.15;
    if (!isMobile) {
      if (screenWidth > 1200) {
        dynamicAspectRatio = 1.6;
      } else if (screenWidth > 900) {
        dynamicAspectRatio = 1.3;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: false,
            backgroundColor: const Color(0xff1A1F16),
            actions: [
              SizedBox(
                height: isMobile ? 32 : 40,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryYellow, width: 2),
                    backgroundColor: const Color(0xff1A1F16),
                    foregroundColor: primaryYellow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Iniciar Sesión',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: isMobile ? 32 : 40,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistroScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Registrarse',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Image.asset('assets/Logo.png', width: isMobile ? 180 : 250, fit: BoxFit.contain),
                        const SizedBox(height: 12),
                        Image.asset('assets/eslogandos.png', width: isMobile ? 150 : 200, fit: BoxFit.contain),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text('¿Qué te ofrecemos?',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 24),
                      _buildOfferCard(
                        icon: Icons.maps_home_work_outlined,
                        title: 'Alojamientos',
                        description:
                            'Encuentra el hospedaje perfecto para cada tipo de viaje. Filtra por ciudad, fechas, presupuesto y tipo de alojamiento: hoteles, posadas, apartamentos y más.',
                        cardBgColor: cardBgColor,
                        primaryYellow: primaryYellow,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferCard(
                        icon: Icons.stars_outlined,
                        title: 'Experiencias',
                        description:
                            'Descubre actividades únicas con operadores locales de confianza. Desde rutas de montaña hasta experiencias gastronómicas, siempre con reseñas verificadas.',
                        cardBgColor: cardBgColor,
                        primaryYellow: primaryYellow,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferCard(
                        icon: Icons.directions_car_outlined,
                        title: 'Logística y Traslados',
                        description:
                            'Viaja sin complicaciones. Encuentra experiencias y paquetes que ya incluyen el traslado al destino, asegurando que llegues de forma cómoda y segura a cada aventura.',
                        cardBgColor: cardBgColor,
                        primaryYellow: primaryYellow,
                      ),
                      const SizedBox(height: 48),
                      const Center(
                        child: Text("Descubre tu lugar en pa'onde",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(179, 150, 150, 144),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTabButton(
                                  'Explorador', isExploradorActive, () => setState(() => isExploradorActive = true),
                                  primaryYellow),
                              _buildTabButton(
                                  'Anfitrión', !isExploradorActive, () => setState(() => isExploradorActive = false),
                                  primaryYellow),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (isExploradorActive) ...[
                        if (isMobile) ...[
                          _buildOfferCard2(
                            icon: Icons.explore_outlined,
                            title: 'Exploración Inteligente',
                            description:
                                'Busca por destino, fechas y presupuesto. Los filtros avanzados te llevan directo a lo que necesitas, sin perder tiempo.',
                          ),
                          const SizedBox(height: 16),
                          _buildOfferCard2(
                            icon: Icons.stars_outlined,
                            title: 'Reserva con Confianza',
                            description:
                                "Cada Aliado está verificado por el equipo Pa'onde. Lee reseñas reales antes de reservar y decide con información de verdad.",
                          ),
                          const SizedBox(height: 16),
                          _buildOfferCard2(
                            icon: Icons.check_circle_outline,
                            title: 'Todo en un Solo Lugar',
                            description:
                                'Alojamiento, experiencias y traslados juntos. Organiza tu viaje completo sin salir de la plataforma.',
                          ),
                        ] else ...[
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: dynamicAspectRatio,
                            children: [
                              _buildOfferCard2(
                                icon: Icons.explore_outlined,
                                title: 'Exploración Inteligente',
                                description:
                                    'Busca por destino, fechas y presupuesto. Los filtros avanzados te llevan directo a lo que necesitas, sin perder tiempo.',
                              ),
                              _buildOfferCard2(
                                icon: Icons.stars_outlined,
                                title: 'Reserva con Confianza',
                                description:
                                    "Cada Aliado está verificado por el equipo Pa'onde. Lee reseñas reales antes de reservar y decide con información de verdad.",
                              ),
                              _buildOfferCard2(
                                icon: Icons.check_circle_outline,
                                title: 'Todo en un Solo Lugar',
                                description:
                                    'Alojamiento, experiencias y traslados juntos. Organiza tu viaje completo sin salir de la plataforma.',
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        if (isMobile) ...[
                          _buildOfferCard2(
                            icon: Icons.file_upload_outlined,
                            title: 'Publica tu Servicio',
                            description:
                                'Crea tu publicación con fotos, descripción, precios y disponibilidad. Tu negocio viable para miles de viajeros en minutos.',
                          ),
                          const SizedBox(height: 16),
                          _buildOfferCard2(
                            icon: Icons.calendar_month_outlined,
                            title: 'Gestiona tus Reservas',
                            description:
                                'Recibe solicitudes, confirma reservas y lleva el control de tu agenda desde un panel diseñado para hacerte la vida más facil',
                          ),
                          const SizedBox(height: 16),
                          _buildOfferCard2(
                            icon: Icons.bar_chart_outlined,
                            title: 'Crece con Estadísticas',
                            description:
                                'Visualiza las númericas: reservas del mes, ingresos, calificación promedio y que servrvicios ganaron más interés',
                          ),
                        ] else ...[
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: dynamicAspectRatio,
                            children: [
                              _buildOfferCard2(
                                icon: Icons.file_upload_outlined,
                                title: 'Publica tu Servicio',
                                description:
                                    'Crea tu publicación con fotos, descripción, precios y disponibilidad. Tu negocio viable para miles de viajeros en minutos.',
                              ),
                              _buildOfferCard2(
                                icon: Icons.calendar_month,
                                title: 'Gestiona tus Reservas',
                                description:
                                    'Recibe solicitudes, confirma reservas y lleva el control de tu agenda desde un panel diseñado para hacerte la vida más facil',
                              ),
                              _buildOfferCard2(
                                icon: Icons.bar_chart_outlined,
                                title: 'Crece con Estadísticas',
                                description:
                                    'Visualiza las númericas: reservas del mes, ingresos, calificación promedio y que servrvicios ganaron más interés',
                              ),
                            ],
                          ),
                        ],
                      ],
                      const SizedBox(height: 54),
                      const Center(
                        child: Text('Tu próxima aventura comienza aquí',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryYellow)),
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text("¿Pa'onde quieres ir?",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe un destino, experiencia o servicio...',
                                      hintStyle: const TextStyle(
                                        color: Color.fromARGB(179, 150, 150, 144),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Color.fromARGB(179, 150, 150, 144), size: 20),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.white10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color.fromARGB(188, 111, 111, 111),
                                  elevation: 0,
                                  fixedSize: const Size(40, 40),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(Icons.tune, size: 25),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      CarouselSection(
                        title: "Descubre Venezuela",
                        height: 155,
                        viewportFraction: isMobile ? 0.6 : 0.23,
                        items: List.generate(6, (index) => DestinoCard()),
                      ),
                      const SizedBox(height: 48),
                      const Text("Servicios destacados",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryYellow)),
                      const SizedBox(height: 16),
                      
                      // SECTION ALOJAMIENTOS CORREGIDA CON ESPACIADO LATERAL REAL
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('hoteles').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 275,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final hotels = snapshot.data!.docs;
                          if (hotels.isEmpty) {
                            return const SizedBox(
                              height: 275,
                              child: Center(child: Text('No hay hoteles disponibles', style: TextStyle(color: Colors.white70))),
                            );
                          }
                          return CarouselSection(
                            title: "Alojamientos",
                            isSubSection: true,
                            height: 275, 
                            // AJUSTE: Bajamos levemente el fraction para liberar aire entre tarjetas
                            viewportFraction: isMobile ? 0.80 : 0.23,
                            items: hotels.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final String hotelId = doc.id;

                              // SOLUCIÓN DEFINITIVA: Separación manual inyectada al vuelo
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AlojamientoCard(
                                  hotelId: hotelId,
                                  nombre: data['nombre'] ?? 'Sin nombre',
                                  ubicacion: data['ubicacion'] ?? 'Sin ubicación',
                                  precio: (data['precioPorNoche'] ?? 0).toDouble(),
                                  imagenUrl: data['imagenUrl'] ?? '',
                                  onReservar: () => _onReservarPressed(hotelId),
                                  isFavorito: favoritosProvider.esAlojamientoFavorito(hotelId),
                                  onFavorito: () => favoritosProvider.toggleAlojamiento(hotelId),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 48),
                      
                      // SECTION EXPERIENCIAS REFORMADA
                      CarouselSection(
                        title: "Experiencias",
                        isSubSection: true,
                        height: isMobile ? 140 : 165,
                        viewportFraction: isMobile ? 0.65 : 0.35,
                        items: List.generate(
                          6,
                          (index) {
                            final String experienciaId = "experiencia_home_index_$index";

                            return ExperienciaCard(
                              onReservar: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Próximamente')),
                              ),
                              isFavorito: favoritosProvider.esExperienciaFavorita(experienciaId),
                              onFavorito: () => favoritosProvider.toggleExperiencia(experienciaId),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: primaryYellow, thickness: 1),
                      Padding(
                        padding: EdgeInsets.only(top: isMobile ? 4.0 : 8.0, bottom: isMobile ? 0.0 : 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/logo.png', width: isMobile ? 80 : 150, fit: BoxFit.contain),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Footer(
                                    title: 'Sobre Nosotros',
                                    isMobile: isMobile,
                                    onTap: () => Navigator.pushNamed(context, '/sobre-nosotros'),
                                  ),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(
                                    title: 'Sé un Aliado',
                                    isMobile: isMobile,
                                    onTap: () => Navigator.pushNamed(context, '/partner-register'),
                                  ),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(
                                    title: 'Ayuda',
                                    isMobile: isMobile,
                                    onTap: () => Navigator.pushNamed(context, '/ayuda'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap, Color primaryYellow) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.black),
        ),
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
      decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryYellow)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1C241B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xffE2E600),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 