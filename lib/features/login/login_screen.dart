import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto que escriba el usuario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1A1F16), // Verde oscuro de tu Figma
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo de la App estilo Figma
                  const Text(
                    'pa\'onde',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffE2E600), // Amarillo de tu Figma
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Plataforma de Turismo Low-Cost y Sostenible',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xffA1A89B)),
                  ),
                  const SizedBox(height: 48),

                  // Campo de Correo Electrónico
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: const TextStyle(color: Color(0xffA1A89B)),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xffA1A89B)),
                      // Borde cuando la caja no está seleccionada
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xff333D2E)),
                      ),
                      // Borde cuando el usuario hace clic para escribir (se ilumina en amarillo)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffE2E600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo de Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Oculta la clave con puntitos
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}