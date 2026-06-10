import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/alojamiento_card.dart';
import '../widgets/carousel_section.dart';
import '../widgets/destino_card.dart';
import '../widgets/experiencia_card.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
import 'hotel_detail_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Lista COMPLETA de los 24 estados de Venezuela con imágenes reales de internet
  final List<Map<String, String>> _estadosCarrusel = [
    {'nombre': 'Amazonas', 'foto': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Anzoátegui', 'foto': 'https://images.unsplash.com/photo-1597200381847-30ec200eeb9a?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Apure', 'foto': 'https://images.unsplash.com/photo-1610123598147-f632aa18b275?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Aragua', 'foto': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Barinas', 'foto': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Bolívar', 'foto': 'https://images.unsplash.com/photo-1628155930542-3c7a64e2c833?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Carabobo', 'foto': 'https://images.unsplash.com/photo-1580137189272-c9379f8864fd?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Cojedes', 'foto': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Delta Amacuro', 'foto': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Distrito Capital', 'foto': 'https://images.unsplash.com/photo-1590439491754-080c55711670?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Falcón', 'foto': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Guárico', 'foto': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Lara', 'foto': 'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Mérida', 'foto': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Miranda', 'foto': 'https://images.unsplash.com/photo-1433832565846-527241675ba8?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Monagas', 'foto': 'https://images.unsplash.com/photo-1511497584788-876760111969?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Nueva Esparta', 'foto': 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Portuguesa', 'foto': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Sucre', 'foto': 'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Táchira', 'foto': 'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Trujillo', 'foto': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'La Guaira', 'foto': 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Yaracuy', 'foto': 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?q=80&w=600&auto=format&fit=crop'},
    {'nombre': 'Zulia', 'foto': 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?q=80&w=600&auto=format&fit=crop'},
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;
    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const CustomDrawer(selectedIndex: 0) : null,
      appBar: isMobile ? const Header(selectedIndex: 0, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) Header(selectedIndex: 0, isMobile: false),
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
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 26 : 42, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 10, color: Colors.black45)]),
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
                      const Center(child: Text('¿Pa\'onde quieres ir?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 20),
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
                                    hintText: 'Escribe un destino...',
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
                      
                      // Carrusel completo que leerá las 24 entidades federales
                      CarouselSection(
                        title: "Descubre Venezuela",
                        height: 140,
                        viewportFraction: isMobile ? 0.6 : 0.23,
                        items: List.generate(_estadosCarrusel.length, (index) {
                          return DestinoCard(
                            estado: _estadosCarrusel[index]['nombre']!,
                            imagenUrl: _estadosCarrusel[index]['foto']!,
                          );
                        }),
                      ),
                      const SizedBox(height: 40),
                      const Text("Servicios destacados", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryYellow)),
                      const SizedBox(height: 12),
                      
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('hoteles').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 310,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final hotels = snapshot.data!.docs;
                          if (hotels.isEmpty) {
                            return const SizedBox(
                              height: 310,
                              child: Center(child: Text('No hay hoteles disponibles', style: TextStyle(color: Colors.white70))),
                            );
                          }
                          return CarouselSection(
                            title: "Alojamientos",
                            isSubSection: true,
                            height: 310,
                            viewportFraction: isMobile ? 0.85 : 0.25,
                            items: hotels.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return AlojamientoCard(
                                hotelId: doc.id,
                                nombre: data['nombre'] ?? 'Sin nombre',
                                ubicacion: data['ubicacion'] ?? 'Sin ubicación',
                                precio: (data['precioPorNoche'] ?? 0).toDouble(),
                                imagenUrl: data['imagenUrl'] ?? '',
                                onReservar: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: doc.id)),
                                ),
                                onFavorito: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Función de favoritos próximamente')),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      CarouselSection(
                        title: "Experiencias",
                        isSubSection: true,
                        height: isMobile ? 120 : 150,
                        viewportFraction: isMobile ? 0.65 : 0.35,
                        items: List.generate(6, (index) => ExperienciaCard(
                          onReservar: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente'))),
                          onFavorito: () {},
                        )),
                      ),
                      const SizedBox(height: 40),
                      const Text("Aprovecha las ofertas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryYellow)),
                      const SizedBox(height: 12),
                      
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('hoteles').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox(height: 310);
                          final hotels = snapshot.data!.docs;
                          if (hotels.isEmpty) return const SizedBox(height: 310);
                          return CarouselSection(
                            title: "Alojamientos",
                            isSubSection: true,
                            height: 310,
                            viewportFraction: isMobile ? 0.85 : 0.25,
                            items: hotels.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return AlojamientoCard(
                                hotelId: doc.id,
                                nombre: data['nombre'] ?? 'Sin nombre',
                                ubicacion: data['ubicacion'] ?? 'Sin ubicación',
                                precio: (data['precioPorNoche'] ?? 0).toDouble(),
                                imagenUrl: data['imagenUrl'] ?? '',
                                onReservar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: doc.id))),
                                onFavorito: () {},
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      CarouselSection(
                        title: "Experiencias",
                        isSubSection: true,
                        height: isMobile ? 120 : 150,
                        viewportFraction: isMobile ? 0.65 : 0.35,
                        items: List.generate(6, (index) => ExperienciaCard(
                          onReservar: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente'))),
                          onFavorito: () {},
                        )),
                      ),
                      const SizedBox(height: 16),
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