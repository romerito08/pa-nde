class Hotel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precioPorNoche;
  final String ubicacion;
  final String imagenUrl;
  final int capacidad;
  final double calificacionPromedio; // promedio de reseñas
  final String creadoPor; // uid del aliado

  Hotel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioPorNoche,
    required this.ubicacion,
    required this.imagenUrl,
    required this.capacidad,
    required this.calificacionPromedio,
    required this.creadoPor,
  });

  // Convertir desde Firestore
  factory Hotel.fromFirestore(Map<String, dynamic> data, String id) {
    return Hotel(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precioPorNoche: (data['precioPorNoche'] ?? 0).toDouble(),
      ubicacion: data['ubicacion'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
      capacidad: data['capacidad'] ?? 0,
      calificacionPromedio: (data['calificacionPromedio'] ?? 0).toDouble(),
      creadoPor: data['creadoPor'] ?? '',
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precioPorNoche': precioPorNoche,
      'ubicacion': ubicacion,
      'imagenUrl': imagenUrl,
      'capacidad': capacidad,
      'calificacionPromedio': calificacionPromedio,
      'creadoPor': creadoPor,
    };
  }
}