import 'package:flutter/material.dart';
import '../services/hotel_service.dart';
import '../models/hotel.dart';

class EditHotelScreen extends StatefulWidget {
  final String hotelId;
  const EditHotelScreen({super.key, required this.hotelId});

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final HotelService _hotelService = HotelService();
  late Future<Hotel?> _hotel;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _ubicacionController;
  late TextEditingController _capacidadController;

  @override
  void initState() {
    super.initState();
    _hotel = _hotelService.getHotelById(widget.hotelId);
    _hotel.then((hotel) {
      if (hotel != null) {
        _nombreController = TextEditingController(text: hotel.nombre);
        _descripcionController = TextEditingController(text: hotel.descripcion);
        _precioController = TextEditingController(text: hotel.precioPorNoche.toString());
        _ubicacionController = TextEditingController(text: hotel.ubicacion);
        _capacidadController = TextEditingController(text: hotel.capacidad.toString());
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _ubicacionController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await _hotelService.updateHotel(widget.hotelId, {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'precioPorNoche': double.parse(_precioController.text),
        'ubicacion': _ubicacionController.text,
        'capacidad': int.parse(_capacidadController.text),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hotel actualizado')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Hotel')),
      body: FutureBuilder<Hotel?>(
        future: _hotel,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  TextFormField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
                  TextFormField(controller: _precioController, decoration: const InputDecoration(labelText: 'Precio por noche'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  TextFormField(controller: _ubicacionController, decoration: const InputDecoration(labelText: 'Ubicación')),
                  TextFormField(controller: _capacidadController, decoration: const InputDecoration(labelText: 'Capacidad'), keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _saveChanges, child: const Text('Guardar Cambios')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}