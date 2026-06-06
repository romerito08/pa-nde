import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/hotel_detail_screen.dart';

class PartnerHotelsScreen extends StatelessWidget {
  const PartnerHotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión como aliado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Hoteles'),
        backgroundColor: const Color(0xff1A1F16),
        foregroundColor: const Color(0xffE2E600),
      ),
      backgroundColor: const Color(0xff1A1F16),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hoteles')
            .where('creadoPor', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has publicado ningún hotel.\nPresiona el botón + para crear uno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xffA1A89B)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final hotelId = doc.id;
              final nombre = data['nombre'] ?? 'Sin nombre';
              final ubicacion = data['ubicacion'] ?? 'Sin ubicación';
              final precio = data['precioPorNoche'] ?? 0;
              final imagenUrl = data['imagenUrl'] ?? '';

              return Card(
                color: const Color(0xff1C241B),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelDetailScreen(hotelId: hotelId),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Imagen miniatura
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imagenUrl.isNotEmpty
                              ? Image.network(
                                  imagenUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.broken_image, color: Colors.white54),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.hotel, color: Colors.white54),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Información
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ubicacion,
                                style: const TextStyle(color: Color(0xffA1A89B), fontSize: 12),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$$precio por noche',
                                style: const TextStyle(color: Color(0xffE2E600), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // Botones de acción
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xffE2E600)),
                              onPressed: () {
                                // Navegar a pantalla de edición (la crearemos luego)
                                Navigator.pushNamed(
                                  context,
                                  '/edit-hotel',
                                  arguments: hotelId,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteHotel(context, hotelId),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-hotel');
        },
        backgroundColor: const Color(0xffE2E600),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteHotel(BuildContext context, String hotelId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hotel'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('hoteles').doc(hotelId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hotel eliminado correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}