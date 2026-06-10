import 'package:flutter/material.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/drawer.dart';
import '../models/booking.dart'; 
import '../features/bookings/booking_controller.dart';   
import '../widgets/alojamiento_card.dart'; 
import '../widgets/experiencia_card.dart';

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({super.key});

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final _bookingController = BookingController();
  late Future<List<Booking>> _futureReservas;

  @override
  void initState() {
    super.initState();
    _futureReservas = _bookingController.obtenerReservasUsuario();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff141811); 

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? CustomDrawer(selectedIndex: 4) : null, 
      appBar: isMobile ? Header(selectedIndex: 4, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) Header(isMobile: false, selectedIndex: 4),

            // Banner Principal
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

            // Contenedor principal alineado con los márgenes de la app
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // ==========================================
                  // SECCIÓN 1: MIS RESERVAS (Firestore)
                  // ==========================================
                  _buildTituloSeccion('Mis Reservas', primaryYellow),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Booking>>(
                    future: _futureReservas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: primaryYellow),
                          ),
                        );
                      }
                      final reservas = snapshot.data ?? [];
                      if (reservas.isEmpty) {
                        return _buildEstadoVacio('No tienes reservas confirmadas actualmente.');
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reservas.length,
                        itemBuilder: (context, index) {
                          return _buildTarjetaHorizontal(
                            reserva: reservas[index],
                            esCotizacion: false,
                            primaryYellow: primaryYellow,
                            isMobile: isMobile,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // ==========================================
                  // SECCIÓN 2: COTIZACIONES
                  // ==========================================
                  _buildTituloSeccion('Cotizaciones', primaryYellow),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return _buildTarjetaHorizontal(
                        reserva: Booking(
                          hotelId: 'hotel_mock',
                          usuarioId: 'user_mock',
                          fechaInicio: DateTime.now().add(const Duration(days: 10)),
                          fechaFin: DateTime.now().add(const Duration(days: 15)),
                          huespedes: 2,
                          totalPagar: 200.0,
                        ),
                        esCotizacion: true,
                        primaryYellow: primaryYellow,
                        isMobile: isMobile,
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // ==========================================
                  // SECCIÓN 3: ALOJAMIENTOS GUARDADOS
                  // ==========================================
                  _buildTituloSeccion('Alojamientos guardados', Colors.white),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isMobile ? 2 : 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 0.65 : 0.75, 
                    ),
                    itemBuilder: (context, index) {
                      return IntrinsicHeight(
                        child: AlojamientoCard(
                          hotelId: 'id_hotel_$index',
                          nombre: 'Título del servicio',
                          ubicacion: 'Playa',
                          precio: 50.0,
                          imagenUrl: '', 
                          onReservar: () {},
                          onFavorito: () {},
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // ==========================================
                  // SECCIÓN 4: EXPERIENCIAS GUARDADAS
                  // ==========================================
                  _buildTituloSeccion('Experiencias guardadas', Colors.white),
                  const SizedBox(height: 16),
                  isMobile
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ExperienciaCard(
                                onReservar: () {},
                                onFavorito: () {},
                              ),
                            );
                          },
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, 
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.2,
                          ),
                          itemBuilder: (context, index) {
                            return ExperienciaCard(
                              onReservar: () {},
                              onFavorito: () {},
                            );
                          },
                        ),
                  
                  // Espacio controlado de separación antes del footer
                  const SizedBox(height: 54),

                  // ==========================================
                  // LÍNEA DIVISORIA Y FOOTER ALINEADO
                  // ==========================================
                  const Divider(color: primaryYellow, thickness: 1),
                  Padding(
                    padding: EdgeInsets.only(
                      top: isMobile ? 8.0 : 16.0, 
                      bottom: isMobile ? 16.0 : 32.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/Logo.png', width: isMobile ? 80 : 130, fit: BoxFit.contain),
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
                              SizedBox(width: isMobile ? 10 : 24),
                              Footer(
                                title: 'Sé un Aliado', 
                                isMobile: isMobile, 
                                onTap: () => Navigator.pushNamed(context, '/se-un-aliado'),
                              ),
                              SizedBox(width: isMobile ? 10 : 24),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTituloSeccion(String texto, Color color) {
    return Text(
      texto,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color, fontFamily: 'Montserrat'),
    );
  }

  Widget _buildEstadoVacio(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xff1E241A), borderRadius: BorderRadius.circular(16)),
      child: Center(child: Text(mensaje, style: const TextStyle(color: Colors.white60, fontSize: 14))),
    );
  }

  Widget _buildTarjetaHorizontal({
    required Booking reserva,
    required bool esCotizacion,
    required Color primaryYellow,
    required bool isMobile,
  }) {
    String txtInicio = "${reserva.fechaInicio.day.toString().padLeft(2, '0')}/${reserva.fechaInicio.month.toString().padLeft(2, '0')}/${reserva.fechaInicio.year}";
    String txtFin = "${reserva.fechaFin.day.toString().padLeft(2, '0')}/${reserva.fechaFin.month.toString().padLeft(2, '0')}/${reserva.fechaFin.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isMobile ? double.infinity : 240,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/Encabezado.png'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20, height: 16),
                Expanded(
                  flex: isMobile ? 0 : 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Playa', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Título del servicio',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Descripción del servicio que se está presentando aquí.',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: primaryYellow, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Total:  \$${reserva.totalPagar.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20, height: 16),
                Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Color(0xffFFD200), size: 16),
                        Icon(Icons.star, color: Color(0xffFFD200), size: 16),
                        Icon(Icons.star, color: Color(0xffFFD200), size: 16),
                        Icon(Icons.star, color: Color(0xffFFD200), size: 16),
                        Icon(Icons.star, color: Color(0xffFFD200), size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildBloqueFecha('Check-in', txtInicio),
                        const SizedBox(width: 8),
                        _buildBloqueFecha('Check-out', txtFin),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('${reserva.huespedes} Huéspedes', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xff141811), 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Enviar un mensaje',
                          style: TextStyle(color: primaryYellow, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffD1D1D1), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          esCotizacion ? 'Reservar' : 'Escribir una reseña',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBloqueFecha(String titulo, String fecha) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xffEAEAEA), borderRadius: BorderRadius.circular(8)),
          child: Text(fecha, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
        )
      ],
    );
  }
}