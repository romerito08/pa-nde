import 'package:flutter/material.dart';

// Modelo simple para los Hoteles
class Hotel {
  final String id;
  final String name;
  final String location;
  final double price;
  final String imageUrl;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.imageUrl,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice para controlar la pestaña activa (0 = Home, 1 = Dashboard)
  int _selectedIndex = 0;

  // Base de datos local temporal de hoteles
  final List<Hotel> _hotels = [
    Hotel(
      id: '1',
      name: 'Resort Vista al Mar',
      location: 'Maldivas',
      price: 250.0,
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=500',
    ),
    Hotel(
      id: '2',
      name: 'Gran Hotel Central',
      location: 'Madrid, España',
      price: 140.0,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
    ),
  ];

  // Controladores para el formulario de nuevo hotel
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // Función para añadir un hotel desde el Dashboard
  void _addHotel() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _hotels.add(
          Hotel(
            id: DateTime.now().toString(),
            name: _nameController.text,
            location: _locationController.text,
            price: double.parse(_priceController.text),
            imageUrl: _imageController.text.isEmpty 
                ? 'https://images.unsplash.com/photo-1540553016722-983e48a2cd10?w=500' 
                : _imageController.text,
          ),
        );
      });
      // Limpiar campos y cerrar teclado
      _nameController.clear();
      _locationController.clear();
      _priceController.clear();
      _imageController.clear();
      FocusScope.of(context).unfocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Hotel agregado con éxito!')),
      );
    }
  }

  // Función para eliminar un hotel
  void _deleteHotel(String id) {
    setState(() {
      _hotels.removeWhere((hotel) => hotel.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de las dos vistas principales
    final List<Widget> views = [
      _buildHomeView(),
      _buildDashboardView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Pa'onde - Explorar" : "Dashboard Admin"),
        backgroundColor: const Color(0xff252C20),
        elevation: 0,
      ),
      body: views[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xff252C20),
        selectedItemColor: const Color(0xff81C784),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio público',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }

  // ================= VISTA 1: HOME PÚBLICO (Cards) =================
  Widget _buildHomeView() {
    if (_hotels.isEmpty) {
      return const Center(child: Text('No hay hoteles disponibles.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _hotels.length,
      itemBuilder: (context, index) {
        final hotel = _hotels[index];
        return Card(
          color: const Color(0xff252C20),
          margin: const EdgeInsets.only(bottom: 16.0),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                hotel.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[800],
                  child: const Icon(Icons.hotel, size: 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                 Shear(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(hotel.location, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hotel.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      maxLines: 1,
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text('Por noche', style: TextStyle(color: Colors.grey)),
                        Text(
                          '\$${hotel.price.toStringAsFixed(0)} USD',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff81C784)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= VISTA 2: DASHBOARD (Gestión) =================
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Añadir Nuevo Hotel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          // Formulario de entrada
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre del Hotel', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingresa la ubicación' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio por noche', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Ingresa el precio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: 'URL de la Imagen (Opcional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addHotel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4CAF50),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Guardar en la App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Hoteles Activos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),

          // Lista de control (para borrar)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hotels.length,
            itemBuilder: (context, index) {
              final hotel = _hotels[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(hotel.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: Colors.grey)),
                ),
                title: Text(hotel.name),
                subtitle: Text('\$${hotel.price}/noche • ${hotel.location}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteHotel(hotel.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}