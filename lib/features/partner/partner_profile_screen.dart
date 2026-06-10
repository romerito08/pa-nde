import 'package:flutter/material.dart';
import 'package:paonde_app/widgets/header.dart';
import 'package:paonde_app/widgets/footer.dart';
import 'package:paonde_app/widgets/drawer.dart';

class PartnerModel {
  final String companyName;
  final String rif;
  final String phone;
  final String email;
  final String password;
  final String estado;
  final String municipio;

  PartnerModel({
    required this.companyName,
    required this.rif,
    required this.phone,
    required this.email,
    required this.password,
    required this.estado,
    required this.municipio,
  });
}

class PerfilAliadoScreen extends StatefulWidget {
  const PerfilAliadoScreen({super.key});

  @override
  State<PerfilAliadoScreen> createState() => _PerfilAliadoScreenState();
}

class _PerfilAliadoScreenState extends State<PerfilAliadoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _companyController;
  late TextEditingController _rifController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String? _selectedEstado;
  String? _selectedMunicipio;
  List<String> _municipiosDisponibles = [];

  bool _isPasswordVisible = false;
  bool _isDataInitialized = false;

  // Diccionario geográfico de Venezuela
  final Map<String, List<String>> _venezuelaGeografia = {
    'Amazonas': ['Atures', 'Atabapo', 'Maroa', 'Río Negro', 'Autana'],
    'Anzoátegui': ['Anaco', 'Aragua', 'Diego Bautista Urbaneja', 'Juan Antonio Sotillo', 'Simón Bolívar', 'Freites'],
    'Apure': ['San Fernando', 'Achaguas', 'Biruaca', 'Muñoz', 'Paéz'],
    'Aragua': ['Girardot', 'Santiago Mariño', 'José Félix Ribas', 'Sucre', 'Zamora', 'Tovar'],
    'Barinas': ['Barinas', 'Bolívar', 'Cruz Paredes', 'Obispos', 'Pedraza', 'Alberto Arvelo Torrealba'],
    'Bolívar': ['Caroní', 'Angostura del Orinoco', 'Piar', 'Gran Sabana', 'Sifontes', 'Callao'],
    'Carabobo': ['Valencia', 'Puerto Cabello', 'Guacara', 'Naguanagua', 'San Diego', 'Tocuyito'],
    'Cojedes': ['San Carlos', 'Tinaco', 'Tinaquillo', 'Anzoátegui', 'Pao de San Juan Bautista'],
    'Delta Amacuro': ['Tucupita', 'Pedernales', 'Antonio Díaz', 'Casacoima'],
    'Distrito Capital': ['Libertador'],
    'Falcón': ['Miranda', 'Carirubana', 'Silva', 'Colina', 'Falcón', 'Monseñor Iturriza', 'Los Taques'],
    'Guárico': ['Juan Germán Roscio', 'Francisco de Miranda', 'Leonardo Infante', 'Zaraza', 'Calabozo'],
    'Lara': ['Iribarren', 'Palavecino', 'Morán', 'Torres', 'Jiménez', 'Andrés Eloy Blanco'],
    'Mérida': ['Libertador', 'Alberto Adriani', 'Campo Elías', 'Sucre', 'Tovar', 'Rangel'],
    'Miranda': ['Chacao', 'Sucre', 'Baruta', 'El Hatillo', 'Guaicaipuro', 'Plaza', 'Zamora', 'Lander'],
    'Monagas': ['Maturín', 'Caripe', 'Cedeño', 'Ezequiel Zamora', 'Piar'],
    'Nueva Esparta': ['Mariño', 'Maneiro', 'Arismendi', 'García', 'Antolín del Campo', 'Macanao'],
    'Portuguesa': ['Guanare', 'Acarigua', 'Araure', 'Turén', 'Ospino'],
    'Sucre': ['Sucre', 'Bermúdez', 'Benítez', 'Arismendi', 'Valdez', 'Ribero'],
    'Táchira': ['San Cristóbal', 'Cárdenas', 'Junín', 'Pedro María Ureña', 'Bolívar', 'Jáuregui'],
    'Trujillo': ['Trujillo', 'Valera', 'Boconó', 'Carache', 'Escuque'],
    'La Guaira': ['Vargas'],
    'Yaracuy': ['San Felipe', 'Peña', 'Nirgua', 'Bruzual', 'Independencia'],
    'Zulia': ['Maracaibo', 'San Francisco', 'Cabimas', 'Lagunillas', 'Colón', 'Mara', 'Guajira'],
  };

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController();
    _rifController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isDataInitialized) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      
      // SÓLO SE CARGA SI EXISTEN DATOS REALES PASADOS POR ARGUMENTOS
      if (arguments is PartnerModel) {
        _companyController.text = arguments.companyName;
        _rifController.text = arguments.rif;
        _phoneController.text = arguments.phone;
        _emailController.text = arguments.email;
        _passwordController.text = arguments.password;
        _setupUbicacion(arguments.estado, arguments.municipio);
      }
      _isDataInitialized = true;
    }
  }

  void _setupUbicacion(String estado, String municipio) {
    if (_venezuelaGeografia.containsKey(estado)) {
      _selectedEstado = estado;
      _municipiosDisponibles = _venezuelaGeografia[estado]!;
      if (_municipiosDisponibles.contains(municipio)) {
        _selectedMunicipio = municipio;
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _rifController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Todos los campos reales han sido actualizados con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cerrarSesion() {
    // Aquí puedes añadir tu lógica de Firebase Auth si la usas en el futuro:
    // FirebaseAuth.instance.signOut();
    
    // Limpia el historial de navegación y redirige al home o login de la app
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);
    const Color inputBgColor = Color(0xff11140E);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const CustomDrawer(selectedIndex: -1) : null,
      appBar: isMobile ? const Header(selectedIndex: -1, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) _buildAliadoHeader(context),

            // --- HERO ---
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: isMobile ? 140 : 200,
                  width: double.infinity,
                  child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
                ),
                Container(width: double.infinity, height: isMobile ? 140 : 200, color: Colors.black.withAlpha((0.4 * 255).round())),
                Column(
                  children: [
                    const Icon(Icons.account_circle, size: 60, color: primaryYellow),
                    const SizedBox(height: 8),
                    Text('Perfil de Aliado', style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),

            // --- FORMULARIO INTEGRAL ---
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 40.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel('Nombre de la compañía:'),
                        _buildInputField(_companyController, inputBgColor),
                        const SizedBox(height: 20),

                        if (!isMobile)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('RIF:'),
                                    _buildInputField(_rifController, inputBgColor),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Nro de Teléfono:'),
                                    _buildInputField(_phoneController, inputBgColor, keyboardType: TextInputType.phone),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildLabel('RIF:'),
                          _buildInputField(_rifController, inputBgColor),
                          const SizedBox(height: 20),
                          _buildLabel('Nro de Teléfono:'),
                          _buildInputField(_phoneController, inputBgColor, keyboardType: TextInputType.phone),
                        ],
                        const SizedBox(height: 20),

                        _buildLabel('Correo:'),
                        _buildInputField(_emailController, inputBgColor, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20),

                        _buildLabel('Contraseña:'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputBgColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Center(
                          child: Text(
                            '¿Dónde se encuentra tu alojamiento o servicio?',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withAlpha((0.9 * 255).round()), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- SELECTORES DINÁMICOS ---
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Estado:'),
                                  DropdownButtonFormField<String>(
                                    value: _selectedEstado,
                                    dropdownColor: inputBgColor,
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: inputBgColor,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                    hint: const Text('Seleccione', style: TextStyle(color: Colors.white38, fontSize: 14)),
                                    items: _venezuelaGeografia.keys.map((String estado) {
                                      return DropdownMenuItem<String>(value: estado, child: Text(estado));
                                    }).toList(),
                                    onChanged: (String? nuevoEstado) {
                                      setState(() {
                                        _selectedEstado = nuevoEstado;
                                        _municipiosDisponibles = nuevoEstado != null ? _venezuelaGeografia[nuevoEstado]! : [];
                                        _selectedMunicipio = null;
                                      });
                                    },
                                    validator: (val) => val == null ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Municipio:'),
                                  DropdownButtonFormField<String>(
                                    value: _selectedMunicipio,
                                    dropdownColor: inputBgColor,
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: inputBgColor,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                    hint: const Text('Seleccione', style: TextStyle(color: Colors.white38, fontSize: 14)),
                                    items: _municipiosDisponibles.map((String municipio) {
                                      return DropdownMenuItem<String>(value: municipio, child: Text(municipio));
                                    }).toList(),
                                    onChanged: _selectedEstado == null ? null : (String? nuevoMunicipio) {
                                      setState(() {
                                        _selectedMunicipio = nuevoMunicipio;
                                      });
                                    },
                                    validator: (val) => val == null ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // --- BOTONES DE ACCIÓN (GUARDAR Y CERRAR SESIÓN) ---
                        Row(
                          children: [
                            // Botón Guardar Cambios
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _guardarCambios,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryYellow,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Guardar Cambios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón Cerrar Sesión
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: _cerrarSesion,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                    foregroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.logout, size: 18),
                                  label: const Text('Salir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // --- FOOTER ---
                        const Divider(color: primaryYellow, thickness: 1),
                        Padding(
                          padding: EdgeInsets.only(top: isMobile ? 4.0 : 8.0, bottom: isMobile ? 0.0 : 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset('assets/Logo.png', width: isMobile ? 80 : 150, fit: BoxFit.contain),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Footer(title: 'Sobre Nosotros', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/sobre-nosotros')),
                                    SizedBox(width: isMobile ? 6 : 20),
                                    Footer(title: 'Sé un Aliado', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/se-un-aliado')),
                                    SizedBox(width: isMobile ? 6 : 20),
                                    Footer(title: 'Ayuda', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/ayuda')),
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
      ),
    );
  }

  Widget _buildAliadoHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      color: const Color(0xff1A1F16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/Logo.png', width: 120),
          Row(
            children: [
              _aliadoNavLink(context, 'Dashboard', false, '/partner-dashboard'),
              _aliadoNavLink(context, 'Servicios', false, '/partner-services'),
              _aliadoNavLink(context, 'Cotizaciones', false, '/partner-quotes'),
              _aliadoNavLink(context, 'Reservas', false, '/partner-reservations'),
            ],
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Text('Mi perfil', style: TextStyle(color: Color(0xffE2E600), fontWeight: FontWeight.bold)),
            label: const Icon(Icons.account_circle, color: Color(0xffE2E600)),
          ),
        ],
      ),
    );
  }

  Widget _aliadoNavLink(BuildContext context, String text, bool isSelected, String routeName) {
    return InkWell(
      onTap: () {
        if (!isSelected) Navigator.pushNamed(context, routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(text, style: TextStyle(color: isSelected ? const Color(0xffE2E600) : Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildInputField(TextEditingController controller, Color bgColor, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
        return null;
      },
    );
  }
}