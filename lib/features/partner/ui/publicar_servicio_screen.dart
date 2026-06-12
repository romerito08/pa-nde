import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/paonde_stepper.dart';
import '../../../models/servicio.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/publicacion_controller.dart';

/// Formulario de creación/edición de servicios (RF04/RF13/RF14) en stepper
/// lineal continuo de 4 pasos reales — Identidad, Costos, Ubicación y
/// Éxito — controlado por el botón "Siguiente", con el componente visual de
/// stepper del design system de Figma.
class PublicarServicioScreen extends StatelessWidget {
  /// Servicio a editar; `null` para crear uno nuevo.
  final Servicio? servicio;

  const PublicarServicioScreen({super.key, this.servicio});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicacionController(servicioInicial: servicio),
      child: const _ContenidoStepper(),
    );
  }
}

class _ContenidoStepper extends StatelessWidget {
  const _ContenidoStepper();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<PublicacionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controlador.esEdicion
            ? 'Editar servicio'
            : 'Publicar nuevo servicio'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaondeStepper(
                  pasos: PublicacionController.pasos,
                  pasoActual: controlador.pasoActual,
                ),
                const SizedBox(height: 32),
                _pasoActivo(context, controlador),
                if (controlador.errorPaso != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(controlador.errorPaso!,
                              style:
                                  const TextStyle(color: AppColors.blanco)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _botonera(context, controlador),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pasoActivo(BuildContext context, PublicacionController controlador) {
    switch (controlador.pasoActual) {
      case 0:
        return _pasoIdentidad(context, controlador);
      case 1:
        return _pasoCostos(context, controlador);
      case 2:
        return _pasoUbicacion(context, controlador);
      default:
        return _pasoExito(context, controlador);
    }
  }

  // --- PASO 1: IDENTIDAD ---
  Widget _pasoIdentidad(
      BuildContext context, PublicacionController controlador) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Identidad del servicio',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Cuéntale a los exploradores qué ofreces.',
          style: TextStyle(color: AppColors.verdeClaro),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controlador.nombreController,
          style: const TextStyle(color: AppColors.blanco),
          decoration: const InputDecoration(labelText: 'Nombre del servicio'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: controlador.tipo,
          dropdownColor: AppColors.verde,
          decoration: const InputDecoration(labelText: 'Tipo de servicio'),
          items: TiposServicio.todos
              .map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo,
                        style: const TextStyle(color: AppColors.blanco)),
                  ))
              .toList(),
          onChanged: (valor) {
            if (valor != null) {
              context.read<PublicacionController>().cambiarTipo(valor);
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controlador.descripcionController,
          maxLines: 4,
          style: const TextStyle(color: AppColors.blanco),
          decoration: const InputDecoration(
              labelText: 'Descripción (mínimo 20 caracteres)'),
        ),
        const SizedBox(height: 24),
        Text('Imágenes (URLs)',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controlador.imagenUrlController,
                style: const TextStyle(color: AppColors.blanco),
                decoration: const InputDecoration(
                    labelText: 'https://ejemplo.com/foto.jpg'),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                final advertencia =
                    context.read<PublicacionController>().agregarImagen();
                if (advertencia != null) {
                  FeedbackHelper.mostrarAdvertencia(context, advertencia);
                }
              },
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controlador.imagenes.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controlador.imagenes.length,
              separatorBuilder: (context, _) => const SizedBox(width: 10),
              itemBuilder: (context, indice) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        controlador.imagenes[indice],
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Container(
                          width: 120,
                          height: 90,
                          color: AppColors.verde,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppColors.verdeClaro),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () => context
                            .read<PublicacionController>()
                            .quitarImagen(indice),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  // --- PASO 2: COSTOS ---
  Widget _pasoCostos(BuildContext context, PublicacionController controlador) {
    final esExperiencia = controlador.tipo == TiposServicio.experiencia;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Costos y capacidad',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          esExperiencia
              ? 'Las experiencias se cobran por persona.'
              : 'Los alojamientos se cobran por noche.',
          style: const TextStyle(color: AppColors.verdeClaro),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controlador.precioController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.blanco),
          decoration: InputDecoration(
            labelText:
                'Precio en USD por ${esExperiencia ? 'persona' : 'noche'}',
            prefixIcon: const Icon(Icons.attach_money,
                color: AppColors.verdeClaro, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controlador.capacidadController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.blanco),
          decoration: const InputDecoration(
            labelText: 'Capacidad máxima (personas)',
            prefixIcon:
                Icon(Icons.group_outlined, color: AppColors.verdeClaro, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.verde,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.amarillo, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Las reservas que comienzan viernes o sábado aplican un recargo automático del 15 % (tarifa de fin de semana).',
                  style: TextStyle(color: AppColors.blanco, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PASO 3: UBICACIÓN ---
  Widget _pasoUbicacion(
      BuildContext context, PublicacionController controlador) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Ubicación', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          '¿Dónde encontrarán tu servicio los exploradores?',
          style: TextStyle(color: AppColors.verdeClaro),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controlador.ciudadController,
          style: const TextStyle(color: AppColors.blanco),
          decoration: const InputDecoration(
            labelText: 'Ciudad',
            prefixIcon: Icon(Icons.location_city_outlined,
                color: AppColors.verdeClaro, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controlador.direccionController,
          style: const TextStyle(color: AppColors.blanco),
          decoration: const InputDecoration(
            labelText: 'Dirección o punto de referencia',
            prefixIcon: Icon(Icons.location_on_outlined,
                color: AppColors.verdeClaro, size: 20),
          ),
        ),
      ],
    );
  }

  // --- PASO 4: ÉXITO ---
  Widget _pasoExito(BuildContext context, PublicacionController controlador) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.amarillo,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 56, color: Colors.black),
        ),
        const SizedBox(height: 24),
        Text(
          controlador.esEdicion
              ? '¡Cambios guardados!'
              : '¡Servicio publicado!',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '"${controlador.nombreController.text}" ya está ${controlador.esEdicion ? 'actualizado' : 'visible'} en el catálogo de Pa\'onde.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.verdeClaro, fontSize: 15),
        ),
      ],
    );
  }

  Widget _botonera(BuildContext context, PublicacionController controlador) {
    if (controlador.enPasoExito) {
      return ElevatedButton.icon(
        onPressed: () => Navigator.of(context)
            .pushNamedAndRemoveUntil('/aliado/servicios', (route) => false),
        icon: const Icon(Icons.grid_view_outlined, size: 18),
        label: const Text('Ver mis servicios'),
      );
    }

    return Row(
      children: [
        if (controlador.pasoActual > 0)
          OutlinedButton.icon(
            onPressed: controlador.guardando
                ? null
                : () => context.read<PublicacionController>().atras(),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Atrás'),
          ),
        const Spacer(),
        controlador.guardando
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                    width: 28, height: 28, child: CircularProgressIndicator()),
              )
            : ElevatedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthController>();
                  final avanzo = await context
                      .read<PublicacionController>()
                      .siguiente(auth.usuario);
                  if (!context.mounted) return;
                  if (avanzo &&
                      context.read<PublicacionController>().enPasoExito) {
                    FeedbackHelper.mostrarExito(
                        context, 'Servicio guardado en Firestore.');
                  }
                },
                icon: Icon(
                  controlador.pasoActual == 2
                      ? Icons.cloud_upload_outlined
                      : Icons.arrow_forward,
                  size: 18,
                ),
                label: Text(controlador.pasoActual == 2
                    ? 'Guardar y finalizar'
                    : 'Siguiente'),
              ),
      ],
    );
  }
}
