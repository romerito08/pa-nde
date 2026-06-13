import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/reserva.dart';
import '../data/booking_repository.dart';
import '../data/paypal_gateway_mock.dart';

/// Controlador de "Mis Reservas" del Explorador: expone el stream de
/// reservas, cancela reservas aún no pagadas (liberando sus fechas) y
/// ejecuta el cobro con el mock de PayPal, cuyo callback de éxito muta el
/// documento a "Pagado" automáticamente.
class MisReservasController extends ChangeNotifier {
  final BookingRepository _repository;
  final PayPalGatewayMock _pasarela;

  final Set<String> _procesando = {};

  MisReservasController(
      {BookingRepository? repository, PayPalGatewayMock? pasarela})
      : _repository = repository ?? BookingRepository(),
        _pasarela = pasarela ?? PayPalGatewayMock();

  Stream<List<Reserva>> reservasDe(String usuarioId) =>
      _repository.reservasDeUsuario(usuarioId);

  bool estaProcesando(String reservaId) => _procesando.contains(reservaId);

  /// Ejecuta el cobro simulado. El callback `alAprobar` de la pasarela
  /// actualiza el estado a "Pagado" automáticamente en Firestore.
  /// Devuelve el resultado para que la UI muestre el comprobante o el error.
  Future<ResultadoPago> pagar(Reserva reserva, String metodo) async {
    if (reserva.estado != EstadosReserva.pendientePago) {
      return ResultadoPago(
        exitoso: false,
        monto: reserva.total,
        metodo: metodo,
        mensajeError: 'Esta reserva ya fue pagada.',
      );
    }
    _procesando.add(reserva.id);
    notifyListeners();
    try {
      final resultado = await _pasarela.procesarPago(
        monto: reserva.total,
        metodo: metodo,
        referenciaReserva: reserva.id,
        alAprobar: (pago) async {
          await _repository.actualizarEstado(
            reservaId: reserva.id,
            nuevoEstado: EstadosReserva.pagado,
            metodoPago: pago.metodo,
            codigoAutorizacion: pago.codigoAutorizacion,
          );
        },
      );
      return resultado;
    } on AppException catch (e) {
      // El cobro fue aprobado pero Firestore falló al persistirlo: se informa
      // con claridad para que el usuario reintente sin pagar dos veces.
      return ResultadoPago(
        exitoso: false,
        monto: reserva.total,
        metodo: metodo,
        mensajeError: e.mensaje,
      );
    } finally {
      _procesando.remove(reserva.id);
      notifyListeners();
    }
  }

  /// Cancela una reserva que aún está pendiente de pago. Devuelve el error
  /// amigable o `null` si se liberaron las fechas correctamente.
  Future<String?> cancelar(Reserva reserva) async {
    if (reserva.estado != EstadosReserva.pendientePago) {
      return 'Solo puedes cancelar reservas que sigan en "Pendiente de Pago".';
    }
    _procesando.add(reserva.id);
    notifyListeners();
    try {
      await _repository.cancelarReserva(reserva.id);
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    } finally {
      _procesando.remove(reserva.id);
      notifyListeners();
    }
  }
}
