import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/servicio.dart';
import '../data/catalog_repository.dart';

/// Controlador reactivo del buscador y catálogo (RF02/RF03/RF10/RF11).
/// Los filtros geográficos usan la estructura estandarizada de Venezuela
/// (Estado/Municipio por dropdown, nunca texto libre), más fecha y
/// presupuesto máximo. Valida búsquedas vacías con una advertencia visual y
/// restablece todo con "Limpiar Filtros".
class CatalogController extends ChangeNotifier {
  final CatalogRepository _repository;
  StreamSubscription<List<Servicio>>? _suscripcion;

  List<Servicio> _todos = [];
  List<Servicio> _resultados = [];
  bool _cargando = true;
  String? _error;

  // --- Estado de los filtros ---
  String? _estado;
  String? _municipio;
  DateTime? _fecha;
  double? _presupuestoMaximo;
  String _textoBusqueda = '';
  Set<String> _tiposAlojamiento = {};
  bool? _conTransporte;
  bool _filtrosAplicados = false;

  /// Mensaje de advertencia (banner) cuando se intenta buscar sin filtros.
  String? _advertencia;

  CatalogController({CatalogRepository? repository})
      : _repository = repository ?? CatalogRepository() {
    _escucharServicios();
  }

  List<Servicio> get resultados => _resultados;

  /// Todos los servicios activos sin filtrar, para construir mapas estables
  /// (p. ej. imagen representativa por estado en DestinosScreen).
  List<Servicio> get todos => _todos;
  bool get cargando => _cargando;
  String? get error => _error;
  String? get advertencia => _advertencia;
  bool get filtrosAplicados => _filtrosAplicados;

  String? get estado => _estado;
  String? get municipio => _municipio;
  DateTime? get fecha => _fecha;
  double? get presupuestoMaximo => _presupuestoMaximo;
  String get textoBusqueda => _textoBusqueda;
  Set<String> get tiposAlojamiento => _tiposAlojamiento;
  bool? get conTransporte => _conTransporte;

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

  /// Selección de los dropdowns Estado/Municipio del filtro.
  void actualizarUbicacion(String? estado, String? municipio) {
    _estado = estado;
    _municipio = municipio;
    notifyListeners();
  }

  /// Actualiza el texto de búsqueda libre (nombre, descripción o destino).
  void actualizarTexto(String texto) {
    _textoBusqueda = texto.trim().toLowerCase();
    notifyListeners();
  }

  /// Aplica todos los filtros activos (incluyendo texto) de forma sincrónica,
  /// sin llamadas async. Útil para búsqueda por texto sin verificación de
  /// disponibilidad por fecha.
  void buscarLocalmente() {
    _filtrosAplicados = _estado != null ||
        _municipio != null ||
        (_presupuestoMaximo != null && _presupuestoMaximo! > 0) ||
        _textoBusqueda.isNotEmpty ||
        _tiposAlojamiento.isNotEmpty ||
        _conTransporte == true;
    _advertencia = null;
    _aplicarFiltrosLocales();
    notifyListeners();
  }

  void actualizarFecha(DateTime? valor) {
    _fecha = valor;
    notifyListeners();
  }

  void actualizarPresupuesto(String valor) {
    _presupuestoMaximo = double.tryParse(valor.replaceAll(',', '.'));
  }

  void actualizarTiposAlojamiento(Set<String> tipos) {
    _tiposAlojamiento = Set.of(tipos);
  }

  void actualizarTransporte(bool? valor) {
    _conTransporte = valor;
  }

  void cerrarAdvertencia() {
    _advertencia = null;
    notifyListeners();
  }

  /// Ejecuta la búsqueda. Si solo hay texto aplica filtros localmente.
  /// Si hay filtros de fecha/ubicación/presupuesto verifica disponibilidad
  /// en Firestore. Muestra advertencia solo cuando no hay ningún criterio.
  Future<void> buscar() async {
    final sinUbicacion = _estado == null && _municipio == null;
    final sinFecha = _fecha == null;
    final sinPresupuesto = _presupuestoMaximo == null || _presupuestoMaximo! <= 0;

    final sinTipos = _tiposAlojamiento.isEmpty;
    final sinTransporte = _conTransporte != true;

    if (sinUbicacion && sinFecha && sinPresupuesto && _textoBusqueda.isEmpty &&
        sinTipos && sinTransporte) {
      _advertencia =
          'Completa al menos un filtro (estado/municipio, fecha o presupuesto) antes de buscar.';
      notifyListeners();
      return;
    }

    // Solo texto/tipos/transporte → filtro local sin async.
    if (sinUbicacion && sinFecha && sinPresupuesto) {
      buscarLocalmente();
      return;
    }

    _advertencia = null;
    _cargando = true;
    notifyListeners();

    try {
      // La tendencia se registra para los gráficos del Administrador (RF12).
      await _repository.registrarBusqueda(
        estado: _estado,
        municipio: _municipio,
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

    _resultados = _todos.where((servicio) {
      final coincideEstado = _estado == null || servicio.estado == _estado;
      final coincideMunicipio =
          _municipio == null || servicio.municipio == _municipio;
      final coincidePresupuesto = _presupuestoMaximo == null ||
          _presupuestoMaximo! <= 0 ||
          servicio.precio <= _presupuestoMaximo!;
      final disponibleEnFecha = _fecha == null ||
          !(_ultimosOcupados?.contains(servicio.id) ?? false);
      final coincideTexto = _textoBusqueda.isEmpty ||
          servicio.nombre.toLowerCase().contains(_textoBusqueda) ||
          servicio.descripcion.toLowerCase().contains(_textoBusqueda) ||
          servicio.estado.toLowerCase().contains(_textoBusqueda) ||
          servicio.municipio.toLowerCase().contains(_textoBusqueda);
      final coincideTipoAlojamiento = _tiposAlojamiento.isEmpty ||
          _tiposAlojamiento.contains(servicio.tipoAlojamiento);
      final coincideTransporte =
          _conTransporte != true || servicio.incluyeTransporte;
      return coincideEstado &&
          coincideMunicipio &&
          coincidePresupuesto &&
          disponibleEnFecha &&
          coincideTexto &&
          coincideTipoAlojamiento &&
          coincideTransporte;
    }).toList();
  }

  /// Botón "Limpiar Filtros" (RF03): restablece todos los estados al valor
  /// por defecto y vuelve a mostrar el catálogo completo.
  void limpiarFiltros() {
    _estado = null;
    _municipio = null;
    _fecha = null;
    _presupuestoMaximo = null;
    _textoBusqueda = '';
    _tiposAlojamiento = {};
    _conTransporte = null;
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
