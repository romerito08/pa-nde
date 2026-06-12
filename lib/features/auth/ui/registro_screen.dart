import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../models/usuario.dart';
import '../logic/auth_controller.dart';

/// Pantalla de registro (RF01/RF15): crea la cuenta en Firebase Auth y el
/// documento en la colección `usuarios` segregando el rol elegido
/// (Explorador o Aliado). Replica la composición de Figma: panel fotográfico
/// en Web, formulario en columna con filas dobles y botón amarillo.
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
  final _estadoController = TextEditingController();
  final _municipioController = TextEditingController();

  String _rolSeleccionado = RolesUsuario.explorador;
  bool _contrasenaOculta = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _estadoController.dispose();
    _municipioController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final exito = await auth.registrar(
      correo: _correoController.text,
      contrasena: _contrasenaController.text,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      estado: _estadoController.text,
      municipio: _municipioController.text,
      rol: _rolSeleccionado,
    );

    if (!mounted) return;
    if (exito) {
      FeedbackHelper.mostrarExito(context, '¡Cuenta creada! Bienvenido a Pa\'onde.');
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
          padding: EdgeInsets.symmetric(horizontal: esMovil ? 24 : 60, vertical: 40),
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
                  const SizedBox(height: 36),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _campoTexto('Nombre', _nombreController)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _campoTexto('Apellido', _apellidoController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _campoTexto('Correo electrónico', _correoController,
                      esCorreo: true),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _contrasenaOculta,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
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
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Crea una contraseña.';
                      }
                      if (valor.length < 6) {
                        return 'Debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¿Dónde estás? Encuentra lo mejor de tu zona.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _campoTexto('Estado', _estadoController)),
                      const SizedBox(width: 16),
                      Expanded(
                          child:
                              _campoTexto('Municipio', _municipioController)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Selector de rol: segrega Exploradores y Aliados (RF15).
                  DropdownButtonFormField<String>(
                    initialValue: _rolSeleccionado,
                    dropdownColor: AppColors.verde,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: const InputDecoration(
                      labelText: '¿Cómo quieres usar Pa\'onde?',
                      prefixIcon: Icon(Icons.badge_outlined,
                          color: AppColors.verdeClaro),
                    ),
                    items: RolesUsuario.registrables
                        .map((rol) => DropdownMenuItem(
                              value: rol,
                              child: Text(
                                rol == RolesUsuario.explorador
                                    ? 'Explorador — quiero viajar'
                                    : 'Aliado — quiero ofrecer servicios',
                                style:
                                    const TextStyle(color: AppColors.blanco),
                              ),
                            ))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() => _rolSeleccionado = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 36),
                  auth.cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _enviar,
                          child: const Text('Registrarse'),
                        ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
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

  Widget _campoTexto(String etiqueta, TextEditingController controller,
      {bool esCorreo = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: esCorreo ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: AppColors.blanco),
      decoration: InputDecoration(labelText: etiqueta),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'Campo obligatorio.';
        }
        if (esCorreo && (!valor.contains('@') || !valor.contains('.'))) {
          return 'Ingresa un correo válido.';
        }
        return null;
      },
    );
  }
}
