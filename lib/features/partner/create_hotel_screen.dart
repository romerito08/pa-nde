import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CreateHotelScreen extends StatefulWidget {
  const CreateHotelScreen({super.key});

  @override
  State<CreateHotelScreen> createState() => _CreateHotelScreenState();
}

class _CreateHotelScreenState extends State<CreateHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _capacidadController = TextEditingController();
  File? _imagenSeleccionada;
  bool _isLoading = false;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<String?> _subirImagen(String hotelId) async {
    if (_imagenSeleccionada == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('hoteles')
          .child('$hotelId.jpg');
      await ref.putFile(_imagenSeleccionada!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _guardarHotel() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión como aliado')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Primero, creamos un documento temporal para obtener el ID
      final docRef = FirebaseFirestore.instance.collection('hoteles').doc();
      final hotelId = docRef.id;

      // Subir imagen si la hay
      String? imagenUrl;
      if (_imagenSeleccionada != null) {
        imagenUrl = await _subirImagen(hotelId);
      }

      // Guardar datos en Firestore
      await docRef.set({
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precioPorNoche': double.parse(_precioController.text.trim()),
        'ubicacion': _ubicacionController.text.trim(),
        'capacidad': int.parse(_capacidadController.text.trim()),
        'imagenUrl': imagenUrl ?? '',
        'calificacionPromedio': 0.0,
        'creadoPor': user.uid,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel publicado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Nuevo Hotel'),
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
              // Imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xff2A2E24),
                    borderRadius: BorderRadius.circular(12),
                    image: _imagenSeleccionada != null
                        ? DecorationImage(image: FileImage(_imagenSeleccionada!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imagenSeleccionada == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50, color: Color(0xffA1A89B)),
                              SizedBox(height: 8),
                              Text('Toca para seleccionar una imagen', style: TextStyle(color: Color(0xffA1A89B))),
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
              _buildTextField(_precioController, 'Precio por noche (USD)', Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_ubicacionController, 'Ubicación', Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(_capacidadController, 'Capacidad (personas)', Icons.people,
                  keyboardType: TextInputType.number),

              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _guardarHotel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE2E600),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Publicar Hotel', style: TextStyle(fontWeight: FontWeight.bold)),
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