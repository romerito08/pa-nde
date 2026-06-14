import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/ocupacion.dart';
import '../../../models/reserva.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../data/booking_repository.dart';
import 'price_strategy.dart';

/// Controlador del flujo de reserva directa en la vista de detalle.
/// Consulta en tiempo real la colección `calendarios` del servicio: si las
/// fechas elegidas están disponibles, la reserva se procesa automáticamente
/// — sin aprobación previa del Aliado — y la UI abre de inmediato la
/// pasarela de pago con la reserva creada.
class BookingController extends ChangeNotifier {
  final BookingRepository _repository;
  final Servicio servicio;

  List<Ocupacion> _ocupaciones = [];
  bool _cargandoCalendario = true;
  bool _procesando = false;
  String? _error;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _huespedes = 1;

  BookingController({required this.servicio, BookingRepository? repository})
      : _repository = repository ?? BookingRepository() {
    _cargarOcupaciones();
  }

  List<Ocupacion> get ocupaciones => _ocupaciones;
  bool get cargandoCalendario => _cargandoCalendario;
  bool get procesando => _procesando;
  String? get error => _error;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;
  int get huespedes => _huespedes;

  Future<void> _cargarOcupaciones() async {
    try {
      _ocupaciones = await _repository.ocupacionesDe(servicio.id);
      _error = null;
    } on AppException catch (e) {
      _error = e.mensaje;
    }
    _cargandoCalendario = false;
    notifyListeners();
  }

  /// Recarga manual del calendario (botón de reintento tras un fallo de red).
  Future<void> recargarCalendario() async {
    _cargandoCalendario = true;
    notifyListeners();
    await _cargarOcupaciones();
  }

  bool diaOcupado(DateTime dia) {
    return _ocupaciones.any((o) => o.contieneDia(dia));
  }

  bool _rangoLibre(DateTime inicio, DateTime fin) {
    return _ocupaciones.every((o) => !o.seSolapaCon(inicio, fin));
  }

  /// Selección interactiva del calendario: el primer toque fija el inicio,
  /// el segundo cierra el rango si está libre; tocar de nuevo reinicia.
  /// Devuelve un mensaje de advertencia si el rango toca fechas ocupadas.
  String? seleccionarDia(DateTime dia) {
    final normalizado = DateTime(dia.year, dia.month, dia.day);
    if (diaOcupado(normalizado)) {
      return 'Ese día ya está ocupado. Elige una fecha disponible.';
    }

    if (_fechaInicio == null || _fechaFin != null) {
      _fechaInicio = normalizado;
      _fechaFin = null;
      notifyListeners();
      return null;
    }

    if (!normalizado.isAfter(_fechaInicio!)) {
      _fechaInicio = normalizado;
      notifyListeners();
      return null;
    }

    if (!_rangoLibre(_fechaInicio!, normalizado)) {
      _fechaInicio = normalizado;
      _fechaFin = null;
      notifyListeners();
      return 'El rango elegido incluye días ocupados. Selecciona otro tramo.';
    }

    _fechaFin = normalizado;
    notifyListeners();
    return null;
  }

  bool diaEnRangoSeleccionado(DateTime dia) {
    if (_fechaInicio == null) return false;
    final normalizado = DateTime(dia.year, dia.month, dia.day);
    if (_fechaFin == null) {
      return normalizado == _fechaInicio;
    }
    return !normalizado.isBefore(_fechaInicio!) &&
        !normalizado.isAfter(_fechaFin!);
  }

  void cambiarHuespedes(int valor) {
    _huespedes = valor.clamp(1, servicio.capacidad);
    notifyListeners();
  }

  double get totalEstimado {
    if (_fechaInicio == null) return 0;
    if (servicio.esExperiencia) {
      return RegularPriceStrategy().calcularTotal(servicio.precio, _huespedes);
    }
    if (_fechaFin == null) return 0;
    final noches = _fechaFin!.difference(_fechaInicio!).inDays;
    return RegularPriceStrategy().calcularTotal(servicio.precio, noches);
  }

  bool get seleccionCompleta {
    if (_fechaInicio == null) return false;
    if (servicio.esExperiencia) return true;
    return _fechaFin != null;
  }

  /// Reserva directa: verifica la disponibilidad contra `calendarios` justo
  /// antes de confirmar y, si las fechas están libres, crea la reserva en
  /// "Pendiente de Pago" bloqueando el calendario. Devuelve la reserva
  /// persistida (para abrir la pasarela de inmediato) o el mensaje de error.
  Future<(Reserva?, String?)> reservarDirecto(Usuario? usuario) async {
    if (usuario == null) {
      return (null, 'Inicia sesión para reservar.');
    }
    if (!seleccionCompleta) {
      return (
        null,
        servicio.esExperiencia
            ? 'Selecciona la fecha de tu experiencia en el calendario.'
            : 'Selecciona las fechas de entrada y salida en el calendario.',
      );
    }

    // Las experiencias ocupan un solo día: el rango cierra al día siguiente.
    final inicio = _fechaInicio!;
    final fin = servicio.esExperiencia
        ? inicio.add(const Duration(days: 1))
        : _fechaFin!;

    _procesando = true;
    notifyListeners();
    try {
      final borrador = Reserva(
        id: '',
        servicioId: servicio.id,
        servicioNombre: servicio.nombre,
        servicioImagen: servicio.imagenPrincipal,
        servicioUbicacion: servicio.ubicacion,
        aliadoId: servicio.creadoPor,
        usuarioId: usuario.uid,
        usuarioNombre: usuario.nombreCompleto,
        fechaInicio: inicio,
        fechaFin: fin,
        huespedes: _huespedes,
        total: totalEstimado,
        estado: EstadosReserva.pendientePago,
        metodoPago: '',
      );
      final reservaId = await _repository.crearReserva(borrador);

      // Refresca las ocupaciones para que el calendario refleje el bloqueo.
      await _cargarOcupaciones();
      _fechaInicio = null;
      _fechaFin = null;
      _procesando = false;
      notifyListeners();
      return (borrador.copyWith(id: reservaId), null);
    } on AppException catch (e) {
      _procesando = false;
      notifyListeners();
      return (null, e.mensaje);
    }
  }
}
