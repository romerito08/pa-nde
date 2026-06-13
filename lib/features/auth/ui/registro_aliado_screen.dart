import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/utils/validadores.dart';
import '../../../core/widgets/selector_geografico.dart';
import '../../../models/usuario.dart';
import '../logic/auth_controller.dart';

/// Página dedicada "Sé un Aliado", accesible exclusivamente desde el footer
/// de la Landing Page: presenta los beneficios comerciales de aliarse con
/// Pa'onde y contiene el formulario de registro de Aliados (Proveedores).
class RegistroAliadoScreen extends StatefulWidget {
  const RegistroAliadoScreen({super.key});

  @override
  State<RegistroAliadoScreen> createState() => _RegistroAliadoScreenState();
}

class _RegistroAliadoScreenState extends State<RegistroAliadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _estadoSeleccionado;
  String? _municipioSeleccionado;
  bool _contrasenaOculta = true;

  static const _beneficios = [
    (
      icono: Icons.storefront_outlined,
      titulo: 'Vitrina sin comisiones de entrada',
      detalle:
          'Publica alojamientos y experiencias en minutos y llega a toda la '
          'comunidad de exploradores sin costos fijos de afiliación.',
    ),
    (
      icono: Icons.calendar_month_outlined,
      titulo: 'Reservas y calendario automáticos',
      detalle:
          'Tu disponibilidad se gestiona sola: el sistema bloquea fechas '
          'reservadas y recibe pagos confirmados sin que tengas que aprobar '
          'cada solicitud.',
    ),
    (
      icono: Icons.query_stats_outlined,
      titulo: 'Dashboard con métricas reales',
      detalle:
          'Sigue tus ganancias, reservas y satisfacción de clientes con '
          'gráficos en tiempo real, y responde cotizaciones desde tu bandeja '
          'de entrada.',
    ),
    (
      icono: Icons.eco_outlined,
      titulo: 'Turismo sostenible y local',
      detalle:
          'Forma parte de una red que impulsa el turismo low-cost responsable '
          'y visibiliza a los emprendedores de cada rincón de Venezuela.',
    ),
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _telefonoController.dispose();
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
      telefono: _telefonoController.text,
      estado: _estadoSeleccionado!,
      municipio: _municipioSeleccionado!,
      rol: RolesUsuario.aliado,
    );

    if (!mounted) return;
    if (exito) {
      FeedbackHelper.mostrarExito(
          context, '¡Bienvenido, Aliado! Tu panel está listo.');
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
      appBar: AppBar(title: const Text('Sé un Aliado')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final esMovil = constraints.maxWidth < 900;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: esMovil ? 16 : 40, vertical: 32),
                  child: esMovil
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _panelBeneficios(),
                            const SizedBox(height: 32),
                            _formulario(esMovil),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _panelBeneficios()),
                            const SizedBox(width: 40),
                            Expanded(child: _formulario(esMovil)),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _panelBeneficios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Haz crecer tu negocio\ncon Pa\'onde',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        const Text(
          'Conecta tu alojamiento o experiencia con miles de exploradores '
          'que buscan turismo low-cost y sostenible.',
          style: TextStyle(
              color: AppColors.verdeClaro, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 28),
        ..._beneficios.map(
          (beneficio) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.amarillo,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(beneficio.icono, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficio.titulo,
                        style: const TextStyle(
                            color: AppColors.blanco,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        beneficio.detalle,
                        style: const TextStyle(
                            color: AppColors.verdeClaro,
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _formulario(bool esMovil) {
    final auth = context.watch<AuthController>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amarillo.withValues(alpha: 0.4)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Registro de Aliado',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _campoTexto('Nombre', _nombreController)),
                const SizedBox(width: 16),
                Expanded(child: _campoTexto('Apellido', _apellidoController)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.blanco),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico comercial',
                prefixIcon:
                    Icon(Icons.email_outlined, color: AppColors.verdeClaro),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa tu correo electrónico.';
                }
                if (!Validadores.esCorreoValido(valor)) {
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
                prefixIcon:
                    const Icon(Icons.lock_outline, color: AppColors.verdeClaro),
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
                  onPressed: () =>
                      setState(() => _contrasenaOculta = !_contrasenaOculta),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.blanco),
              decoration: const InputDecoration(
                labelText: 'Teléfono de contacto',
                hintText: '0414-1234567',
                prefixIcon:
                    Icon(Icons.phone_outlined, color: AppColors.verdeClaro),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa tu teléfono de contacto.';
                }
                if (!Validadores.esTelefonoValido(valor)) {
                  return 'Formato inválido. Ej.: 0414-1234567';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SelectorGeografico(
              estado: _estadoSeleccionado,
              municipio: _municipioSeleccionado,
              enFila: !esMovil,
              onChanged: (estado, municipio) => setState(() {
                _estadoSeleccionado = estado;
                _municipioSeleccionado = municipio;
              }),
            ),
            const SizedBox(height: 28),
            auth.cargando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _enviar,
                    icon: const Icon(Icons.handshake_outlined, size: 18),
                    label: const Text('Convertirme en Aliado'),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
            ),
          ],
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
        if (valor == null || valor.trim().isEmpty) {
          return 'Campo obligatorio.';
        }
        return null;
      },
    );
  }
}
