import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/review_controller.dart';

/// Sección de comentarios de la vista de detalle (RF06): desplegable
/// numérico de estrellas, campo de texto y botón "Enviar Comentario" que
/// impacta la subcolección, limpia el campo y recalcula el promedio en vivo.
/// El formulario sólo se muestra si el usuario tiene al menos una reserva
/// en estado "Disfrutado" para este servicio.
class ReviewSection extends StatefulWidget {
  const ReviewSection({super.key});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  String? _ultimoUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthController>().usuario?.uid;
    if (uid != _ultimoUid) {
      _ultimoUid = uid;
      context.read<ReviewController>().verificarPermiso(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<ReviewController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reseñas de otros exploradores',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _formularioOAviso(context, controlador),
        const SizedBox(height: 24),
        _lista(controlador),
      ],
    );
  }

  Widget _formularioOAviso(BuildContext context, ReviewController controlador) {
    if (!controlador.puedeResenar) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.verde,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline,
                color: AppColors.verdeClaro, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Solo puedes dejar una reseña una vez que hayas disfrutado este servicio.',
                style: TextStyle(color: AppColors.verdeClaro, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  '¿Qué tal fue tu experiencia?',
                  style: TextStyle(
                      color: AppColors.blanco,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
              ),
              DropdownButton<int>(
                value: controlador.calificacionSeleccionada,
                dropdownColor: AppColors.verde,
                underline: const SizedBox.shrink(),
                items: List.generate(5, (i) {
                  final valor = i + 1;
                  return DropdownMenuItem(
                    value: valor,
                    child: Row(
                      children: [
                        Text('$valor ',
                            style: const TextStyle(color: AppColors.blanco)),
                        const Icon(Icons.star,
                            color: AppColors.amarillo, size: 18),
                      ],
                    ),
                  );
                }),
                onChanged: (valor) {
                  if (valor != null) {
                    context
                        .read<ReviewController>()
                        .seleccionarCalificacion(valor);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controlador.comentarioController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.blanco),
            decoration: const InputDecoration(
              hintText: 'Escribe tu opinión aquí...',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: controlador.enviando
                ? const SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: () async {
                      final auth = context.read<AuthController>();
                      final mensajeError = await context
                          .read<ReviewController>()
                          .enviarComentario(auth.usuario);
                      if (!context.mounted) return;
                      if (mensajeError == null) {
                        FeedbackHelper.mostrarExito(
                            context, '¡Gracias por compartir tu opinión!');
                      } else {
                        FeedbackHelper.mostrarError(context, mensajeError);
                      }
                    },
                    icon: const Icon(Icons.send_outlined, size: 16),
                    label: const Text('Enviar Comentario'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _lista(ReviewController controlador) {
    if (controlador.cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controlador.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(controlador.error!,
            style: const TextStyle(color: AppColors.error)),
      );
    }
    if (controlador.resenas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Aún no hay reseñas. ¡Sé el primero en opinar!',
          style: TextStyle(
              color: AppColors.verdeClaro, fontStyle: FontStyle.italic),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controlador.resenas.length,
      separatorBuilder: (context, _) => const SizedBox(height: 20),
      itemBuilder: (context, indice) {
        final resena = controlador.resenas[indice];
        return Row(
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
                  const Icon(Icons.person_outline, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          resena.nombreUsuario,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.blanco,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                      ),
                      Text(
                        resena.fechaFormateada,
                        style: const TextStyle(
                            color: AppColors.verdeClaro, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (estrella) {
                      return Icon(
                        estrella < resena.calificacion
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.amarillo,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resena.texto,
                    style: const TextStyle(
                        color: AppColors.blanco, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
