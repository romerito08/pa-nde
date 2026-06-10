// lib/features/partner/partner_register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/footer.dart';

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
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
  await _firestore.collection('usuarios').doc(user.uid).set({
    'uid': user.uid,
    'nombre': _companyController.text.trim(),   // De 'companyName' a 'nombre' (Estandarizado)
    'rif': _rifController.text.trim().toUpperCase(),
    'telefono': _phoneController.text.trim(),   // De 'phone' a 'telefono'
    'correo': _emailController.text.trim(),     // De 'email' a 'correo'
    'estado': _stateController.text.trim(),     // De 'state' a 'estado'
    'municipio': _municipioController.text.trim(),
    'direccion': _addressController.text.trim(), // De 'address' a 'direccion'
    'role': 'partner',                          // Discriminador de rol requerido por el sistema
    'createdAt': FieldValue.serverTimestamp(),
  });

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
    const Color primaryYellow = Color(0xffE2E600);
    const Color cardBgColor = Color(0xff1C241B);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    double dynamicAspectRatio = 1.05;
    if (!isMobile) {
      if (screenWidth > 1200) {
        dynamicAspectRatio = 1.6;
      } else if (screenWidth > 900) {
        dynamicAspectRatio = 1.3;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      body: CustomScrollView(
        slivers: [
          // 1. ENCABEZADO RESPONSIVO (Igual al Home)
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: false,
            backgroundColor: const Color(0xff1A1F16),
            iconTheme: const IconThemeData(color: Color(0xffE2E600)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Image.asset(
                          'assets/Logo.png',
                          width: isMobile ? 180 : 250,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. FORMULARIO SEGURO Y LIMITADO (Ancho máximo 600px)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Mantiene la estética limpia de los inputs
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Accede a una herramienta sin límites',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffE2E600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(_companyController, 'Nombre de la Compañía', Icons.business),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(_rifController, 'RIF', Icons.numbers),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(_phoneController, 'Nro de Teléfono', Icons.phone, keyboardType: TextInputType.phone),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(_emailController, 'Correo Electrónico', Icons.email, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildTextField(_passwordController, 'Contraseña', Icons.lock, obscure: true),
                        const SizedBox(height: 24),

                        const Center(
                          child: Text(
                            '¿Dónde se encuentra tu alojamiento o servicio?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 171, 172, 159),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(_stateController, 'Estado', Icons.location_on),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(_municipioController, 'Municipio', Icons.location_city),
                            ),
                          ],
                        ),
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
                        const SizedBox(height: 32),
                        const Center(
                          child: Text(
                            '¿Ya tienes una cuenta?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 171, 172, 159),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff333D2E), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: const Color(0xffE2E600),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. SECCIÓN INFERIOR RESPONSIVA Y ANCHA (Ancho máximo 1000px como en Home)
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000), // Ahora las tarjetas aprovechan toda la pantalla
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          '¿Por qué estar en pa\'onde?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid adaptativo idéntico a HomeScreen
                      if (isMobile) ...[
                        _buildOfferCard2(
                          icon: Icons.menu_sharp,
                          title: 'Identidad del servicio',
                          description: 'Define el nombre, la categoría (Alojamiento o Experiencia) y la descripción de lo que ofreces.',
                        ),
                        const SizedBox(height: 16),
                        _buildOfferCard2(
                          icon: Icons.payment_rounded,
                          title: 'Gastos e Inversión',
                          description: 'Gestiona tus tarifas detalladas y establece el cupo máximo de personas para evitar sobreventas.',
                        ),
                        const SizedBox(height: 16),
                        _buildOfferCard2(
                          icon: Icons.pin_drop_outlined,
                          title: 'Ubicación y Galería',
                          description: 'Ubica tu emprendimiento en el mapa y sube las mejores fotos para atraer a los viajeros.',
                        ),
                      ] else ...[
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: dynamicAspectRatio,
                          children: [
                            _buildOfferCard2(
                              icon: Icons.menu_sharp,
                              title: 'Identidad del servicio',
                              description: 'Define el nombre, la categoría (Alojamiento o Experiencia) y la descripción de lo que ofreces.',
                            ),
                            _buildOfferCard2(
                              icon: Icons.payment_rounded,
                              title: 'Gastos e Inversión',
                              description: 'Gestiona tus tarifas detalladas y establece el cupo máximo de personas para evitar sobreventas.',
                            ),
                            _buildOfferCard2(
                              icon: Icons.pin_drop_outlined,
                              title: 'Ubicación y Galería',
                              description: 'Ubica tu emprendimiento en el mapa y sube las mejores fotos para atraer a los viajeros.',
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 48),
                      const Center(
                        child: Text(
                          'Seguridad y confianza en cada paso',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildOfferCard(
                        icon: Icons.perm_identity,
                        title: 'Aliados Certificados',
                        description: 'Verificamos cada emprendimiento para garantizar la mejor experiencia.',
                        cardBgColor: cardBgColor,
                        primaryYellow: primaryYellow,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferCard(
                        icon: Icons.monetization_on_outlined,
                        title: 'Pagos Seguros',
                        description: 'Recibe tus pagos de forma puntual y protegida.',
                        cardBgColor: cardBgColor,
                        primaryYellow: primaryYellow,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferCard(
                        icon: Icons.question_mark_outlined,
                        title: 'Soporte 24/7',
                        description: 'Acompañamiento constante para el crecimiento de tu negocio.',
                        cardBgColor: cardBgColor,
                        primaryYellow: primaryYellow,
                      ),
                      const Divider(
                        color: primaryYellow,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      Padding(
                        // MODIFICACIÓN: Reducimos el padding inferior para pegarlo más al borde de la página
                        padding: EdgeInsets.only(
                          top: isMobile ? 4.0 : 8.0,
                          bottom: isMobile
                              ? 0.0
                              : 4.0, // Menos espacio abajo si es móvil
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Alinea verticalmente el logo y los textos
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: isMobile ? 80 : 150,
                              fit: BoxFit.contain,
                              // Alinea el logo a la izquierda dentro de su espacio
                            ),

                            // LADO DERECHO: Enlaces que se mantienen horizontales
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize
                                    .min, // Ocupa solo el espacio necesario
                                children: [
                                  Footer(
                                    title: 'Sobre Nosotros',
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/sobre-nosotros',
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: isMobile ? 6 : 20,
                                  ), // Espaciado más ajustado en móvil
                                  Footer(
                                    title: 'Sé un Aliado',
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/se-un-aliado',
                                      );
                                    },
                                  ),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(
                                    title: 'Ayuda',
                                    isMobile: isMobile,
                                    onTap: () {
                                      Navigator.pushNamed(context, '/ayuda');
                                    },
                                  ),
                                ],
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

  Widget _buildOfferCard({
    required IconData icon,
    required String title,
    required String description,
    required Color cardBgColor,
    required Color primaryYellow,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryYellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard2({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1C241B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xffE2E600),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}