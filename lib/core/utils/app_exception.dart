/// Excepción de dominio con mensaje amigable para el usuario final (RNF03).
/// Los repositorios capturan los errores técnicos de Firebase y los traducen
/// a instancias de esta clase para que la UI nunca muestre trazas crudas.
///
/// [esBloqueado] se activa cuando el fallo es consecuencia de una cuenta
/// suspendida por el administrador, para que el controlador pueda
/// distinguirlo y navegar a la pantalla de cuenta bloqueada.
class AppException implements Exception {
  final String mensaje;
  final bool esBloqueado;

  const AppException(this.mensaje, {this.esBloqueado = false});

  @override
  String toString() => mensaje;
}
