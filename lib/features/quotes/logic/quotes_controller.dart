import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/cotizacion.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../data/quote_repository.dart';

/// Controlador del módulo de cotizaciones: crea solicitudes del Explorador
/// y gestiona las respuestas con feedback del Aliado, notificando a la UI.
class QuotesController extends ChangeNotifier {
  final QuoteRepository _repository;

  final Set<String> _procesando = {};
  bool _enviandoSolicitud = false;

  QuotesController({QuoteRepository? repository})
      : _repository = repository ?? QuoteRepository();

  bool get enviandoSolicitud => _enviandoSolicitud;
  bool estaProcesando(String cotizacionId) =>
      _procesando.contains(cotizacionId);

  Stream<List<Cotizacion>> bandejaDeAliado(String aliadoId) =>
      _repository.cotizacionesDeAliado(aliadoId);

  Stream<List<Cotizacion>> cotizacionesDeUsuario(String usuarioId) =>
      _repository.cotizacionesDeUsuario(usuarioId);

  /// "Solicitar una Cotización" del Explorador: valida y crea el documento
  /// en la colección `cotizaciones`. Devuelve el error amigable o `null`.
  Future<String?> solicitar({
    required Usuario? usuario,
    required Servicio servicio,
    required String mensaje,
    required int huespedes,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    if (usuario == null) {
      return 'Inicia sesión para solicitar una cotización.';
    }
    if (mensaje.trim().length < 10) {
      return 'Cuéntale al aliado qué necesitas (mínimo 10 caracteres).';
    }
    _enviandoSolicitud = true;
    notifyListeners();
    try {
      await _repository.crear(
        Cotizacion(
          id: '',
          servicioId: servicio.id,
          servicioNombre: servicio.nombre,
          aliadoId: servicio.creadoPor,
          usuarioId: usuario.uid,
          usuarioNombre: usuario.nombreCompleto,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          huespedes: huespedes,
          mensaje: mensaje.trim(),
          estado: EstadosCotizacion.pendiente,
          feedback: '',
          precioPropuesto: null,
          creadoEn: DateTime.now(),
        ),
      );
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    } finally {
      _enviandoSolicitud = false;
      notifyListeners();
    }
  }

  /// Respuesta del Aliado desde su bandeja: feedback + mutación de estado.
  /// Devuelve el error amigable o `null` si la respuesta quedó guardada.
  Future<String?> responder({
    required Cotizacion cotizacion,
    required String nuevoEstado,
    required String feedback,
    double? precioPropuesto,
  }) async {
    _procesando.add(cotizacion.id);
    notifyListeners();
    try {
      await _repository.responder(
        cotizacionId: cotizacion.id,
        nuevoEstado: nuevoEstado,
        feedback: feedback,
        precioPropuesto: precioPropuesto,
      );
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    } finally {
      _procesando.remove(cotizacion.id);
      notifyListeners();
    }
  }
}
