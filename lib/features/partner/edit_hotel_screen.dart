import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditHotelScreen extends StatefulWidget {
  final String hotelId;
  const EditHotelScreen({super.key, required this.hotelId});

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _capacidadController = TextEditingController();
  File? _imagenSeleccionada;
  bool _isLoading = true;
  bool _saving = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('hoteles')
          .doc(widget.hotelId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _nombreController.text = data['nombre'] ?? '';
        _descripcionController.text = data['descripcion'] ?? '';
        _precioController.text = (data['precioPorNoche'] ?? 0).toString();
        _ubicacionController.text = data['ubicacion'] ?? '';
        _capacidadController.text = (data['capacidad'] ?? 0).toString();
        _currentImageUrl = data['imagenUrl'] ?? '';
      }
    } catch (e) {
      debugPrint('Error cargando hotel: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenSeleccionada = File(pickedFile.path));
    }
  }

  Future<String?> _subirNuevaImagen(String hotelId) async {
    if (_imagenSeleccionada == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('hoteles')
          .child('$hotelId.jpg');
      await ref.putFile(_imagenSeleccionada!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      String? imagenUrl = _currentImageUrl;
      if (_imagenSeleccionada != null) {
        imagenUrl = await _subirNuevaImagen(widget.hotelId);
      }

      await FirebaseFirestore.instance
          .collection('hoteles')
          .doc(widget.hotelId)
          .update({
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precioPorNoche': double.parse(_precioController.text.trim()),
        'ubicacion': _ubicacionController.text.trim(),
        'capacidad': int.parse(_capacidadController.text.trim()),
        'imagenUrl': imagenUrl ?? '',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel actualizado correctamente')),
        );
        Navigator.pop(context, true); // regresa con resultado true
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Hotel'),
        backgroundColor: const Color(0xff1A1F16),
        foregroundColor: const Color(0xffE2E600),
      ),
      backgroundColor: const Color(0xff1A1F16),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen actual o nueva
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xff2A2E24),
                    borderRadius: BorderRadius.circular(12),
                    image: _imagenSeleccionada != null
                        ? DecorationImage(image: FileImage(_imagenSeleccionada!), fit: BoxFit.cover)
                        : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                            ? DecorationImage(image: NetworkImage(_currentImageUrl!), fit: BoxFit.cover)
                            : null),
                  ),
                  child: (_imagenSeleccionada == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50, color: Color(0xffA1A89B)),
                              SizedBox(height: 8),
                              Text('Toca para cambiar la imagen', style: TextStyle(color: Color(0xffA1A89B))),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(_nombreController, 'Nombre del hotel', Icons.business),
              const SizedBox(height: 16),
              _buildTextField(_descripcionController, 'Descripción', Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_precioController, 'Precio por noche (USD)', Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_ubicacionController, 'Ubicación', Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(_capacidadController, 'Capacidad (personas)', Icons.people, keyboardType: TextInputType.number),

              const SizedBox(height: 32),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE2E600),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffA1A89B)),
        prefixIcon: Icon(icon, color: const Color(0xffA1A89B)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff333D2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffE2E600)),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
    );
  }
}