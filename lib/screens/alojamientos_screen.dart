import 'package:flutter/material.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
import '../widgets/alojamiento_card.dart';
import 'reservas_screen.dart';


class AlojamientosScreen extends StatefulWidget {
  const AlojamientosScreen({super.key});

  @override
  State<AlojamientosScreen> createState() => _AlojamientosScreenState();
}

class _AlojamientosScreenState extends State<AlojamientosScreen> {
  
  
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);

    return Scaffold(
      backgroundColor: bgColor, 

          drawer: isMobile
          ? CustomDrawer(
              selectedIndex: 0
            )
          : null,
          appBar: isMobile
          ? Header(
              
              selectedIndex:1,
              isMobile: true,
            )
          : null,
         body: SingleChildScrollView(
        child: Column(
          children: [
            // 3. HEADER PARA ESCRITORIO (Solo se dibuja si NO es móvil)
            if (!isMobile)
              Header(
                isMobile: false,
                selectedIndex: 1,
                
              ),

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
                      shadows: const [
                        Shadow(blurRadius: 10, color: Colors.black45),
                      ],
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

                              // BOTÓN TOTALMENTE CUADRADO
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
                                child: const Icon(Icons.tune, size: 25),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculamos las columnas dinámicamente basándonos en el ancho disponible
                          // Máximo 4 columnas en pantallas grandes, mínimo 1 en pantallas muy chicas
                          int crossAxisCount = 4;
                          if (screenWidth < 600) {
                            crossAxisCount = 1;
                          } else if (screenWidth < 900) {
                            crossAxisCount = 2;
                          } else if (screenWidth < 1100) {
                            crossAxisCount = 3;
                          }
                      
                          return GridView.builder(
                            shrinkWrap: true, // Permite que funcione dentro de un SingleChildScrollView
                            physics: const NeverScrollableScrollPhysics(), // El scroll lo maneja la pantalla completa
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16, // Espacio horizontal entre tarjetas
                              mainAxisSpacing: 20,    // Espacio vertical entre filas
                              // Importante: Ajusta esta proporción según cómo quieras que se vea de alta la tarjeta
                              childAspectRatio: isMobile ? 0.85 : 0.78, 
                            ),
                            itemCount: 16, // Cambia esto por la longitud de tu lista real de alojamientos
                            itemBuilder: (context, index) {
                              return AlojamientoCard(
                                onReservar: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ReservaScreen(),
                                    ),
                                  );
                                },
                                onFavorito: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ReservaScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    
                      const SizedBox(height: 40),

                      const Divider(
                        color: primaryYellow,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
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
}
