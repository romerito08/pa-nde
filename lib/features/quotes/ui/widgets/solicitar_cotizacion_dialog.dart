import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/servicio.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../logic/quotes_controller.dart';

/// Diálogo "Solicitar una Cotización": el Explorador describe lo que
/// necesita (con las fechas que haya marcado en el calendario, si las hay) y
/// la solicitud se crea en la colección `cotizaciones`. Devuelve `true` por
/// el Navigator cuando la solicitud fue enviada con éxito.
class SolicitarCotizacionDialog extends StatefulWidget {
  final Servicio servicio;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int huespedes;

  const SolicitarCotizacionDialog({
    super.key,
    required this.servicio,
    required this.fechaInicio,
    required this.fechaFin,
    required this.huespedes,
  });

  @override
  State<SolicitarCotizacionDialog> createState() =>
      _SolicitarCotizacionDialogState();
}

class _SolicitarCotizacionDialogState
    extends State<SolicitarCotizacionDialog> {
  final _mensajeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final auth = context.read<AuthController>();
    final mensajeError = await context.read<QuotesController>().solicitar(
          usuario: auth.usuario,
          servicio: widget.servicio,
          mensaje: _mensajeController.text,
          huespedes: widget.huespedes,
          fechaInicio: widget.fechaInicio,
          fechaFin: widget.fechaFin,
        );
    if (!mounted) return;
    if (mensajeError == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = mensajeError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enviando = context.watch<QuotesController>().enviandoSolicitud;
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: const Text('Solicitar una Cotización'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.servicio.nombre,
              style: const TextStyle(
                  color: AppColors.amarillo,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              widget.fechaInicio == null
                  ? 'Sin fechas seleccionadas (el aliado te propondrá opciones).'
                  : 'Fechas tentativas: ${formatoFecha.format(widget.fechaInicio!)}'
                      '${widget.fechaFin == null ? '' : ' → ${formatoFecha.format(widget.fechaFin!)}'}'
                      ' · ${widget.huespedes} persona(s)',
              style:
                  const TextStyle(color: AppColors.verdeClaro, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mensajeController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.blanco),
              decoration: const InputDecoration(
                labelText: '¿Qué necesitas?',
                hintText:
                    'Ej.: Somos 4 estudiantes, ¿hay descuento por grupo para ese fin de semana?',
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
          onPressed:
              enviando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.verdeClaro)),
        ),
        enviando
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                    width: 22, height: 22, child: CircularProgressIndicator()),
              )
            : ElevatedButton.icon(
                onPressed: _enviar,
                icon: const Icon(Icons.request_quote_outlined, size: 16),
                label: const Text('Enviar solicitud'),
              ),
      ],
    );
  }
}
