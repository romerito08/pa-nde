import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/servicio.dart';
import '../data/catalog_repository.dart';

/// Controlador reactivo del buscador y catálogo (RF02/RF03/RF10/RF11).
/// Mantiene los filtros (ciudad, fecha, presupuesto máximo), valida que no
/// se disparen búsquedas vacías mostrando una advertencia visual, aplica el
/// filtrado sobre el stream de servicios y resetea todo con "Limpiar Filtros".
class CatalogController extends ChangeNotifier {
  final CatalogRepository _repository;
  StreamSubscription<List<Servicio>>? _suscripcion;

  List<Servicio> _todos = [];
  List<Servicio> _resultados = [];
  bool _cargando = true;
  String? _error;

  // --- Estado de los filtros ---
  String _ciudad = '';
  DateTime? _fecha;
  double? _presupuestoMaximo;
  bool _filtrosAplicados = false;

  /// Mensaje de advertencia (banner) cuando se intenta buscar sin filtros.
  String? _advertencia;

  CatalogController({CatalogRepository? repository})
      : _repository = repository ?? CatalogRepository() {
    _escucharServicios();
  }

  List<Servicio> get resultados => _resultados;
  bool get cargando => _cargando;
  String? get error => _error;
  String? get advertencia => _advertencia;
  bool get filtrosAplicados => _filtrosAplicados;

  String get ciudad => _ciudad;
  DateTime? get fecha => _fecha;
  double? get presupuestoMaximo => _presupuestoMaximo;

  void _escucharServicios() {
    _cargando = true;
    notifyListeners();
    _suscripcion = _repository.serviciosActivos().listen(
      (servicios) {
        _todos = servicios;
        _error = null;
        _cargando = false;
        // Si hay filtros activos se reaplican sobre los datos frescos para
        // que el catálogo se mantenga reactivo en tiempo real.
        if (_filtrosAplicados) {
          _aplicarFiltrosLocales();
        } else {
          _resultados = List.of(servicios);
        }
        notifyListeners();
      },
      onError: (_) {
        _cargando = false;
        _error =
            'No pudimos cargar el catálogo. Verifica tu conexión a internet.';
        notifyListeners();
      },
    );
  }

  void actualizarCiudad(String valor) {
    _ciudad = valor;
  }

  void actualizarFecha(DateTime? valor) {
    _fecha = valor;
    notifyListeners();
  }

  void actualizarPresupuesto(String valor) {
    _presupuestoMaximo = double.tryParse(valor.replaceAll(',', '.'));
  }

  void cerrarAdvertencia() {
    _advertencia = null;
    notifyListeners();
  }

  /// Ejecuta la búsqueda. Valida que al menos un filtro tenga valor: si todos
  /// están vacíos dispara la advertencia visual (banner en la UI) y no
  /// consulta nada (RF02).
  Future<void> buscar() async {
    final sinCiudad = _ciudad.trim().isEmpty;
    final sinFecha = _fecha == null;
    final sinPresupuesto = _presupuestoMaximo == null || _presupuestoMaximo! <= 0;

    if (sinCiudad && sinFecha && sinPresupuesto) {
      _advertencia =
          'Completa al menos un filtro (ciudad, fecha o presupuesto) antes de buscar.';
      notifyListeners();
      return;
    }

    _advertencia = null;
    _cargando = true;
    notifyListeners();

    try {
      // La tendencia se registra para los gráficos del Administrador (RF12).
      await _repository.registrarBusqueda(
        ciudad: sinCiudad ? null : _ciudad,
        fecha: _fecha,
        presupuestoMaximo: sinPresupuesto ? null : _presupuestoMaximo,
      );

      Set<String>? ocupados;
      if (!sinFecha) {
        ocupados = await _repository.serviciosOcupadosEn(_fecha!);
      }

      _filtrosAplicados = true;
      _aplicarFiltrosLocales(ocupadosEnFecha: ocupados);
      _cargando = false;
      notifyListeners();
    } on AppException catch (e) {
      _cargando = false;
      _error = e.mensaje;
      notifyListeners();
    }
  }

  Set<String>? _ultimosOcupados;

  void _aplicarFiltrosLocales({Set<String>? ocupadosEnFecha}) {
    if (ocupadosEnFecha != null) _ultimosOcupados = ocupadosEnFecha;
    final ciudadNormalizada = _ciudad.trim().toLowerCase();

    _resultados = _todos.where((servicio) {
      final coincideCiudad = ciudadNormalizada.isEmpty ||
          servicio.ciudad.toLowerCase().contains(ciudadNormalizada) ||
          servicio.nombre.toLowerCase().contains(ciudadNormalizada);
      final coincidePresupuesto = _presupuestoMaximo == null ||
          _presupuestoMaximo! <= 0 ||
          servicio.precio <= _presupuestoMaximo!;
      final disponibleEnFecha = _fecha == null ||
          !(_ultimosOcupados?.contains(servicio.id) ?? false);
      return coincideCiudad && coincidePresupuesto && disponibleEnFecha;
    }).toList();
  }

  /// Botón "Limpiar Filtros" (RF03): restablece todos los estados al valor
  /// por defecto y vuelve a mostrar el catálogo completo.
  void limpiarFiltros() {
    _ciudad = '';
    _fecha = null;
    _presupuestoMaximo = null;
    _filtrosAplicados = false;
    _advertencia = null;
    _ultimosOcupados = null;
    _resultados = List.of(_todos);
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
