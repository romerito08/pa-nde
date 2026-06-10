// lib/providers/favoritos_provider.dart
import 'package:flutter/material.dart';

class FavoritosProvider extends ChangeNotifier {
  // Guardamos los IDs únicos de lo que al usuario le gusta
  final Set<String> _alojamientosFavoritos = {};
  final Set<String> _experienciasFavoritas = {};

  // Consultar si un elemento específico es favorito (devuelve true o false)
  bool esAlojamientoFavorito(String id) => _alojamientosFavoritos.contains(id);
  bool esExperienciaFavorita(String id) => _experienciasFavoritas.contains(id);

  // Obtener las listas completas para la pantalla de Guardados
  List<String> get listaAlojamientos => _alojamientosFavoritos.toList();
  List<String> get listaExperiencias => _experienciasFavoritas.toList();

  // Activa o desactiva un alojamiento
  void toggleAlojamiento(String id) {
    if (_alojamientosFavoritos.contains(id)) {
      _alojamientosFavoritos.remove(id);
    } else {
      _alojamientosFavoritos.add(id);
    }
    notifyListeners(); // Esto le avisa a las tarjetas que se vuelvan amarillas
  }

  // Activa o desactiva una experiencia
  void toggleExperiencia(String id) {
    if (_experienciasFavoritas.contains(id)) {
      _experienciasFavoritas.remove(id);
    } else {
      _experienciasFavoritas.add(id);
    }
    notifyListeners(); // Esto le avisa a las tarjetas que se vuelvan amarillas
  }
}