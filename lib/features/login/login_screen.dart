import 'package:flutter/material.dart';
import 'login_controller.dart'; 
import '../../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _controller = LoginController();  // ← nueva instancia

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();  // ← limpiar controlador
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await _controller.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      body: Row(
        children: [
          Expanded (
            child: Container( 
              child:Stack(
                children: [
                  SizedBox.expand(
                  child: Image.asset('assets/imageninicio.png', 
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6, 
                child: Image.asset('assets/Logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              ),
            ],
          ),
        ),
      ),

                  Expanded(
                    child: SafeArea(
                      child: Stack(
                      children: [
                        // 1. El botón "X" posicionado arriba a la derecha
                        Positioned(
                          top: 16,  // Margen superior
                          right: 24, // Margen derecho
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.pop(context); // Regresa a la HomeScreen
                            },
                          ),
                        ),
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        key: const ValueKey('from_padding'),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                              '¿Pa\'onde vamos hoy?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                letterSpacing: -1.5,
                    ),
                  ),
                  

                  const SizedBox(height: 48),

                  // Campo correo
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: const TextStyle(color: Color(0xffA1A89B)),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xffA1A89B)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xff333D2E)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffE2E600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Color(0xffA1A89B)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xffA1A89B)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xff333D2E)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffE2E600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón de Ingresar con estado de carga (modificado)
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, child) {
                      if (_controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffE2E600),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Acceder', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  TextButton(
                    onPressed: () {
                      // Aquí luego rediriges a RegisterScreen (cuando exista)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pantalla de registro en construcción')),
                      );
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(color: Color(0xffE2E600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
                      ],
                    ), 
                  ),
                  ), 
        ],
      ),
    );
  }
}