import 'package:flutter/material.dart';
import '../features/login/login_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

// pagina uno, como en figma
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable de estado: true = Explorador activo, false = Anfitrión activo
  bool isExploradorActive = true;

  final CarouselSliderController _destinosController =
      CarouselSliderController();
  final CarouselSliderController _AlojamientosController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xffE2E600);
    const Color cardBgColor = Color(0xff1C241B);

    // Medidas de la pantalla para el diseño responsivo
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Ajuste dinámico para que las tarjetas de abajo no crezcan hacia abajo en PC
    double dynamicAspectRatio = 1.05;
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
          // Encabezado responsivo
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: false,
            backgroundColor: const Color(0xff1A1F16),
            actions: [

              SizedBox(
              height: isMobile ? 32:40, // Espacio a la derecha para que no quede pegado al borde
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffE2E600), width: 2),
                  backgroundColor: const Color(0xff1A1F16),
                  foregroundColor: const Color(0xffE2E600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Iniciar Sesión',
                    style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(

              height: isMobile ? 32 : 40, // Espacio a la derecha para que
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE2E600),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                 
                ),
                child: Text(
                  'Registrarse',
                  style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14
                    ),
                  ),
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
                        Image.asset(
                          'assets/Logo.png',
                          width: isMobile ? 180 : 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        Image.asset(
                          'assets/eslogandos.png',
                          width: isMobile ? 150 : 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cuerpo de la página contenido y limitado en su ancho máximo
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ), // Marco controlado a 1000px
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          '¿Qué te ofrecemos?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tarjetas Horizontales originales
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
                        child: Text(
                          "Descubre tu lugar en pa'onde",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
                              // PESTAÑA: EXPLORADOR
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExploradorActive = true;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExploradorActive
                                        ? primaryYellow
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Explorador',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isExploradorActive
                                          ? Colors.black87
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),

                              // PESTAÑA: ANFITRIÓN
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExploradorActive = false;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isExploradorActive
                                        ? primaryYellow
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Anfitrión',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: !isExploradorActive
                                          ? Colors.black87
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // RENDERIZADO DINÁMICO SEGÚN MÓVIL O PC
                      if (isExploradorActive) ...[
                        if (isMobile) ...[
                          // Diseño Vertical para telfs (Explorador)
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
                          // Diseño Horizontal (Grid) para Desktop / Tablet (Explorador)
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
                        // Sección alternativa cuando Anfitrión está activo
                        if (isMobile) ...[
                          // Diseño Vertical para Móviles (Anfitrión)
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
                          // Diseño Horizontal (Grid) para Desktop / Tablet (Anfitrión)
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

                      const SizedBox(height: 48),
                      const Center(
                        child: Text(
                          'Tu próxima aventura comienza aquí',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryYellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          "¿Pa'onde quieres ir?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BARRA DE BÚSQUEDA Y BOTÓN AL LADO UNIFICADOS
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Escribe un destino, experiencia o servicio...',
                                      hintStyle: const TextStyle(
                                        color: Color.fromARGB(
                                          179,
                                          150,
                                          150,
                                          144,
                                        ),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Color.fromARGB(
                                          179,
                                          150,
                                          150,
                                          144,
                                        ),
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.white10,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // BOTÓN TOTALMENTE CUADRADO (44x44)
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color.fromARGB(
                                    188,
                                    111,
                                    111,
                                    111,
                                  ),
                                  elevation: 0,
                                  fixedSize: const Size(40, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                  Icons.filter_list_outlined,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildSectionHeader(
                        title: "Descubre Venezuela",
                        controller: _destinosController,
                      ),
                      const SizedBox(height: 16),
                      _buildCarousel(
                        controller: _destinosController,
                        viewportFraction: isMobile
                            ? 0.6
                            : 0.23, // Muestra aprox 4 tarjetas en PC
                        height: 140,
                        items: List.generate(
                          6,
                          (index) => _buildDestinoPlaceholderCard(),
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "Servicios destacados",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryYellow,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionHeader(
                        title: "Alojamientos",
                        controller: _AlojamientosController,
                        isSubSection: true,
                      ),
                      const SizedBox(height: 16),
                      _buildCarousel(
                        controller: _AlojamientosController,
                        viewportFraction: isMobile
                            ? 0.85
                            : 0.25, // Muestra 4 tarjetas completas en desktop
                        height: 310,
                        items: List.generate(
                          6,
                          (index) => _buildAlojamientoPlaceholderCard(),
                        ),
                      ),
                      const SizedBox(height: 40),

                      const SizedBox(height: 12),
                      _buildSectionHeader(
                        title: "Experiencias",
                        controller: _AlojamientosController,
                        isSubSection: true,
                      ),
                      const SizedBox(height: 16),
                      _buildCarousel(
                        controller: _AlojamientosController,
                        viewportFraction: isMobile
                            ? 0.65
                            : 0.35, // Muestra 4 tarjetas completas en desktop
                        height: isMobile ? 120: 150,
                        items: List.generate(
                          6,
                          (index) => _buildExperienciaPlaceholderCard(),
                        ),
                      ),

                      const SizedBox(height: 16 ),
                      const Divider(
                        color: primaryYellow ,
                        thickness: 1,         
                        indent: 0,           
                        endIndent: 0,        
                      ),
                      // NUEVA SECCIÓN: Footer / Barra de navegación inferior
                      Padding(
                      // MODIFICACIÓN: Reducimos el padding inferior para pegarlo más al borde de la página
                        padding: EdgeInsets.only(
                          top: isMobile ? 4.0 : 8.0,
                          bottom: isMobile ? 0.0 : 4.0 // Menos espacio abajo si es móvil
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center, // Alinea verticalmente el logo y los textos
                          children: [
                            
                            Image.asset(
                               'assets/logo.png', 
                               width: isMobile ? 80: 150, 
                                fit: BoxFit.contain,
                                 // Alinea el logo a la izquierda dentro de su espacio
                              ),
                            

                            // LADO DERECHO: Enlaces que se mantienen horizontales
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
                                children: [
                                  _buildFooterLink('Sobre Nosotros', isMobile, () {
                                    Navigator.pushNamed(context, '/sobre-nosotros');
                                  }),
                                  SizedBox(width: isMobile ? 6 : 20), // Espaciado más ajustado en móvil
                                  _buildFooterLink('Sé un Aliado', isMobile, () {
                                    Navigator.pushNamed(context, '/se-un-aliado');
                                  }),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  _buildFooterLink('Ayuda', isMobile, () {
                                    Navigator.pushNamed(context, '/ayuda');
                                  }),
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
Widget _buildFooterLink(String title, bool isMobile, VoidCallback onTap) {
  return InkWell(
    onTap: onTap, // <--- Aquí se ejecuta la acción personalizada
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 13 : 15,
          fontWeight: FontWeight.w500,
        ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryYellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
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
      width: double.infinity,
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
              fontSize: 14,
              color: Colors.white70,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget _buildSectionHeader({
  required String title,
  required CarouselSliderController controller,
  bool isSubSection = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Envolver el texto en Expanded previene errores si el título es muy largo
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontSize: isSubSection ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Row(
        mainAxisSize:
            MainAxisSize.min, // Evita que esta sub-fila ocupe espacio de más
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white70,
              size: 18,
            ),
            onPressed: () => controller.previousPage(
              duration: const Duration(milliseconds: 300),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
            onPressed: () => controller.nextPage(
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildCarousel({
  required CarouselSliderController controller,
  required double viewportFraction,
  required double height,
  required List<Widget> items,
}) {
  return CarouselSlider(
    carouselController: controller,
    options: CarouselOptions(
      height: height,
      viewportFraction: viewportFraction,
      padEnds: false, // Alinea el carrusel a la izquierda tal como Figma
      enableInfiniteScroll: false,
      initialPage: 0,
      disableCenter: true,
    ),
    items: items,
  );
}

Widget _buildDestinoPlaceholderCard() {
  return Container(
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(
      color: const Color(0xff2A2E24),
      borderRadius: BorderRadius.circular(16),
      // Creación del patrón cuadriculado simulando la falta de imagen de Figma
      image: const DecorationImage(
        image: AssetImage(
          'assets/checkerboard.png',
        ), // Opcional si tienes el asset cuadriculado
        repeat: ImageRepeat.repeat,
        opacity: 0.05,
      ),
    ),
    child: Stack(
      children: [
        // Fondo Grisáceo transparente de Figma
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        const Center(
          child: Text(
            'Destino',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// =========================================================================
// TARJETA DE ALOJAMIENTO DETALLADA (COMPLETA COMO EL DISEÑO)
// =========================================================================
Widget _buildExperienciaPlaceholderCard() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Detectamos si la pantalla o el contenedor es muy pequeño (por ejemplo, menos de 340px)
      bool esPantallaPequena = constraints.maxWidth < 340;

      return Container(
        // Si no tienes un ancho fijo externo, puedes usar el double.infinity o dejarlo libre
        width: 350, 
        height: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // ZONA IZQUIERDA: Imagen (Se ajusta el ancho dinámicamente)
            Container(
              // Si la pantalla es pequeña, la imagen mide 90px; si no, 110px
              width: esPantallaPequena ? 90 : 110, 
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[200]!, Colors.grey[300]!],
                ),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 24),
              ),
            ),
            
            // ZONA DERECHA: Detalles del Servicio
            Expanded(
              child: Padding(
                // Reducimos un poco el padding si el espacio es interno
                padding: EdgeInsets.fromLTRB(4, 12, esPantallaPequena ? 8 : 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ubicación y Estrellas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: const [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  'Place', 
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) => const Icon(Icons.star, size: 12, color: Colors.amber)),
                        )
                      ],
                    ),
                    
                    // Título
                    const Text(
                      'Título del servicio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Descripción
                    const Text(
                      'Descripción del servicio que se esta presentando',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.2),
                    ),
                    
                    // ACCIONES: Botón Reservar, Favorito e Importe (Optimizado para espacio)
                    Row(
                      children: [
                        // El botón ahora se expande para usar el espacio disponible de forma segura
                        Expanded(
                          flex: 3, // Le da prioridad de espacio al botón
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1A1F16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 4), // Padding mínimo interno
                              ),
                              // El FittedBox hace que el texto se encoja proporcionalmente si no cabe
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Reservar', 
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        
                        // Icono de favorito
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.favorite_border, size: 16, color: Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        
                        // Precio envuelto en Flexible para evitar desbordes
                        const Flexible(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '50\$/persona',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    },
  );

}

Widget _buildAlojamientoPlaceholderCard() {
  return Container(
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zona superior: Cuadrícula transparente (Placeholder de imagen)
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              // fondo transparente
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[200]!, Colors.grey[400]!],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.black26,
                size: 32,
              ),
            ),
          ),
        ),
        // Zona inferior: Detalles del Servicio
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            key: UniqueKey(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ubicación y Estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Place',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Título del servicio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Descripción del servicio que se esta presentando',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                ),
                // Botón Reservar, Favorito e Importe
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1A1F16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Reservar',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '50\$/noche',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
