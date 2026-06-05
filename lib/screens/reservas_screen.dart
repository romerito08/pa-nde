import 'package:flutter/material.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
//import '../widgets/destino_card.dart';

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({super.key});

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);

    return Scaffold(
      backgroundColor: bgColor,

      drawer: isMobile ? CustomDrawer(selectedIndex: 0) : null,
      appBar: isMobile ? Header(selectedIndex: 4, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 3. HEADER PARA ESCRITORIO (Solo se dibuja si NO es móvil)
            if (!isMobile) Header(isMobile: false, selectedIndex: 4),

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
                bottom: isMobile ? 0.0 : 4.0, // Menos espacio abajo si es móvil
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
                      mainAxisSize:
                          MainAxisSize.min, // Ocupa solo el espacio necesario
                      children: [
                        Footer(
                          title: 'Sobre Nosotros',
                          isMobile: isMobile,
                          onTap: () {
                            Navigator.pushNamed(context, '/sobre-nosotros');
                          },
                        ),
                        SizedBox(
                          width: isMobile ? 6 : 20,
                        ), // Espaciado más ajustado en móvil
                        Footer(
                          title: 'Sé un Aliado',
                          isMobile: isMobile,
                          onTap: () {
                            Navigator.pushNamed(context, '/se-un-aliado');
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
    );
  }
}
