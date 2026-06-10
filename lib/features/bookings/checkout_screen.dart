import 'package:flutter/material.dart';
import 'booking_controller.dart';
import '../../widgets/header.dart'; 

class CheckoutScreen extends StatefulWidget {
  // VARIABLES SUELTAS PARA INDEPENDIZARSE DEL MODELO HOTEL
  final String id;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String imagenUrl;
  final DateTimeRange dates;
  final int huespedes;
  final bool esExperiencia;

  const CheckoutScreen({
    super.key,
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.imagenUrl,
    required this.dates,
    required this.huespedes,
    required this.esExperiencia,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _bookingController = BookingController();
  bool _isProcessing = false;
  String _metodoSeleccionado = 'PayPal';

  // --- FUNCIÓN ACTIVA QUE EJECUTA LA RESERVA REAL ---
  void _finalizarReserva() async {
    setState(() => _isProcessing = true);

    // Ejecutamos la lógica usando las variables directas del widget
    final exito = await _bookingController.procesarReserva(
      hotelId: widget.id,
      inicio: widget.dates.start,
      fin: widget.dates.end,
      huespedes: widget.huespedes,
      precioBasePorNoche: widget.precio,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      
      if (exito) {
        showDialog(
          context: context,
          barrierDismissible: false, 
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              '🎉 ¡Reserva Confirmada!',
              style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Tu reserva en ${widget.nombre} ha sido agendada con éxito.\n'
              'Método utilizado: $_metodoSeleccionado.',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo modal
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red, 
            behavior: SnackBarBehavior.floating,
            content: Text('❌ Las fechas seleccionadas ya no están disponibles o hubo un error.'),
          ),
        );
      }
    }
  }

  /// Retorna la imagen enviada o la de respaldo si viene en blanco (como las experiencias de prueba)
  String _obtenerImagenSegura() {
    if (widget.imagenUrl.isNotEmpty) {
      return widget.imagenUrl;
    }
    return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800';
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el factor de multiplicación del cobro
    final int nochesOPersonas = widget.dates.end.difference(widget.dates.start).inDays;
    
    // Si es experiencia se calcula por número de personas, si es alojamiento por cantidad de noches
    final double total = widget.esExperiencia 
        ? widget.precio * widget.huespedes 
        : (nochesOPersonas == 0 ? 1 : nochesOPersonas) * widget.precio;

    final bool esMovil = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(esMovil ? kToolbarHeight : 70.0),
        child: Header(
          selectedIndex: 4, 
          isMobile: esMovil,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Completa tu reserva',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 45),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: esMovil ? 20 : 120),
              child: Flex(
                direction: esMovil ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // COLUMNA IZQUIERDA: VISUALIZACIÓN
                  Expanded(
                    flex: esMovil ? 0 : 1,
                    child: Container(
                      height: esMovil ? 250 : 580,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: NetworkImage(_obtenerImagenSegura()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: esMovil ? 0 : 50, height: esMovil ? 24 : 0),

                  // COLUMNA DERECHA: FORMULARIOS DE DETALLE Y FACTURACIÓN
                  Expanded(
                    flex: esMovil ? 0 : 1,
                    child: Column(
                      children: [
                        _buildServicioCard(nochesOPersonas),
                        const SizedBox(height: 24),
                        _buildPasarelaCard(total),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60), 
          ],
        ),
      ),
    );
  }

  Widget _buildServicioCard(int noches) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.nombre,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.precio.toInt()}\$',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Text(
                widget.esExperiencia ? ' / persona' : ' / noche', 
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFechaBox('Check-in', '${widget.dates.start.day}/${widget.dates.start.month}/${widget.dates.start.year}'),
              const SizedBox(width: 16),
              _buildFechaBox('Check-out', '${widget.dates.end.day}/${widget.dates.end.month}/${widget.dates.end.year}'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.esExperiencia ? 'Cantidad de personas' : 'Huéspedes', 
            style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.huespedes}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPasarelaCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pasarela de pago',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 16),
          Text(
            'Total a cobrar: \$${total.toInt()}',
            style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _metodoSeleccionado,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black87),
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontFamily: 'Montserrat'),
                  onChanged: _isProcessing 
                      ? null 
                      : (String? nuevoMetodo) {
                          if (nuevoMetodo != null) {
                            setState(() {
                              _metodoSeleccionado = nuevoMetodo;
                            });
                          }
                        },
                  items: <String>['PayPal', 'Tarjeta de Crédito', 'Transferencia']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_metodoSeleccionado == 'PayPal') ...[
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xffFFD200),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Buy with ', style: TextStyle(color: Color(0xff003087), fontWeight: FontWeight.bold, fontSize: 15)),
                    Transform.translate(
                      offset: const Offset(0, -1),
                      child: const Text(
                        'Pay',
                        style: TextStyle(color: Color(0xff003087), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 19),
                      ),
                    ),
                    const Text(
                      'Pal',
                      style: TextStyle(color: Color(0xff0079C1), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 19),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          _isProcessing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : ElevatedButton(
                  onPressed: _finalizarReserva, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff141811),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                    _metodoSeleccionado == 'PayPal' ? 'Reservar' : 'Pagar con $_metodoSeleccionado',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFechaBox(String titulo, String fecha) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(fecha, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}