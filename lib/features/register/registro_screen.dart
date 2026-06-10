import 'package:flutter/material.dart';
import '../login/login_controller.dart'; // ← Ruta correcta al controller
import '../../screens/inicio_screen.dart'; // ← Para redirigir tras registro
import '../../screens/home_screen.dart';   // ← Si se necesita en algún lado (por el botón cerrar)
import '../login/login_screen.dart';       // ← Corregido: import de LoginScreen

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

  /// Despacha la petición de registro hacia el controlador unificado
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
          SnackBar(
            content: Text(_controller.errorMessage ?? 'Error al registrar usuario'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 850; // Umbral de quiebre adaptativo para Web/Móvil
    
    const Color primaryYellow = Color(0xFFE2E600);
    const Color bgColor = Color(0xff1A1F16);

    // --- CÁPSULA DE CONTENIDO: FORMULARIO DE REGISTRO ---
    Widget formContent() {
      return Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 60, 
          vertical: 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // Protege el estiramiento en pantallas ultra-wide
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTextField('Nombre:', _nombreController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Apellido:', _apellidoController)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Correo
                    _buildTextField('Correo:', _emailController, isEmail: true),
                    const SizedBox(height: 20),
                    
                    // Contraseña
                    _buildTextField('Contraseña:', _passwordController, obscureText: true),
                    const SizedBox(height: 24),
                    
                    const Center(
                      child: Text(
                        '¿Dónde estás? Encuentra lo mejor de tu zona.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Fila: Estado y Municipio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTextField('Estado:', _estadoController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Municipio:', _municipioController)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
                    // Botón Registrarse (Reactivo a los cambios de estado del controlador)
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, child) {
                        if (_controller.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: primaryYellow),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryYellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Homologado con los formularios de Aliados
                              ),
                            ),
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                color: bgColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Enlace inferior "¿Ya tienes cuenta?"
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            '¿Ya tienes una cuenta?',
                            style: TextStyle(color: Color(0xffA1A89B), fontSize: 13, fontFamily: 'Montserrat'),
                          ),
                          const SizedBox(height: 4),
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
                                color: primaryYellow,
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
      );
    }

    // --- RENDERIZADO ESTRUCTURAL CON CONTROLES RESPONSIVOS ---
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          isMobile 
              ? SizedBox.expand(child: formContent()) // Vista directa en Mobile sin paneles laterales
              : Row(
                  children: [
                    // COLUMNA DECORATIVA IZQUIERDA: Visible solo en pantallas Desktop/PWA Web
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox.expand(
                            child: Image.asset(
                              'assets/imageninicio.png', 
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(color: Colors.black26), // Sombreado sutil
                          Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.5, 
                              child: Image.asset(
                                'assets/Logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // COLUMNA DERECHA: Formulario aislado
                    Expanded(
                      child: formContent(),
                    ),
                  ],
                ),

          // Botón global flotante para cerrar / abortar flujo
          Positioned(
            top: 24,    
            right: 24,  
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                tooltip: 'Regresar al Home',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
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
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obligatorio';
            }
            if (isEmail && !value.contains('@')) {
              return 'Ingresa un correo válido';
            }
            if (obscureText && value.trim().length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff252B20), // Cambiado a la paleta unificada del proyecto (Gris/Verde oliva oscuro)
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff333D2E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff333D2E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E600), width: 1.5), // Foco amarillo institucional
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}