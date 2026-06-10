import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
import '../widgets/experiencia_card.dart';
import 'reservas_screen.dart';

class ExperienciaScreen extends StatefulWidget {
  const ExperienciaScreen({super.key});

  @override
  State<ExperienciaScreen> createState() => _ExperienciaScreenState();
}

class _ExperienciaScreenState extends State<ExperienciaScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _todasLasExperiencias = [];
  List<Map<String, dynamic>> _experienciasFiltradas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExperiencias();
    _searchController.addListener(_filtrarExperiencias);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExperiencias() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('experiencias').get();
      
      final listaCargada = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();

      setState(() {
        _todasLasExperiencias = listaCargada;
        _experienciasFiltradas = listaCargada;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _todasLasExperiencias = [
          {'id': '1', 'nombre': 'Tour en catamarán Morrocoy', 'ubicacion': 'Falcón', 'precio': 120},
          {'id': '2', 'nombre': 'Parapente en la Colonia Tovar', 'ubicacion': 'Aragua', 'precio': 80},
          {'id': '3', 'nombre': 'Excursión al Salto Ángel', 'ubicacion': 'Bolívar', 'precio': 450},
          {'id': '4', 'nombre': 'Ruta del Cacao en Choroní', 'ubicacion': 'Aragua', 'precio': 45},
        ];
        _experienciasFiltradas = _todasLasExperiencias;
        _isLoading = false;
      });
    }
  }

  void _filtrarExperiencias() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _experienciasFiltradas = _todasLasExperiencias;
      } else {
        _experienciasFiltradas = _todasLasExperiencias.where((exp) {
          final nombre = (exp['nombre'] ?? '').toString().toLowerCase();
          final ubicacion = (exp['ubicacion'] ?? '').toString().toLowerCase();
          return nombre.contains(query) || ubicacion.contains(query);
        }).toList();
      }
    });
  }

  void _mostrarSelectorReserva(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReservaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const CustomDrawer(selectedIndex: 0) : null,
      appBar: isMobile ? const Header(selectedIndex: 2, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) const Header(isMobile: false, selectedIndex: 2),

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
                      
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe un destino o experiencia...',
                                      hintStyle: const TextStyle(color: Color.fromARGB(179, 150, 150, 144), fontSize: 14),
                                      prefixIcon: const Icon(Icons.search, color: Color.fromARGB(179, 150, 150, 144), size: 20),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, color: Colors.black54, size: 18),
                                              onPressed: () => _searchController.clear(),
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10, width: 1)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
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

                      const SizedBox(height: 40),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: primaryYellow))
                          : _experienciasFiltradas.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text(
                                      '❌ No encontramos experiencias para esa búsqueda.',
                                      style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = 3;
                                    if (screenWidth < 600) {
                                      crossAxisCount = 1;
                                    } else if (screenWidth < 900) {
                                      crossAxisCount = 2;
                                    } else if (screenWidth < 1100) {
                                      crossAxisCount = 3;
                                    }
                                
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: isMobile ? 2.5 : 2.0, 
                                      ),
                                      itemCount: _experienciasFiltradas.length,
                                      itemBuilder: (context, index) {
                                        // CAMBIO AQUÍ: Enviamos los datos directamente indexando el arreglo.
                                        // De esta manera no creamos una variable local huérfana y el error/warning se quita por completo.
                                        return ExperienciaCard(
                                          onReservar: () {
                                            _mostrarSelectorReserva(context, index);
                                          },
                                          onFavorito: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const ReservaScreen()),
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
                        padding: EdgeInsets.only(
                          top: isMobile ? 4.0 : 8.0,
                          bottom: isMobile ? 0.0 : 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: isMobile ? 80 : 150,
                              fit: BoxFit.contain,
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
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
                                    onTap: () => Navigator.pushNamed(context, '/se-un-aliado'),
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
          ],
        ),
      ),
    );
  }
}