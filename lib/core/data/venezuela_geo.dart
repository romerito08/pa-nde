import 'package:cloud_firestore/cloud_firestore.dart';

/// Estructura de datos dinámica de la división político-territorial de
/// Venezuela provista desde Cloud Firestore (Colección 'estados').
class VenezuelaGeo {
  VenezuelaGeo._();

  /// Caché en memoria para evitar llamadas redundantes a Firestore
  static final Map<String, List<String>> _estadosYMunicipios = {};

  /// Carga la data geográfica desde Firebase Firestore
  static Future<void> cargarDesdeFirestore() async {
    if (_estadosYMunicipios.isNotEmpty) return; // Ya cargado
    try {
      final snapshot = await FirebaseFirestore.instance.collection('estados').get();
      _estadosYMunicipios.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Asumiendo que el campo dentro del documento se llama 'municipios'
        final List<dynamic> muniList = data['municipios'] ?? [];
        _estadosYMunicipios[doc.id] = muniList.map((e) => e.toString()).toList()..sort();
      }
    } catch (e) {
      // Contingencia defensiva por si falla la red en el primer frame
      _estadosYMunicipios['Distrito Capital'] = ['Libertador'];
      _estadosYMunicipios['Miranda'] = ['Chacao', 'Baruta', 'Sucre'];
    }
  }

  /// Lista ordenada de entidades federales.
  static List<String> get estados {
    final lista = _estadosYMunicipios.keys.toList();
    lista.sort();
    return lista;
  }

  /// Municipios de un estado; lista vacía si el estado no existe.
  static List<String> municipiosDe(String? estado) {
    if (estado == null) return const [];
    return _estadosYMunicipios[estado] ?? const [];
  }

  /// Validación estricta de procedencia geográfica (RF02).
  static bool esUbicacionValida(String? estado, String? municipio) {
    if (estado == null || municipio == null) return false;
    final munis = _estadosYMunicipios[estado];
    if (munis == null) return false;
    return munis.contains(municipio);
  }
}