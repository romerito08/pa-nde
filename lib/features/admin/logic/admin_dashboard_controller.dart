import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/reserva.dart';
import '../../../models/servicio.dart';
import '../data/admin_repository.dart';

/// Rango de precio para agrupar los destinos más solicitados (RF12).
class RangoPrecio {
  final String etiqueta;
  final double minimo;
  final double maximo;

  const RangoPrecio(this.etiqueta, this.minimo, this.maximo);

  bool contiene(double precio) => precio >= minimo && precio < maximo;

  static const List<RangoPrecio> rangos = [
    RangoPrecio('Económico (\$0–25)', 0, 25),
    RangoPrecio('Medio (\$25–60)', 25, 60),
    RangoPrecio('Alto (\$60–120)', 60, 120),
    RangoPrecio('Premium (\$120+)', 120, double.infinity),
  ];
}

/// Controlador del panel analítico del Administrador (RF12): carga
/// búsquedas, reservas y servicios de Firestore y deriva los datasets de
/// los gráficos — tendencia diaria de búsquedas, destinos más buscados y
/// demanda por rango de precio.
class AdminDashboardController extends ChangeNotifier {
  final AdminRepository _repository;

  bool _cargando = true;
  String? _error;

  List<RegistroBusqueda> _busquedas = [];
  List<Reserva> _reservas = [];
  List<Servicio> _servicios = [];
  int _totalUsuarios = 0;

  AdminDashboardController({AdminRepository? repository})
      : _repository = repository ?? AdminRepository() {
    cargar();
  }

  bool get cargando => _cargando;
  String? get error => _error;
  int get totalUsuarios => _totalUsuarios;
  int get totalServicios => _servicios.length;
  int get totalBusquedas => _busquedas.length;
  int get totalReservas => _reservas.length;

  double get volumenTransado => _reservas
      .where((r) =>
          r.estado == EstadosReserva.pagado ||
          r.estado == EstadosReserva.disfrutado)
      .fold<double>(0, (acumulado, r) => acumulado + r.total);

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      // Cargas en paralelo para minimizar la espera del panel.
      final resultados = await Future.wait([
        _repository.busquedasRecientes(dias: 30),
        _repository.todasLasReservas(),
        _repository.todosLosServicios(),
        _repository.totalUsuarios(),
      ]);
      _busquedas = resultados[0] as List<RegistroBusqueda>;
      _reservas = resultados[1] as List<Reserva>;
      _servicios = resultados[2] as List<Servicio>;
      _totalUsuarios = resultados[3] as int;
      _cargando = false;
      notifyListeners();
    } on AppException catch (e) {
      _cargando = false;
      _error = e.mensaje;
      notifyListeners();
    }
  }

  /// Tendencia de búsquedas de los últimos 7 días (para el LineChart):
  /// índice 0 = hace 6 días, índice 6 = hoy.
  List<int> get busquedasPorDia {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(const Duration(days: 6));
    final conteo = List<int>.filled(7, 0);
    for (final busqueda in _busquedas) {
      final dia = DateTime(busqueda.creadoEn.year, busqueda.creadoEn.month,
          busqueda.creadoEn.day);
      final desplazamiento = dia.difference(inicio).inDays;
      if (desplazamiento >= 0 && desplazamiento < 7) {
        conteo[desplazamiento]++;
      }
    }
    return conteo;
  }

  /// Etiquetas día/mes alineadas con [busquedasPorDia].
  List<String> get etiquetasDias {
    final hoy = DateTime.now();
    return List.generate(7, (i) {
      final dia = hoy.subtract(Duration(days: 6 - i));
      return '${dia.day}/${dia.month}';
    });
  }

  /// Destinos más buscados por los exploradores (top 5 para el BarChart),
  /// agrupados por municipio/estado estandarizado.
  List<MapEntry<String, int>> get destinosMasBuscados {
    final conteo = <String, int>{};
    for (final busqueda in _busquedas) {
      final destino = busqueda.destino;
      if (destino == null) continue;
      conteo[destino] = (conteo[destino] ?? 0) + 1;
    }
    final ordenado = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ordenado.take(5).toList();
  }

  /// Destinos más solicitados agrupados por rango de precio del servicio
  /// reservado (para el PieChart): cuenta reservas reales por rango.
  Map<RangoPrecio, int> get reservasPorRangoPrecio {
    final preciosPorServicio = {
      for (final servicio in _servicios) servicio.id: servicio.precio,
    };
    final conteo = {for (final rango in RangoPrecio.rangos) rango: 0};
    for (final reserva in _reservas) {
      final precio = preciosPorServicio[reserva.servicioId];
      if (precio == null) continue;
      for (final rango in RangoPrecio.rangos) {
        if (rango.contiene(precio)) {
          conteo[rango] = (conteo[rango] ?? 0) + 1;
          break;
        }
      }
    }
    return conteo;
  }
}
