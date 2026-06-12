import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/utils/app_exception.dart';
import '../../../models/resena.dart';
import '../../../models/usuario.dart';
import '../data/review_repository.dart';

/// Controlador reactivo de la sección de reseñas (RF06). Posee el
/// TextEditingController del comentario para poder limpiarlo inmediatamente
/// tras el envío y recalcula el promedio general en tiempo real, que la
/// cabecera de la pantalla de detalle observa mediante Provider.
class ReviewController extends ChangeNotifier {
  final ReviewRepository _repository;
  final String servicioId;

  final TextEditingController comentarioController = TextEditingController();
  StreamSubscription<List<Resena>>? _suscripcion;

  List<Resena> _resenas = [];
  int _calificacionSeleccionada = 5;
  bool _enviando = false;
  bool _cargando = true;
  String? _error;

  ReviewController({required this.servicioId, ReviewRepository? repository})
      : _repository = repository ?? ReviewRepository() {
    _suscripcion = _repository.resenasDe(servicioId).listen(
      (resenas) {
        _resenas = resenas;
        _cargando = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _cargando = false;
        _error = 'No pudimos cargar las reseñas. Verifica tu conexión.';
        notifyListeners();
      },
    );
  }

  List<Resena> get resenas => _resenas;
  int get calificacionSeleccionada => _calificacionSeleccionada;
  bool get enviando => _enviando;
  bool get cargando => _cargando;
  String? get error => _error;
  int get totalResenas => _resenas.length;

  /// Promedio general recalculado en tiempo real a partir del stream:
  /// alimenta la cabecera visual de la pantalla de detalle.
  double get promedio {
    if (_resenas.isEmpty) return 0;
    final suma = _resenas.fold<int>(0, (acc, r) => acc + r.calificacion);
    return suma / _resenas.length;
  }

  void seleccionarCalificacion(int valor) {
    _calificacionSeleccionada = valor;
    notifyListeners();
  }

  /// Acción del botón "Enviar Comentario": valida, impacta la subcolección,
  /// limpia el controlador de texto de inmediato y deja que el stream +
  /// transacción recalculen el promedio. Devuelve el mensaje de error
  /// amigable o `null` si todo salió bien.
  Future<String?> enviarComentario(Usuario? usuario) async {
    if (usuario == null) {
      return 'Inicia sesión para dejar tu reseña.';
    }
    final texto = comentarioController.text.trim();
    if (texto.isEmpty) {
      return 'Escribe tu opinión antes de enviar.';
    }

    _enviando = true;
    notifyListeners();
    try {
      await _repository.agregarResena(
        servicioId: servicioId,
        resena: Resena(
          id: '',
          usuarioId: usuario.uid,
          nombreUsuario: usuario.nombreCompleto,
          texto: texto,
          calificacion: _calificacionSeleccionada,
          fecha: DateTime.now(),
        ),
      );
      // Limpieza inmediata del campo tras el impacto en Firestore (RF06).
      comentarioController.clear();
      _calificacionSeleccionada = 5;
      _enviando = false;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _enviando = false;
      notifyListeners();
      return e.mensaje;
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    comentarioController.dispose();
    super.dispose();
  }
}
