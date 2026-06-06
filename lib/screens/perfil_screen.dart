import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/header.dart'; // Ajusta la ruta según tu proyecto
import '../../widgets/drawer.dart'; // Ajusta la ruta según tu proyecto
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _estadoController = TextEditingController();
  final _municipioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // Variable para controlar la visibilidad de la contraseña
  bool _obscurePassword = true;

  // Variable para guardar el correo original y saber si cambió
  String _correoOriginal = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _estadoController.dispose();
    _municipioController.dispose();
    super.dispose();
  }

  // Carga los datos actuales guardados en Firestore
  Future<void> _cargarDatosUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _nombreController.text = data?['nombre'] ?? '';
            _apellidoController.text = data?['apellido'] ?? '';

            _correoOriginal = data?['correo'] ?? user.email ?? '';
            _emailController.text = _correoOriginal;

            _estadoController.text = data?['estado'] ?? '';
            _municipioController.text = data?['municipio'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  // Guarda las modificaciones en Firebase
  Future<void> _handleActualizar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final nuevoCorreo = _emailController.text.trim();
          bool requiereReautenticacion = false;

          // 1. SI EL CORREO FUE MODIFICADO
          if (nuevoCorreo != _correoOriginal) {
            try {
              await user.verifyBeforeUpdateEmail(nuevoCorreo);
              requiereReautenticacion = true;
            } on FirebaseAuthException catch (authError) {
              if (authError.code == 'requires-recent-login') {
                throw 'Por seguridad, necesitas iniciar sesión de nuevo antes de cambiar tu correo.';
              }
              rethrow;
            }
          }

          // 2. SI LA CONTRASEÑA FUE MODIFICADA
          if (_passwordController.text.trim().isNotEmpty) {
            if (_passwordController.text.trim().length >= 6) {
              await user.updatePassword(_passwordController.text.trim());
            }
          }

          // 3. ACTUALIZAR EN FIRESTORE
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .update({
                'nombre': _nombreController.text.trim(),
                'apellido': _apellidoController.text.trim(),
                'correo': nuevoCorreo,
                'estado': _estadoController.text.trim(),
                'municipio': _municipioController.text.trim(),
              });

          _correoOriginal = nuevoCorreo;

          if (mounted) {
            if (requiereReautenticacion) {
              // Avisamos al usuario que el cambio requiere una nueva sesión obligatoria
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se ha enviado un enlace a tu nuevo correo. Para aplicar los cambios, inicia sesión nuevamente.'),
                  duration: Duration(seconds: 4),
                ),
              );

              // Esperamos 3 segundos para que lea el SnackBar y lo sacamos inmediatamente de la app
              await Future.delayed(const Duration(seconds: 3));
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            } else {
              // Si solo cambió nombre/apellido/estado, no lo deslogueamos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Información actualizada correctamente.')),
              );
              _passwordController.clear();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  // Muestra un modal elegante para confirmar el cierre de sesión
  Future<void> _confirmarCerrarSesion() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(
            0xff252B20,
          ), // Fondo a juego con tus inputs
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas salir de tu cuenta?',
            style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancelar
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Cierra el diálogo
                await FirebaseAuth.instance
                    .signOut(); // Cierra sesión en Firebase
                if (context.mounted) {
                  // Te redirige al login borrando el historial de navegación previa
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Salir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      drawer: isMobile ? const CustomDrawer(selectedIndex: 5) : null,
      appBar: isMobile ? const Header(selectedIndex: 5, isMobile: true) : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE2E600)),
            )
          : Column(
              children: [
                if (!isMobile) const Header(selectedIndex: 5, isMobile: false),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'Editar mi información',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Fila: Nombre y Apellido
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      'Nombre:',
                                      _nombreController,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildTextField(
                                      'Apellido:',
                                      _apellidoController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Correo
                              _buildTextField(
                                'Correo:',
                                _emailController,
                                isEmail: true,
                              ),
                              const SizedBox(height: 20),

                              // Contraseña con botón Ojo
                              _buildTextField(
                                'Contraseña:',
                                _passwordController,
                                obscureText: _obscurePassword,
                                requiered: false,
                                isPassword: true,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              const SizedBox(height: 25),

                              const Center(
                                child: Text(
                                  '¿Dónde estás?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Fila: Estado y Municipio
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      'Estado:',
                                      _estadoController,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildTextField(
                                      'Municipio:',
                                      _municipioController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Botón "Actualizar"
                              _isSaving
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFE2E600),
                                      ),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: _handleActualizar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFE2E600,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Actualizar',
                                          style: TextStyle(
                                            color: Color(0xff1A1F16),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ),

                              const SizedBox(
                                height: 15,
                              ), // Separación entre botones
                              // NUEVO: Botón "Cerrar sesión" de estilo sutil y limpio
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: _confirmarCerrarSesion,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cerrar sesión',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xff1A1F16),
                    border: Border(
                      top: BorderSide(color: Color(0xFFE2E600), width: 2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/Logo.png', width: 90),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Sobre Nosotros',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Se un Aliado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Ayuda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Constructor modular adaptado
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool isEmail = false,
    bool requiered = true,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
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
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (requiered && (value == null || value.trim().isEmpty)) {
              return 'Campo obligatorio';
            }
            if (isEmail && value!.isNotEmpty && !value.contains('@')) {
              return 'Ingresa un correo válido';
            }
            if (isPassword && value!.isNotEmpty && value.length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff252B20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
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
