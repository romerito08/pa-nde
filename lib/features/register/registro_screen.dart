import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Envolvemos todo el cuerpo en un Stack global
      body: Stack(
        children: [
          // 1. El diseño base de pantalla dividida (va al fondo)
          Row(
            children: [
              // COLUMNA IZQUIERDA: Imagen del mapa + LOGO PA'ONDE encima
              Expanded(
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
              
              // COLUMNA DERECHA: El Formulario
              Expanded(
                child: Container(
                  color: const Color(0xff1A1F16), 
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título Centrado
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
                              Expanded(child: _buildTextField('Nombre:')),
                              const SizedBox(width: 20),
                              Expanded(child: _buildTextField('Apellido:')),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Correo
                          _buildTextField('Correo:'),
                          const SizedBox(height: 20),
                          
                          // Contraseña
                          _buildTextField('Contraseña:'),
                          const SizedBox(height: 15),
                          
                          // Texto pequeño de ubicación
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
                              Expanded(child: _buildTextField('Estado:')),
                              const SizedBox(width: 20),
                              Expanded(child: _buildTextField('Municipio:')),
                            ],
                          ),
                          const SizedBox(height: 35),
                          
                          // Botón Registrarse Amarillo Figma
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {},
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
                                    Navigator.push(
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
            ],
          ),

          // 2. Botón global para cerrar (Al estar fuera del Row, se ubica respecto a TODA LA PANTALLA)
          Positioned(
            top: 24,    // Margen superior de la pantalla
            right: 24,  // Margen derecho absoluto de la pantalla
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context); // Regresa a la HomeScreen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
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
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff333D2E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}