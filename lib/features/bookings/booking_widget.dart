import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import 'checkout_screen.dart'; // Importación verificada

class BookingWidget extends StatefulWidget {
  final Hotel? hotel; 
  final String? idManual;
  final String? nombreManual;
  final double? precioManual;
  final int? capacidadManual;
  final bool esExperiencia; 

  // Constructor para Hoteles
  const BookingWidget({
    super.key, 
    required this.hotel,
  })  : idManual = null,
        nombreManual = null,
        precioManual = null,
        capacidadManual = null,
        esExperiencia = false;

  // Constructor para Experiencias
  const BookingWidget.experiencia({
    super.key,
    required String id,
    required String nombre,
    required double precio,
    int capacidadMaxima = 10,
  })  : hotel = null,
        idManual = id,
        nombreManual = nombre,
        precioManual = precio,
        capacidadManual = capacidadMaxima,
        esExperiencia = true;

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  DateTimeRange? _selectedDateRange;
  int _huespedes = 2;

  // Getters seguros adaptados para evitar errores de sintaxis o valores nulos
  String get _id {
    if (widget.esExperiencia) return widget.idManual ?? '';
    return widget.hotel?.id ?? '';
  }

  String get _nombre {
    if (widget.esExperiencia) return widget.nombreManual ?? 'Experiencia';
    return widget.hotel?.nombre ?? '';
  }

  double get _precio {
    if (widget.esExperiencia) return widget.precioManual ?? 0.0;
    return widget.hotel?.precioPorNoche.toDouble() ?? 0.0;
  }

  int get _capacidad {
    if (widget.esExperiencia) return widget.capacidadManual ?? 10;
    return widget.hotel?.capacidad ?? 1;
  }

  String get _imagenUrl {
    if (widget.esExperiencia) return '';
    return widget.hotel?.imagenUrl ?? '';
  }

  String get _ubicacion {
    if (widget.esExperiencia) return 'Experiencia';
    return widget.hotel?.ubicacion ?? '';
  }

  void _seleccionarFechas() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      confirmText: 'SELECCIONAR',
      saveText: 'ACEPTAR',
      helpText: 'Reserva tus fechas en Pa\'onde',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xffE2E600),         
              onPrimary: Colors.black,            
              surface: Colors.white,              
              onSurface: Colors.black87,          
              secondary: Color(0xffE2E600), 
              primaryContainer: Color(0xffFDFEE0), 
              onPrimaryContainer: Colors.black87,
            ),  
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,      
              foregroundColor: Colors.black87,    
              elevation: 0,                       
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffE2E600), 
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
              ),
            ), 
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // Redirección limpia enviando los parámetros mapeados de forma segura
  void _confirmarReserva() {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📅 Por favor, selecciona las fechas de estadía.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          id: _id,
          nombre: _nombre,
          ubicacion: _ubicacion,
          precio: _precio,
          imagenUrl: _imagenUrl,
          dates: _selectedDateRange!,
          huespedes: _huespedes,
          esExperiencia: widget.esExperiencia,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color brandYellow = const Color(0xffE2E600);
    final tieneFechas = _selectedDateRange != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15), 
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_precio.toInt()}\$',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Montserrat'),
              ),
              Text(
                widget.esExperiencia ? ' / persona' : ' / noche', 
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),

          InkWell(
            onTap: _seleccionarFechas,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check-in', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45)),
                        const SizedBox(height: 4),
                        Text(
                          tieneFechas ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year}' : 'dd/mm/aaaa',
                          style: TextStyle(fontSize: 14, color: tieneFechas ? Colors.black87 : Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check-out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45)),
                        const SizedBox(height: 4),
                        Text(
                          tieneFechas ? '${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}' : 'dd/mm/aaaa',
                          style: TextStyle(fontSize: 14, color: tieneFechas ? Colors.black87 : Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.esExperiencia ? 'Personas' : 'Huéspedes', 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _huespedes > 1 ? () => setState(() => _huespedes--) : null,
                  icon: const Icon(Icons.remove, size: 18, color: Colors.black87),
                ),
                Text('$_huespedes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                IconButton(
                  onPressed: _huespedes < _capacidad ? () => setState(() => _huespedes++) : null,
                  icon: const Icon(Icons.add, size: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: const [
              BorderBackgroundCircle(),
              SizedBox(width: 8),
              Text(
                'Disponible',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _confirmarReserva,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: brandYellow,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reservar ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(color: Colors.black87, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: Colors.black87,
            ),
            child: const Text('Solicitar una cotización', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class BorderBackgroundCircle extends StatelessWidget {
  const BorderBackgroundCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );
  }
}