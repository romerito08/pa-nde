import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/cotizacion.dart';
import '../../../models/reserva.dart';
import '../../../models/servicio.dart';
import '../../bookings/data/booking_repository.dart';
import '../../quotes/data/quote_repository.dart';
import '../data/servicio_repository.dart';

/// Controlador del Dashboard del Aliado (RF07): combina los streams de sus
/// servicios, reservas y cotizaciones para calcular métricas reales:
/// ganancias (solo estados "Pagado" o "Disfrutado"), pagos pendientes,
/// cotizaciones por responder, satisfacción promedio e ingresos semanales.
class PartnerDashboardController extends ChangeNotifier {
  final ServicioRepository _servicioRepository;
  final BookingRepository _bookingRepository;
  final QuoteRepository _quoteRepository;

  StreamSubscription<List<Servicio>>? _suscripcionServicios;
  StreamSubscription<List<Reserva>>? _suscripcionReservas;
  StreamSubscription<List<Cotizacion>>? _suscripcionCotizaciones;

  List<Servicio> _servicios = [];
  List<Reserva> _reservas = [];
  List<Cotizacion> _cotizaciones = [];
  bool _cargandoServicios = true;
  bool _cargandoReservas = true;
  String? _error;

  PartnerDashboardController({
    required String aliadoId,
    ServicioRepository? servicioRepository,
    BookingRepository? bookingRepository,
    QuoteRepository? quoteRepository,
  })  : _servicioRepository = servicioRepository ?? ServicioRepository(),
        _bookingRepository = bookingRepository ?? BookingRepository(),
        _quoteRepository = quoteRepository ?? QuoteRepository() {
    _suscripcionCotizaciones =
        _quoteRepository.cotizacionesDeAliado(aliadoId).listen(
      (cotizaciones) {
        _cotizaciones = cotizaciones;
        notifyListeners();
      },
      onError: (_) {
        // La bandeja de cotizaciones es secundaria en el dashboard: un fallo
        // aquí no bloquea las métricas principales.
        _cotizaciones = [];
        notifyListeners();
      },
    );
    _suscripcionServicios = _servicioRepository.serviciosDe(aliadoId).listen(
      (servicios) {
        _servicios = servicios;
        _cargandoServicios = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _cargandoServicios = false;
        _error = 'No pudimos cargar tus servicios. Verifica tu conexión.';
        notifyListeners();
      },
    );
    _suscripcionReservas = _bookingRepository.reservasDeAliado(aliadoId).listen(
      (reservas) {
        _reservas = reservas;
        _cargandoReservas = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _cargandoReservas = false;
        _error = 'No pudimos cargar tus reservas. Verifica tu conexión.';
        notifyListeners();
      },
    );
  }

  bool get cargando => _cargandoServicios || _cargandoReservas;
  String? get error => _error;
  List<Servicio> get servicios => _servicios;
  List<Reserva> get reservas => _reservas;

  /// Ganancias reales: itera, filtra y suma los montos de las reservas cuyo
  /// estado es estrictamente "Pagado" o "Disfrutado" (RF07).
  double get gananciasTotales => _reservas
      .where((r) =>
          r.estado == EstadosReserva.pagado ||
          r.estado == EstadosReserva.disfrutado)
      .fold<double>(0, (acumulado, r) => acumulado + r.total);

  /// Monto de reservas confirmadas que los exploradores aún no pagan.
  double get porCobrar => _reservas
      .where((r) => r.estado == EstadosReserva.pendientePago)
      .fold<double>(0, (acumulado, r) => acumulado + r.total);

  /// Cotizaciones pendientes de respuesta en la bandeja de entrada.
  int get cotizacionesPendientes => _cotizaciones
      .where((c) => c.estado == EstadosCotizacion.pendiente)
      .length;

  int get reservasConfirmadas => _reservas
      .where((r) =>
          r.estado == EstadosReserva.pagado ||
          r.estado == EstadosReserva.disfrutado)
      .length;

  /// Satisfacción promedio ponderada por cantidad de reseñas de cada servicio.
  double get satisfaccionPromedio {
    var sumaPonderada = 0.0;
    var totalResenas = 0;
    for (final servicio in _servicios) {
      sumaPonderada += servicio.calificacionPromedio * servicio.totalResenas;
      totalResenas += servicio.totalResenas;
    }
    return totalResenas == 0 ? 0 : sumaPonderada / totalResenas;
  }

  /// Ingresos cobrados por día de la semana actual (lunes a domingo), para
  /// el gráfico de barras de fl_chart.
  /// Usa [pagadoEn] como referencia temporal (cuándo se recibió el pago),
  /// no la fecha de inicio del servicio.
  List<double> get ingresosSemana {
    final ahora = DateTime.now();
    final inicioSemana = DateTime(ahora.year, ahora.month, ahora.day)
        .subtract(Duration(days: ahora.weekday - 1));
    final ingresos = List<double>.filled(7, 0);
    for (final reserva in _reservas) {
      final pagada = reserva.estado == EstadosReserva.pagado ||
          reserva.estado == EstadosReserva.disfrutado;
      if (!pagada) continue;
      // Preferir pagadoEn; si no existe (reservas antiguas) usar fechaInicio.
      final referencia = reserva.pagadoEn ?? reserva.fechaInicio;
      final dia =
          DateTime(referencia.year, referencia.month, referencia.day);
      final desplazamiento = dia.difference(inicioSemana).inDays;
      if (desplazamiento >= 0 && desplazamiento < 7) {
        ingresos[desplazamiento] += reserva.total;
      }
    }
    return ingresos;
  }

  /// Total acumulado de la semana en curso (suma de [ingresosSemana]).
  double get totalSemana =>
      ingresosSemana.fold<double>(0, (acc, v) => acc + v);

  /// Próximas reservas activas, ordenadas por fecha de inicio.
  List<Reserva> get proximasReservas {
    final hoy = DateTime.now();
    final futuras = _reservas
        .where((r) => r.fechaFin.isAfter(hoy))
        .toList()
      ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return futuras.take(6).toList();
  }

  @override
  void dispose() {
    _suscripcionServicios?.cancel();
    _suscripcionReservas?.cancel();
    _suscripcionCotizaciones?.cancel();
    super.dispose();
  }
  
}
