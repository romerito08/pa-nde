import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/cotizacion.dart';
import '../../../models/reserva.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../../bookings/data/booking_repository.dart';
import '../data/quote_repository.dart';

class QuotesController extends ChangeNotifier {
  final QuoteRepository _repository;
  final BookingRepository _bookingRepository;

  final Set<String> _procesando = {};
  bool _enviandoSolicitud = false;

  QuotesController({
    QuoteRepository? repository,
    BookingRepository? bookingRepository,
  })  : _repository = repository ?? QuoteRepository(),
        _bookingRepository = bookingRepository ?? BookingRepository();

  bool get enviandoSolicitud => _enviandoSolicitud;
  bool estaProcesando(String cotizacionId) =>
      _procesando.contains(cotizacionId);

  Stream<List<Cotizacion>> bandejaDeAliado(String aliadoId) =>
      _repository.cotizacionesDeAliado(aliadoId);

  Stream<List<Cotizacion>> cotizacionesDeUsuario(String usuarioId) =>
      _repository.cotizacionesDeUsuario(usuarioId);

  /// Solicitud inicial del Explorador.
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
          servicioImagen: servicio.imagenPrincipal,
          servicioUbicacion: servicio.ubicacion,
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
          precioBase: servicio.precio,
          esExperiencia: servicio.esExperiencia,
          creadoEn: DateTime.now(),
          turnoAliado: true,
          mensajeExplorador: '',
          reservaId: '',
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

  /// Respuesta del Aliado: feedback + estado.
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

  /// Contra-respuesta del Explorador ante una Contrapropuesta.
  Future<String?> contraResponder({
    required Cotizacion cotizacion,
    required String mensaje,
  }) async {
    _procesando.add(cotizacion.id);
    notifyListeners();
    try {
      await _repository.responderExplorador(
        cotizacionId: cotizacion.id,
        mensajeExplorador: mensaje,
      );
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    } finally {
      _procesando.remove(cotizacion.id);
      notifyListeners();
    }
  }

  /// El explorador actualiza las fechas de su cotización.
  Future<String?> actualizarFechas({
    required Cotizacion cotizacion,
    required DateTime fechaInicio,
    DateTime? fechaFin,
  }) async {
    _procesando.add(cotizacion.id);
    notifyListeners();
    try {
      await _repository.actualizarFechas(
        cotizacionId: cotizacion.id,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      return null;
    } on AppException catch (e) {
      return e.mensaje;
    } finally {
      _procesando.remove(cotizacion.id);
      notifyListeners();
    }
  }

  /// Crea una Reserva usando las fechas y el precio acordado en la cotización.
  /// [fechaInicioManual] y [fechaFinManual] se usan cuando el explorador elige
  /// fechas en el momento de reservar (cotización sin fechas previas).
  Future<(Reserva?, String?)> reservarDesdeCotizacion({
    required Cotizacion cotizacion,
    required Usuario? usuario,
    DateTime? fechaInicioManual,
    DateTime? fechaFinManual,
  }) async {
    if (usuario == null) {
      return (null, 'Inicia sesión para reservar.');
    }

    final inicio = fechaInicioManual ?? cotizacion.fechaInicio;
    if (inicio == null) {
      return (null, 'Selecciona las fechas para continuar.');
    }
    final fin = fechaFinManual ??
        cotizacion.fechaFin ??
        inicio.add(const Duration(days: 1));

    _procesando.add(cotizacion.id);
    notifyListeners();

    try {
      // Persist manually-chosen dates so the cotización reflects reality
      if (fechaInicioManual != null) {
        await _repository.actualizarFechas(
          cotizacionId: cotizacion.id,
          fechaInicio: inicio,
          fechaFin: cotizacion.esExperiencia ? null : fin,
        );
      }

      // Recalculate total using the actual dates
      final noches = cotizacion.esExperiencia
          ? cotizacion.huespedes
          : fin.difference(inicio).inDays.clamp(1, 9999);
      final total =
          cotizacion.precioPropuesto ?? cotizacion.precioBase * noches;

      final borrador = Reserva(
        id: '',
        servicioId: cotizacion.servicioId,
        servicioNombre: cotizacion.servicioNombre,
        servicioImagen: cotizacion.servicioImagen,
        servicioUbicacion: cotizacion.servicioUbicacion,
        aliadoId: cotizacion.aliadoId,
        usuarioId: usuario.uid,
        usuarioNombre: usuario.nombreCompleto,
        fechaInicio: inicio,
        fechaFin: fin,
        huespedes: cotizacion.huespedes,
        total: total,
        estado: EstadosReserva.pendientePago,
        metodoPago: '',
      );
      final reservaId = await _bookingRepository.crearReserva(borrador);
      await _repository.vincularReserva(
        cotizacionId: cotizacion.id,
        reservaId: reservaId,
      );
      return (borrador.copyWith(id: reservaId), null);
    } on AppException catch (e) {
      return (null, e.mensaje);
    } finally {
      _procesando.remove(cotizacion.id);
      notifyListeners();
    }
  }
}
