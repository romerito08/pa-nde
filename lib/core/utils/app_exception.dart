/// Excepción de dominio con mensaje amigable para el usuario final (RNF03).
/// Los repositorios capturan los errores técnicos de Firebase y los traducen
/// a instancias de esta clase para que la UI nunca muestre trazas crudas.
class AppException implements Exception {
  final String mensaje;

  const AppException(this.mensaje);

  @override
  String toString() => mensaje;
}
