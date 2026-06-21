import 'dart:async';
import 'dart:math';

/// Respuesta simulada de la pasarela de pagos.
class ResultadoPago {
  final bool exitoso;
  final String? codigoAutorizacion;
  final String? mensajeError;
  final double monto;
  final String metodo;

  const ResultadoPago({
    required this.exitoso,
    required this.monto,
    required this.metodo,
    this.codigoAutorizacion,
    this.mensajeError,
  });
}

/// Mock analítico de la pasarela de pagos (RF08): simula la latencia y las
/// respuestas exitosa/fallida de la API de PayPal. Al recibir éxito ejecuta
/// el callback [alAprobar], que el controlador usa para mutar el estado del
/// documento de la reserva a "Pagado" de forma automática en Firestore.
class PayPalGatewayMock {
  final Random _aleatorio;

  /// Probabilidad de aprobación de la transacción (92 % por defecto, igual
  /// que el sandbox real de PayPal con tarjetas válidas).
  final double tasaAprobacion;

  PayPalGatewayMock({Random? aleatorio, this.tasaAprobacion = 0.92})
      : _aleatorio = aleatorio ?? Random();

  Future<ResultadoPago> procesarPago({
    required double monto,
    required String metodo,
    required String referenciaReserva,
    required Future<void> Function(ResultadoPago resultado) alAprobar,
    Future<void> Function(ResultadoPago resultado)? alRechazar,
  }) async {
    // Latencia de red simulada (1.2 – 2.4 s), como una API real.
    await Future.delayed(
        Duration(milliseconds: 1200 + _aleatorio.nextInt(1200)));

    // Validación analítica del monto, igual que el API real de PayPal.
    if (monto <= 0) {
      final rechazo = ResultadoPago(
        exitoso: false,
        monto: monto,
        metodo: metodo,
        mensajeError: 'AMOUNT_INVALID: el monto debe ser mayor que cero.',
      );
      if (alRechazar != null) await alRechazar(rechazo);
      return rechazo;
    }

    final aprobado = _aleatorio.nextDouble() < tasaAprobacion;

    if (aprobado) {
      final aprobacion = ResultadoPago(
        exitoso: true,
        monto: monto,
        metodo: metodo,
        codigoAutorizacion:
            'PP-${referenciaReserva.substring(0, referenciaReserva.length.clamp(0, 6)).toUpperCase()}-${_aleatorio.nextInt(999999).toString().padLeft(6, '0')}',
      );
      // Callback de éxito: actualiza el documento a "Pagado" en Firestore.
      await alAprobar(aprobacion);
      return aprobacion;
    }

    final rechazo = ResultadoPago(
      exitoso: false,
      monto: monto,
      metodo: metodo,
      mensajeError:
          'INSTRUMENT_DECLINED: el banco emisor rechazó la transacción. Intenta con otro método.',
    );
    if (alRechazar != null) await alRechazar(rechazo);
    return rechazo;
  }
}
