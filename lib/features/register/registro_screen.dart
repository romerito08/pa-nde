import 'package:flutter/material.dart';
import '../login/login_controller.dart'; // ← ruta correcta al controller
import '../../screens/inicio_screen.dart'; // ← para redirigir tras registro
import '../../screens/home_screen.dart';   // ← si se necesita en algún lado (por el botón cerrar)
import '../login/login_screen.dart';       // ← corregido: import de LoginScreen

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _estadoController = TextEditingController();
  final _municipioController = TextEditingController();
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _estadoController.dispose();
    _municipioController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        estado: _estadoController.text.trim(),
        municipio: _municipioController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.errorMessage ?? 'Error al registrar usuario')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // COLUMNA IZQUIERDA: Imagen del mapa + LOGO PA'ONDE
              Expanded(
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: Image.asset(
                        'assets/imageninicio.png', 
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.6, 
                        child: Image.asset(
                          'assets/Logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // COLUMNA DERECHA: El Formulario envuelto en el widget Form
              Expanded(
                child: Container(
                  color: const Color(0xff1A1F16), 
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                '¿Listo para saber\npa’onde vas?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Fila: Nombre y Apellido
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Nombre:', _nombreController)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildTextField('Apellido:', _apellidoController)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Correo
                            _buildTextField('Correo:', _emailController, isEmail: true),
                            const SizedBox(height: 20),
                            
                            // Contraseña
                            _buildTextField('Contraseña:', _passwordController, obscureText: true),
                            const SizedBox(height: 15),
                            
                            const Center(
                              child: Text(
                                '¿Dónde estás? Encuentra lo mejor de tu zona.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Fila: Estado y Municipio
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Estado:', _estadoController)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildTextField('Municipio:', _municipioController)),
                              ],
                            ),
                            const SizedBox(height: 35),
                            
                            // Botón Registrarse
                            ListenableBuilder(
                              listenable: _controller,
                              builder: (context, child) {
                                if (_controller.isLoading) {
                                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE2E600)));
                                }
                                return SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE2E600),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        color: Color(0xff1A1F16),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 25),
                            
                            // Enlace inferior "Ya tienes cuenta?"
                            Center(
                              child: Column(
                                children: [
                                  const Text(
                                    '¿Ya tienes una cuenta?',
                                    style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Montserrat'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        color: Color(0xFFE2E600),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Botón global para cerrar
          Positioned(
            top: 24,    
            right: 24,  
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    bool obscureText = false, 
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obligatorio';
            }
            if (isEmail && !value.contains('@')) {
              return 'Ingresa un correo válido';
            }
            if (obscureText && value.length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff333D2E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            errorStyle: const TextStyle(color: Colors.redAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}