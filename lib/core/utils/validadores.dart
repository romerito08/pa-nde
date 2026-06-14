/// Validadores de datos compartidos por la capa de cliente (formularios) y
/// la capa de datos (guardas de los repositorios antes de tocar Firebase).
class Validadores {
  Validadores._();

  /// RegEx institucional UNIMET: el correo de un Explorador debe terminar
  /// estrictamente en '@unimet.edu.ve' o '@correo.unimet.edu.ve'.
  static final RegExp correoUnimet = RegExp(
    r'^[A-Za-z0-9._%+-]+@(correo\.)?unimet\.edu\.ve$',
    caseSensitive: false,
  );

  /// RegEx genérico de correo electrónico (para Aliados y validación base).
  static final RegExp correoGenerico = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  /// Teléfono venezolano: 0XXX-XXXXXXX con o sin guion/espacios, o formato
  /// internacional +58.
  static final RegExp telefonoVenezolano = RegExp(
    r'^(\+58[\s-]?|0)(2\d{2}|4\d{2})[\s-]?\d{7}$',
  );

  static bool esCorreoUnimet(String correo) =>
      correoUnimet.hasMatch(correo.trim());

  static bool esCorreoValido(String correo) =>
      correoGenerico.hasMatch(correo.trim());

  static bool esTelefonoValido(String telefono) =>
      telefonoVenezolano.hasMatch(telefono.trim());

  /// Contraseña segura: mínimo 4 letras, 1 mayúscula y 4 números.
  static String? validarContrasena(String? v) {
    if (v == null || v.isEmpty) return 'Crea una contraseña.';
    final letras = RegExp(r'[A-Za-z]').allMatches(v).length;
    final mayusculas = RegExp(r'[A-Z]').allMatches(v).length;
    final numeros = RegExp(r'[0-9]').allMatches(v).length;
    if (letras < 4) return 'Debe tener al menos 4 letras.';
    if (mayusculas < 1) return 'Debe incluir al menos 1 mayúscula.';
    if (numeros < 4) return 'Debe tener al menos 4 números.';
    return null;
  }
}
