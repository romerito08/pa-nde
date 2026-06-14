import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/imagen_servicio.dart';
import '../../../models/servicio.dart';
import '../../auth/logic/auth_controller.dart';
import '../data/servicio_repository.dart';

/// "Mis Servicios" del Aliado (RF13/RF14): lista en tiempo real los
/// servicios publicados con sus imágenes (URLs), permite crear, editar,
/// pausar/activar y eliminar con confirmación.
class MisServiciosScreen extends StatefulWidget {
  const MisServiciosScreen({super.key});

  @override
  State<MisServiciosScreen> createState() => _MisServiciosScreenState();
}

class _MisServiciosScreenState extends State<MisServiciosScreen> {
  final _repositorio = ServicioRepository();

  Future<void> _cambiarEstado(Servicio servicio) async {
    final pausar = servicio.estadoPublicacion == EstadosPublicacion.activo;
    final nuevoEstado =
        pausar ? EstadosPublicacion.pausado : EstadosPublicacion.pendiente;
    try {
      await _repositorio.cambiarEstadoPublicacion(servicio.id, nuevoEstado);
      if (!mounted) return;
      FeedbackHelper.mostrarExito(
        context,
        pausar
            ? '"${servicio.nombre}" está pausado y ya no es visible en el catálogo.'
            : '"${servicio.nombre}" fue enviado a revisión. El administrador lo aprobará pronto.',
      );
    } on AppException catch (e) {
      if (!mounted) return;
      FeedbackHelper.mostrarError(context, e.mensaje);
    }
  }

  Future<void> _eliminar(Servicio servicio) async {
    final confirmado = await FeedbackHelper.confirmar(
      context,
      titulo: 'Eliminar servicio',
      mensaje:
          '¿Seguro que quieres eliminar "${servicio.nombre}"? También se borrarán sus reseñas y su calendario. Esta acción no se puede deshacer.',
      textoConfirmar: 'Sí, eliminar',
    );
    if (!confirmado || !mounted) return;
    try {
      await _repositorio.eliminar(servicio.id);
      if (!mounted) return;
      FeedbackHelper.mostrarExito(context, 'Servicio eliminado del catálogo.');
    } on AppException catch (e) {
      if (!mounted) return;
      FeedbackHelper.mostrarError(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer:
              esMovil ? const AppDrawer(rutaActual: '/aliado/servicios') : null,
          appBar: esMovil
              ? const AppHeader(rutaActual: '/aliado/servicios', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(
                      rutaActual: '/aliado/servicios', esMovil: false),
                _hero(esMovil),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('Mis Servicios',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/aliado/publicar'),
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 18),
                                label: const Text('Nueva Publicación'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (!(auth.usuario?.esAliado ?? false))
                            _accesoRestringido(context)
                          else
                            _cuadricula(
                                auth.usuario!.uid, constraints.maxWidth),
                          const SizedBox(height: 40),
                          AppFooter(esMovil: esMovil),
                        ],
                      ),
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
          height: esMovil ? 150 : 240,
          width: double.infinity,
          child: Image.asset('assets/Encabezado.png', fit: BoxFit.cover),
        ),
        Container(
          height: esMovil ? 150 : 240,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Optimiza tu alcance y conecta\ncon la comunidad Pa\'onde',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: esMovil ? 20 : 32,
                fontWeight: FontWeight.w700,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black87)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accesoRestringido(BuildContext context) {
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
            'Esta sección es solo para Aliados. Inicia sesión con una cuenta de Aliado o regístrate.',
            textAlign: TextAlign.center,
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

  Widget _cuadricula(String aliadoId, double anchoPantalla) {
    return StreamBuilder<List<Servicio>>(
      stream: _repositorio.serviciosDe(aliadoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No pudimos cargar tus servicios. Verifica tu conexión.',
                style: TextStyle(color: AppColors.blanco),
              ),
            ),
          );
        }
        final servicios = snapshot.data ?? [];
        if (servicios.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.add_business_outlined,
                    color: AppColors.verdeClaro, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Aún no has publicado servicios. ¡Crea tu primera publicación con el stepper!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.blanco, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/aliado/publicar'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Publicar servicio'),
                ),
              ],
            ),
          );
        }

        int columnas = 3;
        if (anchoPantalla < 700) {
          columnas = 1;
        } else if (anchoPantalla < 1000) {
          columnas = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 300 / 330,
          ),
          itemCount: servicios.length,
          itemBuilder: (context, indice) =>
              _tarjetaServicio(servicios[indice]),
        );
      },
    );
  }

  Widget _tarjetaServicio(Servicio servicio) {
    final activo = servicio.estadoPublicacion == EstadosPublicacion.activo;
    final pendiente = servicio.estadoPublicacion == EstadosPublicacion.pendiente;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: servicio.imagenPrincipal.isEmpty
                ? Container(
                    color: AppColors.verdeOscuro,
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 40, color: AppColors.verdeClaro),
                    ),
                  )
                : ImagenServicio(
                    url: servicio.imagenPrincipal,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => Container(
                      color: AppColors.verdeOscuro,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 36, color: AppColors.verdeClaro),
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.verdeClaro),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          servicio.ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.verdeClaro, fontSize: 11),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: activo
                              ? AppColors.exito
                              : pendiente
                                  ? AppColors.advertencia
                                  : AppColors.verdeClaro,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        servicio.estadoPublicacion,
                        style: TextStyle(
                          color: activo
                              ? AppColors.exito
                              : pendiente
                                  ? AppColors.advertencia
                                  : AppColors.verdeClaro,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    servicio.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.blanco,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      servicio.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.verdeClaro, fontSize: 12),
                    ),
                  ),
                  Text(
                    '\$${servicio.precio.toStringAsFixed(0)} / ${servicio.unidadPrecio}',
                    style: const TextStyle(
                        color: AppColors.amarillo,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushNamed(
                                '/aliado/publicar',
                                arguments: servicio),
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30)),
                            child: const Text('Editar',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            onPressed: pendiente
                                ? null
                                : () => _cambiarEstado(servicio),
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30)),
                            child: Text(
                              pendiente
                                  ? 'En revisión'
                                  : (activo ? 'Pausar' : 'Reenviar'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 30,
                        width: 34,
                        child: OutlinedButton(
                          onPressed: () => _eliminar(servicio),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(34, 30),
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
