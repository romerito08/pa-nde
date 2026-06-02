import 'package:flutter/material.dart';
import '../features/login/login_screen.dart';
import '../widgets/alojamiento_card.dart';
import '../widgets/carousel_section.dart';
import '../widgets/destino_card.dart';
import '../widgets/experiencia_card.dart';
import '../widgets/footer.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
 

  // Variable para controlar qué opción está seleccionada actualmente
  // 0: Inicio, 1: Alojamientos, 2: Experiencias, 3: Destinos, 4: Reservas, 5: Mi perfil
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Detectamos el ancho de la pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);
    return Scaffold(
      backgroundColor: bgColor,

      // 1. MENÚ LATERAL (DRAWER) PARA MÓVILES
      // Contiene las 6 opciones requeridas organizadas verticalmente para que no se desborden
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xff252B20),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: bgColor),
                    child: Center(
                      child: Image.asset('assets/Logo.png', width: 120),
                    ),
                  ),
                  _drawerLink('Inicio', 0, Icons.home_outlined, primaryYellow),
                  _drawerLink('Alojamientos', 1, Icons.hotel_outlined, primaryYellow),
                  _drawerLink('Experiencias', 2, Icons.explore_outlined, primaryYellow),
                  _drawerLink('Destinos', 3, Icons.map_outlined, primaryYellow),
                  _drawerLink('Reservas', 4, Icons.book_online_outlined, primaryYellow),
                  const Divider(color: Colors.white12, height: 20),
                  _drawerLink('Mi perfil', 5, Icons.account_circle_outlined, primaryYellow),
                ],
              ),
            )
          : null,

      // 2. APPBAR PARA MÓVILES
      // Añade el botón de menú tipo hamburguesa de manera nativa para abrir el Drawer
      appBar: isMobile
          ? AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Image.asset('assets/Logo.png', width: 100),
              centerTitle: true,
            )
          : null,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 3. HEADER PARA ESCRITORIO (Solo se dibuja si NO es móvil)
            if (!isMobile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                color: bgColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/Logo.png', width: 120),
                    Row(
                      children: [
                        _navLink('Inicio', 0, primaryYellow),
                        _navLink('Alojamientos', 1, primaryYellow),
                        _navLink('Experiencias', 2, primaryYellow),
                        _navLink('Destinos', 3, primaryYellow),
                        _navLink('Reservas', 4, primaryYellow),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 5;
                        });
                      },
                      icon: Text(
                        'Mi perfil',
                        style: TextStyle(
                          color:primaryYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: Icon(
                        Icons.account_circle_outlined,
                        color: primaryYellow,
                      ),
                    ),
                  ],
                ),
              ),

            // 4. HERO SECTION (Adaptable en tamaño)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: isMobile ? 220 : 350,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/Encabezado.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Encuentra tu próxima aventura',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 26 : 42,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(blurRadius: 10, color: Colors.black45)],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

           Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000, // Mismo límite de 1000px que home_screen
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, // Margen lateral idéntico
                    vertical: 32.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 5. SECCIÓN DE BÚSQUEDA
                      const Center(
                        child: Text(
                          '¿Pa\'onde quieres ir?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // BARRA DE BÚSQUEDA
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
                                      hintText: 'Escribe un destino, experiencia o servicio...',
                                      hintStyle: const TextStyle(
                                        color: Color.fromARGB(179, 150, 150, 144),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Color.fromARGB(179, 150, 150, 144),
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
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

                              // BOTÓN TOTALMENTE CUADRADO
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color.fromARGB(188, 111, 111, 111),
                                  elevation: 0,
                                  fixedSize: const Size(40, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      CarouselSection(
                        title: "Descubre Venezuela",
                        height: 140,
                        viewportFraction: isMobile ? 0.6 : 0.23,
                        items: List.generate(6, (index) => DestinoCard()),
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
                      CarouselSection(
                        title: "Alojamientos",
                        isSubSection: true,
                        height: 310,
                        viewportFraction: isMobile ? 0.85 : 0.25,
                        items: List.generate(
                          6,
                          (index) => AlojamientoCard(
                            onReservar: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                            onFavorito: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      CarouselSection(
                        title: "Experiencias",
                        isSubSection: true,
                        height: isMobile ? 120 : 150,
                        viewportFraction: isMobile ? 0.65 : 0.35,
                        items: List.generate(
                          6,
                          (index) => ExperienciaCard(
                            onReservar: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                            onFavorito: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      const Text(
                        "Aprovecha las ofertas",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryYellow,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CarouselSection(
                        title: "Alojamientos",
                        isSubSection: true,
                        height: 310,
                        viewportFraction: isMobile ? 0.85 : 0.25,
                        items: List.generate(
                          6,
                          (index) => AlojamientoCard(
                            onReservar: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                            onFavorito: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      CarouselSection(
                        title: "Experiencias",
                        isSubSection: true,
                        height: isMobile ? 120 : 150,
                        viewportFraction: isMobile ? 0.65 : 0.35,
                        items: List.generate(
                          6,
                          (index) => ExperienciaCard(
                            onReservar: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                            onFavorito: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                       const Divider(
                        color: primaryYellow,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      // NUEVA SECCIÓN: Footer / Barra de navegación inferior
                      Padding(
                        // MODIFICACIÓN: Reducimos el padding inferior para pegarlo más al borde de la página
                        padding: EdgeInsets.only(
                          top: isMobile ? 4.0 : 8.0,
                          bottom: isMobile
                              ? 0.0
                              : 4.0, // Menos espacio abajo si es móvil
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Alinea verticalmente el logo y los textos
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: isMobile ? 80 : 150,
                              fit: BoxFit.contain,
                              // Alinea el logo a la izquierda dentro de su espacio
                            ),

                            // LADO DERECHO: Enlaces que se mantienen horizontales
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize
                                    .min, // Ocupa solo el espacio necesario
                                children: [
                                  Footer(
                                    title: 'Sobre Nosotros',
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/sobre-nosotros',
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: isMobile ? 6 : 20,
                                  ), // Espaciado más ajustado en móvil
                                  Footer(
                                    title: 'Sé un Aliado',
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/se-un-aliado',
                                      );
                                    },
                                  ),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(
                                    title: 'Ayuda',
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.pushNamed(context, '/ayuda');
                                    },
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
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE AYUDA PARA LOS LINKS ---

  Widget _navLink(String text, int index, Color primaryYellow) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? primaryYellow : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _drawerLink(String text, int index, IconData icon, Color primaryYellow) {
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? primaryYellow : Colors.white70,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? primaryYellow : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}