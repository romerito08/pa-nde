import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../core/data/venezuela_geo.dart';
import '../../../core/utils/app_exception.dart';
import '../../../models/servicio.dart';
import '../../../models/usuario.dart';
import '../data/servicio_repository.dart';

/// Controlador del formulario de publicación paso a paso (RF04):
/// stepper lineal de 4 pasos — Identidad, Costos, Ubicación y Éxito.
/// Las imágenes se comprimen y se almacenan como data URLs base64 en Firestore.
class PublicacionController extends ChangeNotifier {
  final ServicioRepository _repository;

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
  String tipo = TiposServicio.alojamiento;
  String tipoAlojamiento = '';
  bool incluyeTransporte = false;
  final List<String> imagenes = [];

  // --- Paso 2: Costos ---
  final precioController = TextEditingController();
  final capacidadController = TextEditingController();

  // --- Paso 3: Ubicación ---
  String? estadoSeleccionado;
  String? municipioSeleccionado;
  final direccionController = TextEditingController();

  int _pasoActual = 0;
  bool _guardando = false;
  bool _subiendo = false;
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
      tipoAlojamiento = inicial.tipoAlojamiento;
      incluyeTransporte = inicial.incluyeTransporte;
      imagenes.addAll(inicial.imagenes);
      precioController.text = inicial.precio.toStringAsFixed(0);
      capacidadController.text = inicial.capacidad.toString();
      if (VenezuelaGeo.esUbicacionValida(inicial.estado, inicial.municipio)) {
        estadoSeleccionado = inicial.estado;
        municipioSeleccionado = inicial.municipio;
      }
      direccionController.text = inicial.direccion;
    }
  }

  int get pasoActual => _pasoActual;
  bool get guardando => _guardando;
  bool get subiendo => _subiendo;
  String? get errorPaso => _errorPaso;
  bool get esEdicion => servicioInicial != null;
  bool get enPasoExito => _pasoActual == pasos.length - 1;

  void cambiarTipo(String nuevoTipo) {
    tipo = nuevoTipo;
    if (nuevoTipo != TiposServicio.alojamiento) tipoAlojamiento = '';
    notifyListeners();
  }

  void cambiarTipoAlojamiento(String? valor) {
    tipoAlojamiento = valor ?? '';
    notifyListeners();
  }

  void cambiarTransporte(bool valor) {
    incluyeTransporte = valor;
    notifyListeners();
  }

  void cambiarUbicacion(String? estado, String? municipio) {
    estadoSeleccionado = estado;
    municipioSeleccionado = municipio;
    notifyListeners();
  }

  static const int _maxImagenes = 5;

  /// Abre el selector de archivos con selección múltiple, comprime cada
  /// imagen y la guarda como data URL base64 en Firestore. Respeta el límite
  /// de [_maxImagenes] imágenes por servicio. Devuelve error o `null`.
  ///
  /// IMPORTANTE: el picker se abre ANTES de cualquier notifyListeners para que
  /// el navegador no bloquee el file dialog por salirse del contexto de gesto.
  Future<String?> subirImagen(String uid) async {
    final disponibles = _maxImagenes - imagenes.length;
    if (disponibles <= 0) {
      return 'Ya tienes el máximo de $_maxImagenes fotos.';
    }

    // 1. Abrir el selector inmediatamente, sin rebuilds previos.
    FilePickerResult? resultado;
    try {
      resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: true,
      );
    } catch (_) {
      return 'No fue posible abrir el selector de archivos.';
    }

    if (resultado == null || resultado.files.isEmpty) return null;

    // 2. Solo ahora mostramos el spinner de procesamiento.
    _subiendo = true;
    notifyListeners();

    try {
      final archivos = resultado.files.take(disponibles).toList();
      int sinBytes = 0;

      for (final archivo in archivos) {
        final bytes = archivo.bytes;
        if (bytes == null) {
          sinBytes++;
          continue;
        }
        final comprimidos = _comprimirJpg(bytes);
        imagenes.add('data:image/jpeg;base64,${base64Encode(comprimidos)}');
      }

      _subiendo = false;
      notifyListeners();

      if (sinBytes == archivos.length) {
        return 'No se pudieron leer los archivos. Intenta de nuevo.';
      }
      return null;
    } catch (_) {
      _subiendo = false;
      notifyListeners();
      return 'No fue posible procesar las imágenes. Intenta de nuevo.';
    }
  }

  /// Redimensiona a máximo 800 px de ancho y recodifica en JPEG calidad 75
  /// para mantener el tamaño del documento Firestore bajo 1 MB.
  static Uint8List _comprimirJpg(Uint8List bytes) {
    try {
      final original = img.decodeImage(bytes);
      if (original == null) return bytes;
      final reducida = original.width > 800
          ? img.copyResize(original, width: 800)
          : original;
      return Uint8List.fromList(img.encodeJpg(reducida, quality: 75));
    } catch (_) {
      return bytes;
    }
  }

  void quitarImagen(int indice) {
    if (indice >= 0 && indice < imagenes.length) {
      imagenes.removeAt(indice);
      notifyListeners();
    }
  }

  String? _validarPaso(int paso) {
    switch (paso) {
      case 0:
        if (nombreController.text.trim().isEmpty) {
          return 'El nombre del servicio es obligatorio.';
        }
        if (descripcionController.text.trim().length < 20) {
          return 'Describe tu servicio con al menos 20 caracteres.';
        }
        if (tipo == TiposServicio.alojamiento && tipoAlojamiento.isEmpty) {
          return 'Selecciona el tipo de alojamiento.';
        }
        if (imagenes.isEmpty) {
          return 'Sube al menos una foto de tu servicio.';
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
        if (!VenezuelaGeo.esUbicacionValida(
            estadoSeleccionado, municipioSeleccionado)) {
          return 'Selecciona el Estado y el Municipio de la lista oficial.';
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

  Future<bool> siguiente(Usuario? aliado) async {
    final error = _validarPaso(_pasoActual);
    if (error != null) {
      _errorPaso = error;
      notifyListeners();
      return false;
    }
    _errorPaso = null;

    if (_pasoActual < 2) {
      _pasoActual++;
      notifyListeners();
      return true;
    }

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
        tipoAlojamiento: tipoAlojamiento,
        incluyeTransporte: incluyeTransporte,
        precio: double.parse(precioController.text.replaceAll(',', '.')),
        capacidad: int.parse(capacidadController.text),
        estado: estadoSeleccionado!,
        municipio: municipioSeleccionado!,
        direccion: direccionController.text.trim(),
        imagenes: List.of(imagenes),
        calificacionPromedio: servicioInicial?.calificacionPromedio ?? 0,
        totalResenas: servicioInicial?.totalResenas ?? 0,
        estadoPublicacion:
            servicioInicial?.estadoPublicacion ?? EstadosPublicacion.pendiente,
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
    precioController.dispose();
    capacidadController.dispose();
    direccionController.dispose();
    super.dispose();
  }
}
