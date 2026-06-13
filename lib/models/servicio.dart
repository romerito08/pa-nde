import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de servicio publicables por un Aliado (RF04).
class TiposServicio {
  TiposServicio._();

  static const String alojamiento = 'Alojamiento';
  static const String experiencia = 'Experiencia';

  static const List<String> todos = [alojamiento, experiencia];
}

/// Estados de publicación de un servicio en el catálogo.
class EstadosPublicacion {
  EstadosPublicacion._();

  static const String activo = 'Activo';
  static const String pausado = 'Pausado';
}

/// Documento de la colección `servicios` en Firestore. La ubicación usa la
/// estructura estandarizada de Venezuela: Estado + Municipio (dropdowns) y
/// el campo Dirección como complemento textual.
class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final String tipo;
  final double precio;
  final int capacidad;
  final String estado;
  final String municipio;
  final String direccion;
  final List<String> imagenes;
  final double calificacionPromedio;
  final int totalResenas;
  final String estadoPublicacion;
  final String creadoPor;

  const Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.precio,
    required this.capacidad,
    required this.estado,
    required this.municipio,
    required this.direccion,
    required this.imagenes,
    required this.calificacionPromedio,
    required this.totalResenas,
    required this.estadoPublicacion,
    required this.creadoPor,
  });

  bool get esExperiencia => tipo == TiposServicio.experiencia;

  /// Unidad de cobro: las experiencias se cobran por persona y los
  /// alojamientos por noche.
  String get unidadPrecio => esExperiencia ? 'persona' : 'noche';

  /// Ubicación legible "Municipio, Estado".
  String get ubicacion {
    if (municipio.isEmpty && estado.isEmpty) return '';
    if (municipio.isEmpty) return estado;
    if (estado.isEmpty) return municipio;
    return '$municipio, $estado';
  }

  /// Primera imagen asociada o cadena vacía si el aliado no cargó URLs.
  String get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : '';

  factory Servicio.fromFirestore(Map<String, dynamic> data, String id) {
    return Servicio(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      tipo: data['tipo'] ?? TiposServicio.alojamiento,
      precio: (data['precio'] ?? 0).toDouble(),
      capacidad: (data['capacidad'] ?? 1).toInt(),
      estado: data['estado'] ?? '',
      // Compatibilidad con documentos antiguos que usaban 'ciudad' libre.
      municipio: data['municipio'] ?? data['ciudad'] ?? '',
      direccion: data['direccion'] ?? '',
      imagenes: List<String>.from(data['imagenes'] ?? const []),
      calificacionPromedio: (data['calificacionPromedio'] ?? 0).toDouble(),
      totalResenas: (data['totalResenas'] ?? 0).toInt(),
      estadoPublicacion: data['estadoPublicacion'] ?? EstadosPublicacion.activo,
      creadoPor: data['creadoPor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'precio': precio,
      'capacidad': capacidad,
      'estado': estado,
      'municipio': municipio,
      'direccion': direccion,
      'imagenes': imagenes,
      'calificacionPromedio': calificacionPromedio,
      'totalResenas': totalResenas,
      'estadoPublicacion': estadoPublicacion,
      'creadoPor': creadoPor,
      'actualizadoEn': FieldValue.serverTimestamp(),
    };
  }
}
