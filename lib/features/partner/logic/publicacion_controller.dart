import 'package:flutter/material.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../data/servicio_repository.dart';

/// Controlador del formulario de publicación paso a paso (RF04):
/// stepper lineal continuo de 4 pasos reales — "Identidad", "Costos",
/// "Ubicación" y "Éxito" — gobernado por el botón "Siguiente". Sirve tanto
/// para crear como para editar (RF13), administrando las URLs de imágenes.
class PublicacionController extends ChangeNotifier {
  final ServicioRepository _repository;

  /// Servicio en edición; `null` cuando se está creando uno nuevo.
  final Servicio? servicioInicial;

  static const List<String> pasos = [
    'Identidad',
    'Costos',
    'Ubicación',
    'Éxito',
  ];

  // --- Paso 1: Identidad ---
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final imagenUrlController = TextEditingController();
  String tipo = TiposServicio.alojamiento;
  final List<String> imagenes = [];

  // --- Paso 2: Costos ---
  final precioController = TextEditingController();
  final capacidadController = TextEditingController();

  // --- Paso 3: Ubicación ---
  final ciudadController = TextEditingController();
  final direccionController = TextEditingController();

  int _pasoActual = 0;
  bool _guardando = false;
  String? _errorPaso;
  String? _idGuardado;

  PublicacionController(
      {ServicioRepository? repository, this.servicioInicial})
      : _repository = repository ?? ServicioRepository() {
    final inicial = servicioInicial;
    if (inicial != null) {
      nombreController.text = inicial.nombre;
      descripcionController.text = inicial.descripcion;
      tipo = inicial.tipo;
      imagenes.addAll(inicial.imagenes);
      precioController.text = inicial.precio.toStringAsFixed(0);
      capacidadController.text = inicial.capacidad.toString();
      ciudadController.text = inicial.ciudad;
      direccionController.text = inicial.direccion;
    }
  }

  int get pasoActual => _pasoActual;
  bool get guardando => _guardando;
  String? get errorPaso => _errorPaso;
  bool get esEdicion => servicioInicial != null;
  bool get enPasoExito => _pasoActual == pasos.length - 1;

  void cambiarTipo(String nuevoTipo) {
    tipo = nuevoTipo;
    notifyListeners();
  }

  /// Administra las URLs de imágenes asociadas (RF14): agrega la URL escrita
  /// validando su formato y limpia el campo.
  String? agregarImagen() {
    final url = imagenUrlController.text.trim();
    if (url.isEmpty) {
      return 'Escribe la URL de la imagen antes de agregarla.';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'La URL no es válida: debe iniciar con http:// o https://';
    }
    imagenes.add(url);
    imagenUrlController.clear();
    notifyListeners();
    return null;
  }

  void quitarImagen(int indice) {
    if (indice >= 0 && indice < imagenes.length) {
      imagenes.removeAt(indice);
      notifyListeners();
    }
  }

  /// Validación de cada paso antes de avanzar con "Siguiente".
  String? _validarPaso(int paso) {
    switch (paso) {
      case 0:
        if (nombreController.text.trim().isEmpty) {
          return 'El nombre del servicio es obligatorio.';
        }
        if (descripcionController.text.trim().length < 20) {
          return 'Describe tu servicio con al menos 20 caracteres.';
        }
        if (imagenes.isEmpty) {
          return 'Agrega al menos una imagen (URL) de tu servicio.';
        }
        return null;
      case 1:
        final precio =
            double.tryParse(precioController.text.replaceAll(',', '.'));
        if (precio == null || precio <= 0) {
          return 'Ingresa un precio válido mayor que cero.';
        }
        final capacidad = int.tryParse(capacidadController.text);
        if (capacidad == null || capacidad <= 0) {
          return 'Ingresa la capacidad máxima de personas.';
        }
        return null;
      case 2:
        if (ciudadController.text.trim().isEmpty) {
          return 'Indica la ciudad donde se ofrece el servicio.';
        }
        if (direccionController.text.trim().isEmpty) {
          return 'Indica la dirección o punto de referencia.';
        }
        return null;
      default:
        return null;
    }
  }

  void atras() {
    if (_pasoActual > 0 && !enPasoExito) {
      _pasoActual--;
      _errorPaso = null;
      notifyListeners();
    }
  }

  /// Avanza el stepper. Al pasar de "Ubicación" ejecuta el guardado real en
  /// Firestore y, si tiene éxito, muestra el paso "Éxito". Devuelve `true`
  /// cuando el avance (y el guardado, si aplicaba) fue exitoso.
  Future<bool> siguiente(Usuario? aliado) async {
    final error = _validarPaso(_pasoActual);
    if (error != null) {
      _errorPaso = error;
      notifyListeners();
      return false;
    }
    _errorPaso = null;

    // Pasos intermedios: solo avanza.
    if (_pasoActual < 2) {
      _pasoActual++;
      notifyListeners();
      return true;
    }

    // Transición Ubicación → Éxito: persiste en Firestore.
    if (aliado == null || !aliado.esAliado) {
      _errorPaso = 'Debes iniciar sesión como Aliado para publicar.';
      notifyListeners();
      return false;
    }

    _guardando = true;
    notifyListeners();
    try {
      final servicio = Servicio(
        id: servicioInicial?.id ?? '',
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        tipo: tipo,
        precio: double.parse(precioController.text.replaceAll(',', '.')),
        capacidad: int.parse(capacidadController.text),
        ciudad: ciudadController.text.trim(),
        direccion: direccionController.text.trim(),
        imagenes: List.of(imagenes),
        calificacionPromedio: servicioInicial?.calificacionPromedio ?? 0,
        totalResenas: servicioInicial?.totalResenas ?? 0,
        estadoPublicacion:
            servicioInicial?.estadoPublicacion ?? EstadosPublicacion.activo,
        creadoPor: servicioInicial?.creadoPor ?? aliado.uid,
      );

      if (esEdicion) {
        await _repository.actualizar(servicio);
        _idGuardado = servicio.id;
      } else {
        _idGuardado = await _repository.crear(servicio);
      }

      _guardando = false;
      _pasoActual++;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _guardando = false;
      _errorPaso = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  String? get idGuardado => _idGuardado;

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    imagenUrlController.dispose();
    precioController.dispose();
    capacidadController.dispose();
    ciudadController.dispose();
    direccionController.dispose();
    super.dispose();
  }
}
