// lib/features/partner/partner_register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerRegisterScreen extends StatefulWidget {
  const PartnerRegisterScreen({super.key});

  @override
  State<PartnerRegisterScreen> createState() => _PartnerRegisterScreenState();
}

class _PartnerRegisterScreenState extends State<PartnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _companyController = TextEditingController();
  final _rifController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _stateController = TextEditingController();
  final _municipioController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _companyController.dispose();
    _rifController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _stateController.dispose();
    _municipioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Guardar datos adicionales en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'companyName': _companyController.text.trim(),
          'rif': _rifController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'state': _stateController.text.trim(),
          'municipio': _municipioController.text.trim(),
          'address': _addressController.text.trim(),
          'role': 'partner',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Redirigir al Dashboard del aliado (lo crearemos después)
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/partner-dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrarse. Intente de nuevo.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión. Verifique su internet.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      appBar: AppBar(
        title: const Text('Registro de Aliado'),
        backgroundColor: const Color(0xff1A1F16),
        foregroundColor: const Color(0xffE2E600),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Regístrate como Aliado',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffE2E600),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa tus datos para comenzar a publicar tus servicios',
                  style: TextStyle(color: Color(0xffA1A89B), fontSize: 14),
                ),
                const SizedBox(height: 32),

                _buildTextField(_companyController, 'Nombre de la Compañía', Icons.business),
                const SizedBox(height: 16),
                _buildTextField(_rifController, 'RIF', Icons.numbers),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, 'Nro de Teléfono', Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'Correo Electrónico', Icons.email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Contraseña', Icons.lock, obscure: true),
                const SizedBox(height: 16),
                _buildTextField(_stateController, 'Estado', Icons.location_on),
                const SizedBox(height: 16),
                _buildTextField(_municipioController, 'Municipio', Icons.location_city),
                const SizedBox(height: 16),
                _buildTextField(_addressController, 'Dirección', Icons.home),

                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffE2E600),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Registrarse', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                  child: const Text('¿Ya tienes una cuenta? Inicia Sesión', style: TextStyle(color: Color(0xffE2E600))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
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