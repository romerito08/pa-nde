import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/utils/validadores.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/selector_geografico.dart';
import '../../auth/logic/auth_controller.dart';

/// Pantalla de Perfil con edición real (Explorador y Aliado): nombre,
/// apellido, teléfono y ubicación estandarizada se modifican y persisten en
/// el documento de la colección `usuarios` a través del AuthController.
/// El correo y el rol son de solo lectura.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _estadoSeleccionado;
  String? _municipioSeleccionado;
  bool _camposCargados = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _cargarCampos() {
    if (_camposCargados) return;
    final usuario = context.read<AuthController>().usuario;
    if (usuario == null) return;
    _nombreController.text = usuario.nombre;
    _apellidoController.text = usuario.apellido;
    _telefonoController.text = usuario.telefono;
    _estadoSeleccionado =
        usuario.estado.isEmpty ? null : usuario.estado;
    _municipioSeleccionado =
        usuario.municipio.isEmpty ? null : usuario.municipio;
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
    final exito = await auth.actualizarPerfil(
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      telefono: _telefonoController.text,
      estado: _estadoSeleccionado!,
      municipio: _municipioSeleccionado!,
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          // Correo de solo lectura: es la identidad de la cuenta en Auth.
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nombreController,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Campo obligatorio.'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _apellidoController,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Campo obligatorio.'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppColors.blanco),
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              hintText: '0414-1234567',
              prefixIcon:
                  Icon(Icons.phone_outlined, color: AppColors.verdeClaro),
            ),
            validator: (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Ingresa tu teléfono.';
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
