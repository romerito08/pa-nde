import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/app_header.dart';
import '../../../models/reserva.dart';
import '../logic/mis_reservas_controller.dart';

/// Pasarela de pagos (RF08): resumen de la reserva aceptada, selección de
/// método y ejecución del mock de PayPal. Si la simulación responde éxito,
/// el callback actualiza el documento a "Pagado" automáticamente y se
/// muestra el comprobante; si falla, se informa con un diálogo amigable.
class CheckoutScreen extends StatefulWidget {
  final Reserva reserva;

  const CheckoutScreen({super.key, required this.reserva});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodoSeleccionado = 'PayPal';
  bool _procesando = false;

  static const _metodos = ['PayPal', 'Tarjeta de Crédito', 'Transferencia'];

  Future<void> _pagar() async {
    setState(() => _procesando = true);

    final resultado = await context
        .read<MisReservasController>()
        .pagar(widget.reserva, _metodoSeleccionado);

    if (!mounted) return;
    setState(() => _procesando = false);

    if (resultado.exitoso) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('✅ ¡Pago aprobado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Tu reserva en "${widget.reserva.servicioNombre}" quedó en estado Pagado.'),
              const SizedBox(height: 12),
              Text('Método: ${resultado.metodo}',
                  style: const TextStyle(color: AppColors.verdeClaro)),
              Text('Monto: \$${resultado.monto.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.verdeClaro)),
              Text('Autorización: ${resultado.codigoAutorizacion}',
                  style: const TextStyle(color: AppColors.verdeClaro)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Volver a mis reservas'),
            ),
          ],
        ),
      );
    } else {
      FeedbackHelper.mostrarError(
        context,
        resultado.mensajeError ??
            'El pago fue rechazado. Intenta con otro método.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 850;
        return Scaffold(
          appBar: esMovil
              ? AppBar(title: const Text('Completa tu pago'))
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!esMovil)
                  const AppHeader(rutaActual: '/checkout', esMovil: false),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: esMovil ? 16 : 40, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Completa tu pago',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 32),
                          if (esMovil)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _resumenReserva(formatoFecha),
                                const SizedBox(height: 24),
                                _pasarela(),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _resumenReserva(formatoFecha)),
                                const SizedBox(width: 32),
                                Expanded(child: _pasarela()),
                              ],
                            ),
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

  Widget _resumenReserva(DateFormat formatoFecha) {
    final reserva = widget.reserva;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reserva.servicioImagen.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reserva.servicioImagen,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            reserva.servicioNombre,
            style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 22,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            reserva.servicioUbicacion,
            style: const TextStyle(color: AppColors.verdeClaro, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _datoFecha('Check-in',
                    formatoFecha.format(reserva.fechaInicio)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _datoFecha('Check-out', formatoFecha.format(reserva.fechaFin)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Huéspedes: ${reserva.huespedes}',
            style: const TextStyle(color: AppColors.blanco, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _datoFecha(String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.verdeOscuro,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  const TextStyle(color: AppColors.verdeClaro, fontSize: 12)),
          const SizedBox(height: 2),
          Text(valor,
              style: const TextStyle(
                  color: AppColors.blanco,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _pasarela() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pasarela de pago',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text(
            'Total a cobrar: \$${widget.reserva.total.toStringAsFixed(2)}',
            style: const TextStyle(
                color: AppColors.amarillo,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _metodoSeleccionado,
            dropdownColor: AppColors.verde,
            decoration: const InputDecoration(labelText: 'Método de pago'),
            items: _metodos
                .map((metodo) => DropdownMenuItem(
                      value: metodo,
                      child: Text(metodo,
                          style: const TextStyle(color: AppColors.blanco)),
                    ))
                .toList(),
            onChanged: _procesando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() => _metodoSeleccionado = valor);
                    }
                  },
          ),
          const SizedBox(height: 24),
          if (_metodoSeleccionado == 'PayPal') ...[
            // Botón con la identidad visual de PayPal, como en el prototipo.
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD200),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pagar con ',
                        style: TextStyle(
                            color: Color(0xFF003087),
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text('Pay',
                        style: TextStyle(
                            color: Color(0xFF003087),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 19)),
                    Text('Pal',
                        style: TextStyle(
                            color: Color(0xFF0079C1),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 19)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _procesando
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _pagar,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text('Pagar \$${widget.reserva.total.toStringAsFixed(2)} con $_metodoSeleccionado'),
                ),
          const SizedBox(height: 12),
          const Text(
            'Pago simulado con fines académicos: la pasarela responde como el sandbox de PayPal.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.verdeClaro, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
