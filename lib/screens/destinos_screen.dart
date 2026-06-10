import 'package:flutter/material.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
import '../widgets/destino_card.dart';

class DestinoScreen extends StatefulWidget {
  const DestinoScreen({super.key});

  @override
  State<DestinoScreen> createState() => _DestinoScreenState();
}

class _DestinoScreenState extends State<DestinoScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Lista COMPLETA de los 24 estados de Venezuela para la cuadrícula
  final List<Map<String, String>> _todosLosEstados = [
    {
      'estado': 'Amazonas', 
      'imagenUrl': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Anzoátegui', 
      'imagenUrl': 'https://images.unsplash.com/photo-1597200381847-30ec200eeb9a?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Apure', 
      'imagenUrl': 'https://images.unsplash.com/photo-1610123598147-f632aa18b275?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Aragua', 
      'imagenUrl': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Barinas', 
      'imagenUrl': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Bolívar', 
      'imagenUrl': 'https://images.unsplash.com/photo-1628155930542-3c7a64e2c833?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Carabobo', 
      'imagenUrl': 'https://images.unsplash.com/photo-1580137189272-c9379f8864fd?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Cojedes', 
      'imagenUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Delta Amacuro', 
      'imagenUrl': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Distrito Capital', 
      'imagenUrl': 'https://images.unsplash.com/photo-1590439491754-080c55711670?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Falcón', 
      'imagenUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Guárico', 
      'imagenUrl': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Lara', 
      'imagenUrl': 'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Mérida', 
      'imagenUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Miranda', 
      'imagenUrl': 'https://images.unsplash.com/photo-1433832565846-527241675ba8?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Monagas', 
      'imagenUrl': 'https://images.unsplash.com/photo-1511497584788-876760111969?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Nueva Esparta', 
      'imagenUrl': 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Portuguesa', 
      'imagenUrl': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Sucre', 
      'imagenUrl': 'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Táchira', 
      'imagenUrl': 'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Trujillo', 
      'imagenUrl': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'La Guaira', 
      'imagenUrl': 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Yaracuy', 
      'imagenUrl': 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?q=80&w=600&auto=format&fit=crop'
    },
    {
      'estado': 'Zulia', 
      'imagenUrl': 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?q=80&w=600&auto=format&fit=crop'
    },
  ];

  List<Map<String, String>> _estadosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _estadosFiltrados = _todosLosEstados;
    _searchController.addListener(_filtrarEstados);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarEstados() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _estadosFiltrados = _todosLosEstados;
      } else {
        _estadosFiltrados = _todosLosEstados.where((item) {
          final estadoNombre = item['estado']!.toLowerCase();
          return estadoNombre.contains(query);
        }).toList();
      }
    });
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
      appBar: isMobile ? const Header(selectedIndex: 3, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) const Header(isMobile: false, selectedIndex: 3),

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
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText: 'Busca un estado de Venezuela...',
                                      hintStyle: const TextStyle(
                                        color: Color.fromARGB(179, 150, 150, 144),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Color.fromARGB(179, 150, 150, 144),
                                        size: 20,
                                      ),
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
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10)),
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

                      _estadosFiltrados.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  '❌ No encontramos ese estado. ¡Prueba con otro!',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
                                    childAspectRatio: isMobile ? 1.8 : 1.5,
                                  ),
                                  itemCount: _estadosFiltrados.length,
                                  itemBuilder: (context, index) {
                                    return DestinoCard(
                                      estado: _estadosFiltrados[index]['estado']!,
                                      imagenUrl: _estadosFiltrados[index]['imagenUrl']!,
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