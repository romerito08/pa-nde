import 'package:flutter/foundation.dart';

/// Estado reactivo de favoritos en sesión (corazón de las tarjetas del
/// catálogo). Inyectado globalmente mediante Provider.
class FavoritosController extends ChangeNotifier {
  final Set<String> _favoritos = {};

  bool esFavorito(String servicioId) => _favoritos.contains(servicioId);

  List<String> get lista => _favoritos.toList();

  void alternar(String servicioId) {
    if (!_favoritos.add(servicioId)) {
      _favoritos.remove(servicioId);
    }
    notifyListeners();
  }
}
