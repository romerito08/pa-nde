import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../logic/auth_controller.dart';

/// Pantalla de inicio de sesión (RF01), fiel al diseño de Figma:
/// panel fotográfico con el logo a la izquierda (solo Web/escritorio),
/// formulario oscuro a la derecha, inputs con radio de 10 px, botón
/// amarillo #F2DE00 y campo de contraseña con ojo para alternar visibilidad.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  /// Controla la visibilidad del texto de la contraseña (botón de ojo).
  bool _contrasenaOculta = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final exito = await auth.iniciarSesion(
      _correoController.text,
      _contrasenaController.text,
    );

    if (!mounted) return;

    if (exito) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(auth.rutaSegunRol, (route) => false);
    } else if (auth.esBloqueado) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/cuenta-bloqueada', (route) => false);
    } else {
      FeedbackHelper.mostrarError(
          context, auth.error ?? 'No fue posible iniciar sesión.');
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
            widthFactor: 0.55,
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
          padding: EdgeInsets.symmetric(horizontal: esMovil ? 24 : 48, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (esMovil) ...[
                    Center(
                        child: Image.asset('assets/Logo.png',
                            width: 140, fit: BoxFit.contain)),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    "¿Pa'onde vamos hoy?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: AppColors.verdeClaro),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu correo electrónico.';
                      }
                      if (!valor.contains('@') || !valor.contains('.')) {
                        return 'Ingresa un correo válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _contrasenaOculta,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.verdeClaro),
                      // Botón de ojo idéntico a Figma: alterna dinámicamente
                      // la visibilidad del texto de la contraseña.
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
                        return 'Ingresa tu contraseña.';
                      }
                      if (valor.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _enviar(),
                  ),
                  const SizedBox(height: 32),
                  auth.cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _enviar,
                          child: const Text('Acceder'),
                        ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/registro'),
                    child: const Text('¿No tienes cuenta? Regístrate'),
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
