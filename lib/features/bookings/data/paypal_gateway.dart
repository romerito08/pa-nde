import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

import 'paypal_gateway_mock.dart';

// ---------------------------------------------------------------------------
// Interop con window._paondePP (definido en web/index.html).
// ---------------------------------------------------------------------------

@JS('window._paondePP.launch')
external JSPromise<JSObject> _ppLaunch(double amount, String refId);

// ---------------------------------------------------------------------------

/// Pasarela de pagos real (RF08).
///
/// En web y cuando el método es "PayPal" abre el flujo del SDK de PayPal JS
/// definido en `web/index.html`.  Para cualquier otra plataforma o método
/// delega al [PayPalGatewayMock] analítico.
class PayPalGateway {
  final PayPalGatewayMock _mock;

  PayPalGateway() : _mock = PayPalGatewayMock();

  Future<ResultadoPago> procesarPago({
    required double monto,
    required String metodo,
    required String referenciaReserva,
    required Future<void> Function(ResultadoPago resultado) alAprobar,
    Future<void> Function(ResultadoPago resultado)? alRechazar,
  }) async {
    // Para métodos distintos a PayPal (Tarjeta, Transferencia) o en
    // plataformas no-web seguimos usando el mock analítico.
    if (!kIsWeb || metodo != 'PayPal') {
      return _mock.procesarPago(
        monto: monto,
        metodo: metodo,
        referenciaReserva: referenciaReserva,
        alAprobar: alAprobar,
        alRechazar: alRechazar,
      );
    }

    // ---------- Flujo real de PayPal JS SDK ----------
    final JSObject obj = await _ppLaunch(monto, referenciaReserva).toDart;

    final JSAny? okRaw = obj.getProperty('ok'.toJS);
    final bool ok = okRaw != null && (okRaw as JSBoolean).toDart;

    late final ResultadoPago resultado;

    if (ok) {
      final JSAny? idRaw = obj.getProperty('id'.toJS);
      final String captureId = idRaw != null
          ? (idRaw as JSString).toDart
          : 'PP-${referenciaReserva.substring(0, referenciaReserva.length.clamp(0, 8))}';

      resultado = ResultadoPago(
        exitoso: true,
        monto: monto,
        metodo: 'PayPal',
        codigoAutorizacion: captureId,
      );
      await alAprobar(resultado);
    } else {
      final JSAny? msgRaw = obj.getProperty('msg'.toJS);
      final String mensajeError = msgRaw != null
          ? (msgRaw as JSString).toDart
          : 'Pago cancelado.';

      resultado = ResultadoPago(
        exitoso: false,
        monto: monto,
        metodo: 'PayPal',
        mensajeError: mensajeError,
      );
      if (alRechazar != null) await alRechazar(resultado);
    }

    return resultado;
  }
}
