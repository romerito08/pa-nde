import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/campo_rif.dart';
import '../../../core/widgets/campo_telefono.dart';
import '../../../core/widgets/selector_geografico.dart';
import '../../auth/logic/auth_controller.dart';

/// Pantalla de Perfil con edición real (Explorador y Aliado).
/// Los Aliados ven "Nombre de empresa" + RIF segmentado en lugar de Apellido.
/// Ambos roles usan el selector segmentado de teléfono venezolano.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _paypalEmailController = TextEditingController();

  String _telefonoActual = '';
  String _rifActual = '';
  String? _estadoSeleccionado;
  String? _municipioSeleccionado;
  bool _camposCargados = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _paypalEmailController.dispose();
    super.dispose();
  }

  void _cargarCampos() {
    if (_camposCargados) return;
    final usuario = context.read<AuthController>().usuario;
    if (usuario == null) return;
    _nombreController.text = usuario.nombre;
    _apellidoController.text = usuario.apellido;
    _telefonoActual = usuario.telefono;
    _rifActual = usuario.apellido;
    _estadoSeleccionado = usuario.estado.isEmpty ? null : usuario.estado;
    _municipioSeleccionado =
        usuario.municipio.isEmpty ? null : usuario.municipio;
    _paypalEmailController.text = usuario.paypalEmail;
    _camposCargados = true;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estadoSeleccionado == null || _municipioSeleccionado == null) {
      FeedbackHelper.mostrarAdvertencia(
          context, 'Selecciona tu Estado y Municipio de la lista.');
      return;
    }

    final auth = context.read<AuthController>();
    final esAliado = auth.usuario?.esAliado ?? false;

    final exito = await auth.actualizarPerfil(
      nombre: _nombreController.text,
      apellido: esAliado ? _rifActual : _apellidoController.text,
      telefono: _telefonoActual,
      estado: _estadoSeleccionado!,
      municipio: _municipioSeleccionado!,
      paypalEmail: esAliado ? _paypalEmailController.text.trim() : null,
    );

    if (!mounted) return;
    if (exito) {
      FeedbackHelper.mostrarExito(context, 'Perfil actualizado correctamente.');
    } else {
      FeedbackHelper.mostrarError(
          context, auth.error ?? 'No pudimos guardar los cambios.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    _cargarCampos();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil ? const AppDrawer(rutaActual: '/perfil') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/perfil', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/perfil', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: !auth.autenticado
                          ? _sinSesion(context)
                          : _formulario(auth, esMovil),
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40),
                      child: AppFooter(esMovil: esMovil),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sinSesion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.verdeClaro, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Inicia sesión para ver y editar tu perfil.',
            style: TextStyle(color: AppColors.blanco, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            child: const Text('Acceder'),
          ),
        ],
      ),
    );
  }

  Widget _formulario(AuthController auth, bool esMovil) {
    final usuario = auth.usuario!;
    final esAliado = usuario.esAliado;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar + título
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.amarillo,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: Colors.black, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mi Perfil',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.verde,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.amarillo),
                      ),
                      child: Text(
                        usuario.rol,
                        style: const TextStyle(
                            color: AppColors.amarillo,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Correo — solo lectura
          TextFormField(
            initialValue: usuario.correo,
            readOnly: true,
            enabled: false,
            style: const TextStyle(color: AppColors.verdeClaro),
            decoration: const InputDecoration(
              labelText: 'Correo (no editable)',
              prefixIcon:
                  Icon(Icons.email_outlined, color: AppColors.verdeClaro),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppColors.verde),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (esAliado) ...[
            // Aliado: Nombre de empresa
            TextFormField(
              controller: _nombreController,
              style: const TextStyle(color: AppColors.blanco),
              decoration: const InputDecoration(
                  labelText: 'Nombre de la empresa'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obligatorio.' : null,
            ),
            const SizedBox(height: 16),
            // Aliado: RIF segmentado
            const Text(
              'RIF de la empresa',
              style:
                  TextStyle(color: AppColors.verdeClaro, fontSize: 13),
            ),
            const SizedBox(height: 8),
            CampoRif(
              valorInicial: _rifActual,
              onChanged: (v) => _rifActual = v,
            ),
          ] else ...[
            // Explorador: Nombre + Apellido
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Campo obligatorio.'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _apellidoController,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration:
                        const InputDecoration(labelText: 'Apellido'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Campo obligatorio.'
                        : null,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          // Teléfono segmentado (ambos roles)
          const Text(
            'Teléfono',
            style: TextStyle(color: AppColors.verdeClaro, fontSize: 13),
          ),
          const SizedBox(height: 8),
          CampoTelefono(
            valorInicial: _telefonoActual,
            onChanged: (v) => _telefonoActual = v,
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

          // Sección PayPal — solo visible para aliados
          if (esAliado) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.verde,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF009CDE).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo PayPal
                  Row(
                    children: [
                      const Text(
                        'Pay',
                        style: TextStyle(
                          color: Color(0xFF003087),
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        'Pal',
                        style: TextStyle(
                          color: Color(0xFF009CDE),
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.verdeOscuro,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Cuenta de cobro',
                          style: TextStyle(
                              color: AppColors.verdeClaro, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Correo de tu cuenta PayPal para recibir los pagos de tus reservas.',
                    style: TextStyle(
                        color: AppColors.verdeClaro, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _paypalEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.blanco),
                    decoration: const InputDecoration(
                      labelText: 'Correo de PayPal',
                      hintText: 'tunombre@ejemplo.com',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                          color: Color(0xFF009CDE)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final emailReg = RegExp(
                          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
                      if (!emailReg.hasMatch(v.trim())) {
                        return 'Ingresa un correo válido. Ej.: nombre@ejemplo.com';
                      }
                      return null;
                    },
                  ),
                  if (usuario.paypalEmail.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.exito, size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cuenta vinculada: ${usuario.paypalEmail}',
                            style: const TextStyle(
                                color: AppColors.exito, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),
          auth.cargando
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Guardar cambios'),
                ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final cerrada = await auth.cerrarSesion();
              if (!mounted) return;
              if (cerrada) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              } else {
                FeedbackHelper.mostrarError(
                    context, auth.error ?? 'No fue posible cerrar sesión.');
              }
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
