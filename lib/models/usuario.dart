import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles oficiales del sistema (RF01/RF15). El rol "Administrador" se asigna
/// manualmente en la consola de Firestore por seguridad. Los Exploradores se
/// registran desde /registro (con correo institucional UNIMET) y los Aliados
/// exclusivamente desde la página "Sé un Aliado" del footer de la Landing.
class RolesUsuario {
  RolesUsuario._();

  static const String explorador = 'Explorador';
  static const String aliado = 'Aliado';
  static const String administrador = 'Administrador';

  static const List<String> registrables = [explorador, aliado];
}

/// Documento de la colección `usuarios` en Firestore.
class Usuario {
  final String uid;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String estado;
  final String municipio;
  final String rol;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.estado,
    required this.municipio,
    required this.rol,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  bool get esAliado => rol == RolesUsuario.aliado;
  bool get esAdministrador => rol == RolesUsuario.administrador;

  factory Usuario.fromFirestore(Map<String, dynamic> data, String uid) {
    return Usuario(
      uid: uid,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      correo: data['correo'] ?? '',
      telefono: data['telefono'] ?? '',
      estado: data['estado'] ?? '',
      municipio: data['municipio'] ?? '',
      rol: data['rol'] ?? RolesUsuario.explorador,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'estado': estado,
      'municipio': municipio,
      'rol': rol,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }

  /// Copia con los campos editables del perfil (RF de modificación de
  /// perfil): nombre, apellido, teléfono y ubicación.
  Usuario copyWith({
    String? nombre,
    String? apellido,
    String? telefono,
    String? estado,
    String? municipio,
  }) {
    return Usuario(
      uid: uid,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
      municipio: municipio ?? this.municipio,
      rol: rol,
    );
  }
}
