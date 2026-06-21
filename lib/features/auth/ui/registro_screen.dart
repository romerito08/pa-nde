import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/utils/validadores.dart';
import '../../../core/widgets/campo_telefono.dart';
import '../../../core/widgets/selector_geografico.dart';
import '../../../models/usuario.dart';
import '../logic/auth_controller.dart';

/// Registro de Exploradores (RF01/RF15). Correo validado con RegEx UNIMET.
/// Contraseña: ≥ 4 letras, 1 mayúscula y ≥ 4 números. Teléfono segmentado
/// (código de operadora + 7 dígitos). Estado/Municipio con dropdowns.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  String _telefonoActual = '';
  String? _estadoSeleccionado;
  String? _municipioSeleccionado;
  bool _contrasenaOculta = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
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
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      telefono: _telefonoActual,
      estado: _estadoSeleccionado!,
      municipio: _municipioSeleccionado!,
      rol: RolesUsuario.explorador,
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final esMovil = constraints.maxWidth < 850;
          return Stack(
            children: [
              esMovil
                  ? _formulario(esMovil)
                  : Row(
                      children: [
                        Expanded(child: _panelDecorativo()),
                        Expanded(child: _formulario(esMovil)),
                      ],
                    ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  tooltip: 'Volver al inicio',
                  icon: const Icon(Icons.close, color: AppColors.blanco, size: 28),
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _panelDecorativo() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/imageninicio.png', fit: BoxFit.cover),
        Container(color: Colors.black26),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: Image.asset('assets/Logo.png', fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }

  Widget _formulario(bool esMovil) {
    final auth = context.watch<AuthController>();
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: esMovil ? 24 : 60, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¿Listo para saber\npa\'onde vas?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Registro de Exploradores — comunidad UNIMET',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.verdeClaro, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _campoTexto('Nombre', _nombreController)),
                      const SizedBox(width: 16),
                      Expanded(
                          child:
                              _campoTexto('Apellido', _apellidoController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Correo institucional UNIMET
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: const InputDecoration(
                      labelText: 'Correo institucional UNIMET',
                      hintText: 'nombre@correo.unimet.edu.ve',
                      prefixIcon: Icon(Icons.school_outlined,
                          color: AppColors.verdeClaro),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu correo institucional.';
                      }
                      if (!Validadores.esCorreoUnimet(valor)) {
                        return 'Debe terminar en @unimet.edu.ve o @correo.unimet.edu.ve';
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
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.verdeClaro),
                      suffixIcon: IconButton(
                        tooltip: _contrasenaOculta
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
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
                  const SizedBox(height: 24),
                  const Text(
                    '¿Dónde estás? Encuentra lo mejor de tu zona.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.verdeClaro, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SelectorGeografico(
                    estado: _estadoSeleccionado,
                    municipio: _municipioSeleccionado,
                    enFila: !esMovil,
                    onChanged: (estado, municipio) => setState(() {
                      _estadoSeleccionado = estado;
                      _municipioSeleccionado = municipio;
                    }),
                  ),
                  const SizedBox(height: 36),
                  auth.cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _enviar,
                          child: const Text('Registrarse'),
                        ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/login'),
                      child: const Text(
                          '¿Ya tienes una cuenta? Inicia sesión'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      '¿Quieres ofrecer tus servicios? Encuentra "Sé un Aliado" en el pie de página del inicio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.verdeClaro, fontSize: 12),
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

  Widget _campoTexto(String etiqueta, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.blanco),
      decoration: InputDecoration(labelText: etiqueta),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio.';
        return null;
      },
    );
  }
}
