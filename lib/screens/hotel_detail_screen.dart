import 'package:flutter/material.dart';
import '../services/hotel_service.dart';
import '../services/review_service.dart';
import '../models/hotel.dart';
import '../models/review.dart';

class HotelDetailScreen extends StatefulWidget {
  final String hotelId;
  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final HotelService _hotelService = HotelService();
  final ReviewService _reviewService = ReviewService();
  late Future<Hotel?> _hotelFuture;
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 initState: hotelId = ${widget.hotelId}');
    _hotelFuture = _hotelService.getHotelById(widget.hotelId);
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;
    try {
      await _reviewService.addReview(
        hotelId: widget.hotelId,
        calificacion: _selectedRating,
        texto: _commentController.text.trim(),
      );
      _commentController.clear();
      _selectedRating = 5;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentario agregado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Alojamiento')),
      body: FutureBuilder<Hotel?>(
        future: _hotelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Hotel no encontrado'));
          }
          final hotel = snapshot.data!;

          // Creamos el stream SOLO después de que el hotel está cargado
          final Stream<List<Review>> reviewsStream =
              _reviewService.getReviewsForHotel(widget.hotelId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hotel.imagenUrl.isNotEmpty
                      ? Image.network(
                          hotel.imagenUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  hotel.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('📍 ${hotel.ubicacion}'),
                Text('💰 ${hotel.precioPorNoche}\$/noche'),
                Text('👥 Capacidad: ${hotel.capacidad} personas'),
                Text('⭐ Calificación: ${hotel.calificacionPromedio}'),
                const SizedBox(height: 16),
                Text(hotel.descripcion),
                const SizedBox(height: 32),
                const Text(
                  'Comentarios',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Formulario para agregar comentario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Calificación: '),
                            DropdownButton<int>(
                              value: _selectedRating,
                              items: List.generate(5, (i) => i + 1)
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text('$e ⭐'),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedRating = v!),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu comentario...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submitReview,
                          child: const Text('Enviar Comentario'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // StreamBuilder para mostrar los comentarios (con initialData)
                StreamBuilder<List<Review>>(
                  stream: reviewsStream,
                  initialData: const [], 
                  builder: (context, snapshot) {
                    debugPrint(
                        '🔍 StreamBuilder - hotelId: ${widget.hotelId}, data length: ${snapshot.data?.length}, state: ${snapshot.connectionState}, error: ${snapshot.error}');

                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error al cargar comentarios: ${snapshot.error}'));
                    }

                    final reviews = snapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return const Center(
                          child: Text('Aún no hay comentarios. Sé el primero.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final rev = reviews[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                                child: Text(rev.nombreUsuario[0])),
                            title: Text(rev.nombreUsuario),
                            subtitle: Text(rev.texto),
                            trailing: Text('⭐ ${rev.calificacion}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}