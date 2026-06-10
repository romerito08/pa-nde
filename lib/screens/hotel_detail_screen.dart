import 'package:flutter/material.dart';
import '../services/hotel_service.dart';
import '../models/hotel.dart';
import '../features/bookings/booking_widget.dart'; 
import '../features/reviews/review_section_widget.dart'; 
// CORRECCIÓN: Importamos tu componente de Header real
import '../widgets/header.dart'; 

class HotelDetailScreen extends StatefulWidget {
  final String hotelId;
  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final HotelService _hotelService = HotelService();
  late Future<Hotel?> _hotelFuture;

  @override
  void initState() {
    super.initState();
    _hotelFuture = _hotelService.getHotelById(widget.hotelId);
  }

  @override
  Widget build(BuildContext context) {
    final Color brandYellow = const Color(0xffE2E600);

    // Evaluamos el ancho de pantalla para pasárselo de forma dinámica a tu Header
    final bool isMobileLayout = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco limpio fiel al diseño original
      
      // =============================================================
      // TU ENRUTADOR DE HEADER GLOBAL INTEGRADO NATIVAMENTE
      // =============================================================
      appBar: Header(
        selectedIndex: 1, // Mantiene activo el botón de "Alojamientos"
        isMobile: isMobileLayout,
      ),

      body: FutureBuilder<Hotel?>(
        future: _hotelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: brandYellow));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Alojamiento no encontrado'));
          }
          final hotel = snapshot.data!;

          return SingleChildScrollView(
            // Padding general alineado para pantallas web
            padding: EdgeInsets.symmetric(
              horizontal: isMobileLayout ? 20 : 80, 
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- RENDER DE IMAGEN PRINCIPAL ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hotel.imagenUrl.isNotEmpty
                      ? Image.network(
                          hotel.imagenUrl,
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 400,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported, size: 48, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 32),

                // --- COMPORTAMIENTO RESPONSIVO DE DOS COLUMNAS ---
                isMobileLayout 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetallesIzquierda(hotel, brandYellow),
                          const SizedBox(height: 42),
                          BookingWidget(hotel: hotel),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // COLUMNA IZQUIERDA: Detalles del Servicio y Opiniones (flex: 3)
                          Expanded(
                            flex: 3,
                            child: _buildDetallesIzquierda(hotel, brandYellow),
                          ),
                          
                          const SizedBox(width: 64), // Canal de separación limpio

                          // COLUMNA DERECHA: Card de reservas funcional (flex: 2)
                          Expanded(
                            flex: 2,
                            child: BookingWidget(hotel: hotel),
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper metodológico para no duplicar la columna de textos entre Mobile y Web
  Widget _buildDetallesIzquierda(Hotel hotel, Color brandYellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel.nombre,
          style: const TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
            const SizedBox(width: 4),
            Text(
              hotel.ubicacion, 
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (index) => Icon(Icons.star, color: brandYellow, size: 18)),
            const SizedBox(width: 6),
            Text(
              '${hotel.calificacionPromedio} (128 reseñas)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          hotel.descripcion,
          style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 40),
        const Divider(height: 1, color: Colors.grey),
        const SizedBox(height: 32),
        
        // Sección reactiva de comentarios vinculada a Firebase
        ReviewSectionWidget(hotelId: hotel.id),
      ],
    );
  }
}