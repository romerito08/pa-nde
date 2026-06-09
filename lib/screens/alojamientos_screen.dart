import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
import '../widgets/alojamiento_card.dart';
import 'hotel_detail_screen.dart';  

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
      drawer: isMobile ? CustomDrawer(selectedIndex: 0) : null,
      appBar: isMobile ? Header(selectedIndex: 1, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) Header(isMobile: false, selectedIndex: 1),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: isMobile ? 220 : 350,
                  width: double.infinity,
                  child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
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
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          '¿Pa\'onde quieres ir?',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Barra de búsqueda (igual que antes)
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: 'Escribe un destino, experiencia o servicio...',
                                    hintStyle: const TextStyle(color: Color.fromARGB(179, 150, 150, 144), fontSize: 14),
                                    prefixIcon: const Icon(Icons.search, color: Color.fromARGB(179, 150, 150, 144), size: 20),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black)),
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
                      const SizedBox(height: 40),
                      // Grid de hoteles desde Firestore
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('hoteles').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 400,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const SizedBox(
                              height: 400,
                              child: Center(child: Text('No hay hoteles disponibles', style: TextStyle(color: Colors.white70))),
                            );
                          }
                          final hotels = snapshot.data!.docs;
                          // Calcular columnas dinámicamente
                          int crossAxisCount = 4;
                          if (screenWidth < 600) crossAxisCount = 1;
                          else if (screenWidth < 900) crossAxisCount = 2;
                          else if (screenWidth < 1100) crossAxisCount = 3;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 20,
                              childAspectRatio: isMobile ? 0.85 : 0.78,
                            ),
                            itemCount: hotels.length,
                            itemBuilder: (context, index) {
                              final doc = hotels[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return AlojamientoCard(
                                hotelId: doc.id,
                                nombre: data['nombre'] ?? 'Sin nombre',
                                ubicacion: data['ubicacion'] ?? 'Sin ubicación',
                                precio: (data['precioPorNoche'] ?? 0).toDouble(),
                                imagenUrl: data['imagenUrl'] ?? '',
                                onReservar: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HotelDetailScreen(hotelId: doc.id),
                                    ),
                                  );
                                },
                                onFavorito: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Función de favoritos próximamente')),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40),
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
                                  Footer(title: 'Sobre Nosotros', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/sobre-nosotros')),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(title: 'Sé un Aliado', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/partner-register')),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(title: 'Ayuda', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/ayuda')),
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