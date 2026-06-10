import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/header.dart'; 
import '../../widgets/drawer.dart'; 

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto restantes
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variables para la selección de Estado y Municipio
  String? _estadoSeleccionado;
  String? _municipioSeleccionado;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true;
  String _correoOriginal = '';

  // Data nativa de Estados y Municipios de Venezuela (Simplificada con los principales)
  final Map<String, List<String>> _venezuelaData = {
    'Amazonas': ['Atures', 'Atabapo', 'Maroa', 'Río Negro', 'Autana'],
    'Anzoátegui': ['Barcelona', 'Puerto La Cruz', 'El Tigre', 'Anaco', 'Guanta'],
    'Apure': ['San Fernando', 'Achaguas', 'Biruaca', 'Muñoz', 'Paéz'],
    'Aragua': ['Maracay', 'Turmero', 'La Victoria', 'Cagua', 'El Limón'],
    'Barinas': ['Barinas', 'Bolívar', 'Cruz Paredes', 'Obispos', 'Pedraza'],
    'Bolívar': ['Ciudad Bolívar', 'Ciudad Guayana', 'Upata', 'Caicara del Orinoco'],
    'Carabobo': ['Valencia', 'Puerto Cabello', 'Guacara', 'Naguanagua', 'San Diego'],
    'Cojedes': ['San Carlos', 'Tinaco', 'Tinaquillo', 'El Pao'],
    'Delta Amacuro': ['Tucupita', 'Pedernales', 'Antonio Díaz', 'Casacoima'],
    'Distrito Capital': ['Caracas (Libertador)'],
    'Falcón': ['Coro', 'Punto Fijo', 'Chichiriviche', 'Vela de Coro', 'Dabajuro'],
    'Guárico': ['San Juan de los Morros', 'Calabozo', 'Valle de la Pascua', 'Zaraza'],
    'Lara': ['Barquisimeto', 'Cabudare', 'Carora', 'El Tocuyo', 'Quíbor'],
    'Mérida': ['Mérida', 'El Vigía', 'Ejido', 'Tovar', 'Mucuchíes'],
    'Miranda': ['Los Teques', 'Chacao', 'Baruta', 'Guatire', 'Guarenas', 'Higuerote'],
    'Monagas': ['Maturín', 'Caripe', 'Caripito', 'Punta de Mata'],
    'Nueva Esparta': ['La Asunción', 'Porlamar', 'Pampatar', 'Juan Griego'],
    'Portuguesa': ['Guanare', 'Acarigua', 'Araure', 'Turén'],
    'Sucre': ['Cumaná', 'Carúpano', 'Güiria', 'Cumanacoa'],
    'Táchira': ['San Cristóbal', 'Tariba', 'Rubio', 'San Antonio del Táchira'],
    'Trujillo': ['Trujillo', 'Valera', 'Boconó', 'Carache'],
    'La Guaira': ['La Guaira', 'Catia La Mar', 'Macuto', 'Maiquetía', 'Carayaca'],
    'Yaracuy': ['San Felipe', 'Yaritagua', 'Chivacoa', 'Nirgua'],
    'Zulia': ['Maracaibo', 'San Francisco', 'Cabimas', 'Ciudad Ojeda', 'Santa Bárbara'],
  };

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
    super.dispose();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (mounted) {
          if (doc.exists) {
            final data = doc.data();
            setState(() {
              _nombreController.text = data?['nombre'] ?? '';
              _apellidoController.text = data?['apellido'] ?? '';
              _correoOriginal = data?['correo'] ?? user.email ?? '';
              _emailController.text = _correoOriginal;

              // Validamos que el estado guardado exista en nuestro Map antes de asignarlo
              final estadoGuardado = data?['estado'];
              if (_venezuelaData.containsKey(estadoGuardado)) {
                _estadoSeleccionado = estadoGuardado;
                
                // Validamos que el municipio guardado pertenezca a ese estado
                final municipioGuardado = data?['municipio'];
                if (_venezuelaData[_estadoSeleccionado]!.contains(municipioGuardado)) {
                  _municipioSeleccionado = municipioGuardado;
                }
              }

              _isLoading = false;
            });
          } else {
            setState(() {
              _correoOriginal = user.email ?? '';
              _emailController.text = _correoOriginal;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _handleActualizar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final nuevoCorreo = _emailController.text.trim();
          bool requiereReautenticacion = false;

          if (nuevoCorreo != _correoOriginal && _correoOriginal.isNotEmpty) {
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

          if (_passwordController.text.trim().isNotEmpty) {
            if (_passwordController.text.trim().length >= 6) {
              await user.updatePassword(_passwordController.text.trim());
            }
          }

          // Se guardan los strings seleccionados directamente en Firestore
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .set({
                'nombre': _nombreController.text.trim(),
                'apellido': _apellidoController.text.trim(),
                'correo': nuevoCorreo,
                'estado': _estadoSeleccionado ?? '',
                'municipio': _municipioSeleccionado ?? '',
              }, SetOptions(merge: true));

          _correoOriginal = nuevoCorreo;

          if (mounted) {
            if (requiereReautenticacion) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se ha enviado un enlace a tu nuevo correo. Para aplicar los cambios, inicia sesión nuevamente.'),
                  duration: Duration(seconds: 4),
                ),
              );
              await Future.delayed(const Duration(seconds: 3));
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Información actualizada correctamente.')),
              );
              _passwordController.clear();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmarCerrarSesion() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff252B20),
          title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas salir de tu cuenta?', style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    // Obtener la lista de municipios según el estado seleccionado
    List<String> municipiosDisponibles = _estadoSeleccionado != null 
        ? _venezuelaData[_estadoSeleccionado]! 
        : [];

    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      drawer: isMobile ? const CustomDrawer(selectedIndex: 5) : null,
      appBar: isMobile ? const Header(selectedIndex: 5, isMobile: true) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE2E600)))
          : Column(
              children: [
                if (!isMobile) const Header(selectedIndex: 5, isMobile: false),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                                  style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 40),

                              Row(
                                children: [
                                  Expanded(child: _buildTextField('Nombre:', _nombreController)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildTextField('Apellido:', _apellidoController)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildTextField('Correo:', _emailController, isEmail: true),
                              const SizedBox(height: 20),

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
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Fila de selectores dinámicos (Estado y Municipio)
                              Row(
                                children: [
                                  // Selector de Estado
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Estado:', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Montserrat')),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _estadoSeleccionado,
                                          dropdownColor: const Color(0xff252B20),
                                          style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                          decoration: _getDropdownDecoration(),
                                          items: _venezuelaData.keys.map((String estado) {
                                            return DropdownMenuItem<String>(
                                              value: estado,
                                              child: Text(estado),
                                            );
                                          }).toList(),
                                          validator: (value) => value == null ? 'Requerido' : null,
                                          onChanged: (nuevoEstado) {
                                            setState(() {
                                              _estadoSeleccionado = nuevoEstado;
                                              _municipioSeleccionado = null; // Resetea el municipio previo
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  
                                  // Selector de Municipio
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Municipio:', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Montserrat')),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _municipioSeleccionado,
                                          dropdownColor: const Color(0xff252B20),
                                          style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                          decoration: _getDropdownDecoration(hint: _estadoSeleccionado == null ? 'Elige Estado' : 'Elegir'),
                                          items: municipiosDisponibles.map((String municipio) {
                                            return DropdownMenuItem<String>(
                                              value: municipio,
                                              child: Text(municipio),
                                            );
                                          }).toList(),
                                          validator: (value) => value == null ? 'Requerido' : null,
                                          onChanged: _estadoSeleccionado == null ? null : (nuevoMunicipio) {
                                            setState(() {
                                              _municipioSeleccionado = nuevoMunicipio;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              _isSaving
                                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE2E600)))
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: _handleActualizar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE2E600),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        child: const Text(
                                          'Actualizar',
                                          style: TextStyle(color: Color(0xff1A1F16), fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Montserrat'),
                                        ),
                                      ),
                                    ),

                              const SizedBox(height: 15),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: _confirmarCerrarSesion,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.logout, color: Colors.redAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cerrar sesión',
                                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Montserrat'),
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
                    border: Border(top: BorderSide(color: Color(0xFFE2E600), width: 2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/Logo.png', width: 90, errorBuilder: (context, error, stackTrace) => const SizedBox(width: 90)),
                        Row(
                          children: [
                            TextButton(onPressed: () {}, child: const Text('Sobre Nosotros', style: TextStyle(color: Colors.white, fontSize: 13))),
                            TextButton(onPressed: () {}, child: const Text('Se un Aliado', style: TextStyle(color: Colors.white, fontSize: 13))),
                            TextButton(onPressed: () {}, child: const Text('Ayuda', style: TextStyle(color: Colors.white, fontSize: 13))),
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

  // Estilo estético unificado para los Dropdowns
  InputDecoration _getDropdownDecoration({String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xff252B20),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      errorStyle: const TextStyle(color: Colors.redAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
    );
  }

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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Montserrat')),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (requiered && (value == null || value.trim().isEmpty)) return 'Campo obligatorio';
            if (isEmail && value!.isNotEmpty && !value.contains('@')) return 'Ingresa un correo válido';
            if (isPassword && value!.isNotEmpty && value.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff252B20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            errorStyle: const TextStyle(color: Colors.redAccent),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                    onPressed: onToggleVisibility,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
          ),
        ),
      ],
    );
  }
}