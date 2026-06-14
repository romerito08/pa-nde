import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../../models/cotizacion.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/quotes_controller.dart';

class AliadoCotizacionesScreen extends StatelessWidget {
  const AliadoCotizacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          drawer: esMovil
              ? const AppDrawer(rutaActual: '/aliado/cotizaciones')
              : null,
          appBar: esMovil
              ? const AppHeader(
                  rutaActual: '/aliado/cotizaciones', esMovil: true)
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(
                      rutaActual: '/aliado/cotizaciones', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Bandeja de cotizaciones',
                              style:
                                  Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 8),
                          const Text(
                            'Revisa las solicitudes de los exploradores y respóndelas con tu feedback.',
                            style: TextStyle(color: AppColors.verdeClaro),
                          ),
                          const SizedBox(height: 24),
                          if (!(auth.usuario?.esAliado ?? false))
                            _accesoRestringido(context)
                          else
                            _bandeja(context, auth.usuario!.uid),
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
            'Esta sección es solo para Aliados.',
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

  Widget _bandeja(BuildContext context, String aliadoId) {
    final controlador = context.watch<QuotesController>();

    return StreamBuilder<List<Cotizacion>>(
      stream: controlador.bandejaDeAliado(aliadoId),
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
                'No pudimos cargar tu bandeja. Verifica tu conexión.',
                style: TextStyle(color: AppColors.blanco),
              ),
            ),
          );
        }
        final cotizaciones = snapshot.data ?? [];
        if (cotizaciones.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No tienes solicitudes de cotización por ahora.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blanco, fontSize: 16),
              ),
            ),
          );
        }
        return Column(
          children: cotizaciones
              .map((cotizacion) => _TarjetaCotizacion(cotizacion: cotizacion))
              .toList(),
        );
      },
    );
  }
}

class _TarjetaCotizacion extends StatelessWidget {
  final Cotizacion cotizacion;

  const _TarjetaCotizacion({required this.cotizacion});

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<QuotesController>();
    final procesando = controlador.estaProcesando(cotizacion.id);
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final colorEstado = AppColors.colorDeCotizacion(cotizacion.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: servicio + badge de estado
          Row(
            children: [
              Expanded(
                child: Text(
                  cotizacion.servicioNombre,
                  style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorEstado),
                ),
                child: Text(
                  cotizacion.estado,
                  style: TextStyle(
                      color: colorEstado,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'De: ${cotizacion.usuarioNombre} · ${cotizacion.huespedes} persona(s)'
            '${cotizacion.fechaInicio == null ? '' : ' · ${formatoFecha.format(cotizacion.fechaInicio!)}'}'
            '${cotizacion.fechaFin == null ? '' : ' → ${formatoFecha.format(cotizacion.fechaFin!)}'}',
            style: const TextStyle(color: AppColors.verdeClaro, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Mensaje inicial del explorador
          _burbuja(
            label: 'Mensaje del explorador:',
            texto: cotizacion.mensaje,
          ),

          // Contra-mensaje del explorador (rondas 2+)
          if (cotizacion.mensajeExplorador.isNotEmpty) ...[
            const SizedBox(height: 10),
            _burbuja(
              label: 'Nueva respuesta del explorador:',
              texto: cotizacion.mensajeExplorador,
              destacado: true,
            ),
          ],

          // Feedback ya enviado por el aliado
          if (!cotizacion.turnoAliado || cotizacion.esFinal) ...[
            const SizedBox(height: 10),
            _panelFeedbackPropio(),
          ],

          const SizedBox(height: 12),

          // Acción
          if (cotizacion.esFinal)
            const SizedBox.shrink()
          else if (procesando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator()),
              ),
            )
          else if (cotizacion.turnoAliado)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _abrirFormularioRespuesta(context),
                icon: const Icon(Icons.reply_outlined, size: 16),
                label: const Text('Responder'),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Esperando la respuesta del explorador…',
                style: TextStyle(
                    color: AppColors.advertencia.withValues(alpha: 0.85),
                    fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _burbuja({
    required String label,
    required String texto,
    bool destacado = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: destacado
            ? AppColors.amarillo.withValues(alpha: 0.1)
            : AppColors.verdeOscuro,
        borderRadius: BorderRadius.circular(10),
        border: destacado
            ? Border.all(color: AppColors.amarillo.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: destacado ? AppColors.amarillo : AppColors.verdeClaro,
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '"$texto"',
            style: const TextStyle(
                color: AppColors.blanco, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _panelFeedbackPropio() {
    final color = AppColors.colorDeCotizacion(cotizacion.estado);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu feedback (${cotizacion.estado}):',
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            cotizacion.feedback,
            style: const TextStyle(
                color: AppColors.blanco, fontSize: 14, height: 1.4),
          ),
          if (cotizacion.precioPropuesto != null) ...[
            const SizedBox(height: 6),
            Text(
              'Precio propuesto: \$${cotizacion.precioPropuesto!.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: AppColors.amarillo,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  void _abrirFormularioRespuesta(BuildContext context) {
    final quotes = context.read<QuotesController>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: quotes,
        child: _ResponderCotizacionDialog(cotizacion: cotizacion),
      ),
    );
  }
}

class _ResponderCotizacionDialog extends StatefulWidget {
  final Cotizacion cotizacion;

  const _ResponderCotizacionDialog({required this.cotizacion});

  @override
  State<_ResponderCotizacionDialog> createState() =>
      _ResponderCotizacionDialogState();
}

class _ResponderCotizacionDialogState
    extends State<_ResponderCotizacionDialog> {
  final _feedbackController = TextEditingController();
  final _precioController = TextEditingController();
  String _estadoSeleccionado = EstadosCotizacion.aceptada;
  String? _error;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    // Pre-rellenar precio si ya había una propuesta anterior
    if (widget.cotizacion.precioPropuesto != null) {
      _precioController.text =
          widget.cotizacion.precioPropuesto!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _responder() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      setState(() => _error = 'El feedback para el explorador es obligatorio.');
      return;
    }
    double? precio;
    if (_precioController.text.trim().isNotEmpty) {
      precio = double.tryParse(_precioController.text.replaceAll(',', '.'));
      if (precio == null || precio <= 0) {
        setState(() => _error = 'El precio propuesto no es válido.');
        return;
      }
    }
    if (_estadoSeleccionado == EstadosCotizacion.contrapropuesta &&
        precio == null) {
      setState(() =>
          _error = 'Para una contrapropuesta indica el precio sugerido.');
      return;
    }

    setState(() {
      _enviando = true;
      _error = null;
    });
    final mensajeError = await context.read<QuotesController>().responder(
          cotizacion: widget.cotizacion,
          nuevoEstado: _estadoSeleccionado,
          feedback: feedback,
          precioPropuesto: precio,
        );
    if (!mounted) return;
    if (mensajeError == null) {
      Navigator.of(context).pop();
      final mensaje = switch (_estadoSeleccionado) {
        EstadosCotizacion.aceptada =>
          'Cotización aceptada. El explorador ya puede reservar.',
        EstadosCotizacion.rechazada =>
          'Cotización rechazada. El explorador fue notificado.',
        _ =>
          'Contrapropuesta enviada. Esperando la respuesta del explorador.',
      };
      FeedbackHelper.mostrarExito(context, mensaje);
    } else {
      setState(() {
        _enviando = false;
        _error = mensajeError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Responder a ${widget.cotizacion.usuarioNombre}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _estadoSeleccionado,
              isExpanded: true,
              dropdownColor: AppColors.verde,
              decoration: const InputDecoration(labelText: 'Decisión'),
              items: EstadosCotizacion.respuestasAliado
                  .map((estado) => DropdownMenuItem(
                        value: estado,
                        child: Text(
                          estado == EstadosCotizacion.contrapropuesta
                              ? 'Sugerir cambios (contrapropuesta)'
                              : estado,
                          style: const TextStyle(color: AppColors.blanco),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: _enviando
                  ? null
                  : (valor) {
                      if (valor != null) {
                        setState(() => _estadoSeleccionado = valor);
                      }
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              enabled: !_enviando,
              style: const TextStyle(color: AppColors.blanco),
              decoration: const InputDecoration(
                labelText: 'Feedback para el explorador',
                hintText:
                    'Ej.: Puedo ofrecerte esas fechas con 10% de descuento si pagan completo…',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioController,
              enabled: !_enviando,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.blanco),
              decoration: const InputDecoration(
                labelText: 'Precio total en USD',
                hintText: 'Obligatorio para contrapropuesta',
                prefixIcon: Icon(Icons.attach_money,
                    color: AppColors.verdeClaro, size: 20),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.verdeClaro)),
        ),
        _enviando
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                    width: 22, height: 22, child: CircularProgressIndicator()),
              )
            : ElevatedButton.icon(
                onPressed: _responder,
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Enviar respuesta'),
              ),
      ],
    );
  }
}
