import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles oficiales del sistema (RF01/RF15). El rol "Administrador" se asigna
/// manualmente en la consola de Firestore por seguridad; el registro público
/// solo permite "Explorador" y "Aliado".
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
  final String estado;
  final String municipio;
  final String rol;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.correo,
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
      'estado': estado,
      'municipio': municipio,
      'rol': rol,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }
}
