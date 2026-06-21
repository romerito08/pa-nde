import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/utils/validadores.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/campo_rif.dart';
import '../../../core/widgets/campo_telefono.dart';
import '../../../core/widgets/selector_geografico.dart';
import '../../../models/usuario.dart';
import '../logic/auth_controller.dart';

class RegistroAliadoScreen extends StatefulWidget {
  const RegistroAliadoScreen({super.key});

  @override
  State<RegistroAliadoScreen> createState() => _RegistroAliadoScreenState();
}

class _RegistroAliadoScreenState extends State<RegistroAliadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreEmpresaController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  String _rifActual = '';
  String _telefonoActual = '';
  String? _estadoSeleccionado;
  String? _municipioSeleccionado;
  bool _contrasenaOculta = true;

  static const _beneficios = [
    (
      icono: Icons.article_outlined,
      titulo: 'Identidad del servicio',
      detalle:
          'Define el nombre, la categoría (Alojamiento o Experiencia) y la descripción de lo que ofreces.',
    ),
    (
      icono: Icons.account_balance_wallet_outlined,
      titulo: 'Costos e Inversión',
      detalle:
          'Gestiona tus tarifas detalladas y establece el cupo máximo de personas para evitar sobreventas.',
    ),
    (
      icono: Icons.location_on_outlined,
      titulo: 'Ubicación y Galería',
      detalle:
          'Ubica tu emprendimiento en el mapa y sube las mejores fotos para atraer a los viajeros.',
    ),
  ];

  static const _seguridad = [
    (
      icono: Icons.person_outline,
      titulo: 'Aliados Certificados',
      detalle:
          'Verificamos cada emprendimiento para garantizar la mejor experiencia.',
    ),
    (
      icono: Icons.monetization_on_outlined,
      titulo: 'Pagos Seguros',
      detalle: 'Recibe tus pagos de forma puntual y protegida.',
    ),
    (
      icono: Icons.help_outline,
      titulo: 'Soporte 24/7',
      detalle:
          'Acompañamiento constante para el crecimiento de tu negocio.',
    ),
  ];

  @override
  void dispose() {
    _nombreEmpresaController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estadoSeleccionado == null || _municipioSeleccionado == null) {
      FeedbackHelper.mostrarAdvertencia(
          context, 'Selecciona tu Estado y Municipio de la lista.');
      return;
    }

    final auth = context.read<AuthController>();
    final exito = await auth.registrar(
      correo: _correoController.text,
      contrasena: _contrasenaController.text,
      nombre: _nombreEmpresaController.text,
      apellido: _rifActual,
      telefono: _telefonoActual,
      estado: _estadoSeleccionado!,
      municipio: _municipioSeleccionado!,
      rol: RolesUsuario.aliado,
    );

    if (!mounted) return;
    if (exito) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(auth.rutaSegunRol, (route) => false);
    } else {
      FeedbackHelper.mostrarError(
          context, auth.error ?? 'No fue posible crear la cuenta.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _hero(esMovil),
                _seccionFormulario(esMovil),
                _seccionBeneficios(esMovil),
                _seccionSeguridad(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 20 : 48),
                      child: AppFooter(esMovil: esMovil),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hero(bool esMovil) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: esMovil ? 180 : 240,
          width: double.infinity,
          child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
        ),
        Container(
          height: esMovil ? 180 : 240,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        Image.asset('assets/Logo.png', width: esMovil ? 160 : 220),
      ],
    );
  }

  Widget _seccionFormulario(bool esMovil) {
    final auth = context.watch<AuthController>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: esMovil ? 20 : 48,
            vertical: 40,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Accede a una herramienta sin límites',
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.amarillo,
                            fontWeight: FontWeight.w700,
                          ),
                ),
                const SizedBox(height: 32),
                // Nombre de la empresa
                _campoTexto(
                  label: 'Nombre de la compañía',
                  controller: _nombreEmpresaController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio.'
                      : null,
                ),
                const SizedBox(height: 16),
                // RIF segmentado (tipo J/V/E/G/C + número)
                const Text(
                  'RIF de la empresa',
                  style: TextStyle(
                      color: AppColors.verdeClaro, fontSize: 13),
                ),
                const SizedBox(height: 8),
                CampoRif(
                  onChanged: (v) => _rifActual = v,
                ),
                const SizedBox(height: 16),
                // Teléfono segmentado
                const Text(
                  'Teléfono',
                  style: TextStyle(
                      color: AppColors.verdeClaro, fontSize: 13),
                ),
                const SizedBox(height: 8),
                CampoTelefono(
                  onChanged: (v) => _telefonoActual = v,
                ),
                const SizedBox(height: 16),
                // Correo genérico (texto@texto.com)
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    hintText: 'empresa@ejemplo.com',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.verdeClaro),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Campo obligatorio.';
                    }
                    if (!Validadores.esCorreoValido(v.trim())) {
                      return 'Ingresa un correo válido. Ej.: empresa@ejemplo.com';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Contraseña segura
                TextFormField(
                  controller: _contrasenaController,
                  obscureText: _contrasenaOculta,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    helperText:
                        'Mín. 4 letras, 1 mayúscula y 4 números',
                    helperStyle: const TextStyle(
                        color: AppColors.verdeClaro, fontSize: 11),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _contrasenaOculta
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.verdeClaro,
                      ),
                      onPressed: () => setState(
                          () => _contrasenaOculta = !_contrasenaOculta),
                    ),
                  ),
                  validator: Validadores.validarContrasena,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¿Dónde se encuentra tu alojamiento o servicio?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.verdeClaro, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SelectorGeografico(
                  estado: _estadoSeleccionado,
                  municipio: _municipioSeleccionado,
                  enFila: true,
                  onChanged: (estado, municipio) => setState(() {
                    _estadoSeleccionado = estado;
                    _municipioSeleccionado = municipio;
                  }),
                ),
                const SizedBox(height: 28),
                auth.cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _enviar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amarillo,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                const SizedBox(height: 16),
                const Text(
                  '¿Ya tienes una cuenta?',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.verdeClaro, fontSize: 13),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.amarillo,
                    side: const BorderSide(color: AppColors.amarillo),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      style: const TextStyle(color: AppColors.blanco),
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  Widget _seccionBeneficios(bool esMovil) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: esMovil ? 20 : 48,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Porqué estar en paonde?',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.blanco,
                          fontWeight: FontWeight.w700,
                        ),
              ),
              const SizedBox(height: 32),
              esMovil
                  ? Column(
                      children: _beneficios
                          .map((b) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 16),
                                child: _tarjetaBeneficio(b),
                              ))
                          .toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _beneficios
                          .map((b) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: _tarjetaBeneficio(b),
                                ),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaBeneficio(
      ({IconData icono, String titulo, String detalle}) b) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.amarillo, width: 1.5),
            ),
            child: Icon(b.icono, color: AppColors.amarillo, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            b.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.amarillo,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            b.detalle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.blanco,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionSeguridad(bool esMovil) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: esMovil ? 20 : 48,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Seguridad y confianza en cada paso',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.blanco,
                          fontWeight: FontWeight.w700,
                        ),
              ),
              const SizedBox(height: 32),
              ..._seguridad.map((item) => _filaSeguridad(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaSeguridad(
      ({IconData icono, String titulo, String detalle}) item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.amarillo, width: 1.5),
            ),
            child:
                Icon(item.icono, color: AppColors.amarillo, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: const TextStyle(
                    color: AppColors.amarillo,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detalle,
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 13,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
