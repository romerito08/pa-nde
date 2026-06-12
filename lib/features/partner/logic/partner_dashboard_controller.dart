import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/reserva.dart';
import '../../../models/servicio.dart';
import '../../bookings/data/booking_repository.dart';
import '../data/servicio_repository.dart';

/// Controlador del Dashboard del Aliado (RF07): combina los streams de sus
/// servicios y de las reservas recibidas para calcular métricas reales:
/// ganancias (solo estados "Pagado" o "Disfrutado"), montos por cobrar,
/// solicitudes pendientes, satisfacción promedio e ingresos de la semana.
class PartnerDashboardController extends ChangeNotifier {
  final ServicioRepository _servicioRepository;
  final BookingRepository _bookingRepository;

  StreamSubscription<List<Servicio>>? _suscripcionServicios;
  StreamSubscription<List<Reserva>>? _suscripcionReservas;

  List<Servicio> _servicios = [];
  List<Reserva> _reservas = [];
  bool _cargandoServicios = true;
  bool _cargandoReservas = true;
  String? _error;

  PartnerDashboardController({
    required String aliadoId,
    ServicioRepository? servicioRepository,
    BookingRepository? bookingRepository,
  })  : _servicioRepository = servicioRepository ?? ServicioRepository(),
        _bookingRepository = bookingRepository ?? BookingRepository() {
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

  /// Monto aceptado pero aún no pagado por los exploradores.
  double get porCobrar => _reservas
      .where((r) => r.estado == EstadosReserva.aceptado)
      .fold<double>(0, (acumulado, r) => acumulado + r.total);

  int get solicitudesNuevas =>
      _reservas.where((r) => r.estado == EstadosReserva.solicitado).length;

  int get reservasConfirmadas => _reservas
      .where((r) =>
          r.estado == EstadosReserva.aceptado ||
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
  List<double> get ingresosSemana {
    final ahora = DateTime.now();
    final inicioSemana = DateTime(ahora.year, ahora.month, ahora.day)
        .subtract(Duration(days: ahora.weekday - 1));
    final ingresos = List<double>.filled(7, 0);
    for (final reserva in _reservas) {
      final pagada = reserva.estado == EstadosReserva.pagado ||
          reserva.estado == EstadosReserva.disfrutado;
      if (!pagada) continue;
      final dia = DateTime(reserva.fechaInicio.year, reserva.fechaInicio.month,
          reserva.fechaInicio.day);
      final desplazamiento = dia.difference(inicioSemana).inDays;
      if (desplazamiento >= 0 && desplazamiento < 7) {
        ingresos[desplazamiento] += reserva.total;
      }
    }
    return ingresos;
  }

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
    super.dispose();
  }
}
