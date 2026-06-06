import 'package:flutter/material.dart';
import 'login_repository.dart';

class LoginController extends ChangeNotifier {
  final LoginRepository _repository = LoginRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para iniciar sesión (se mantiene igual)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final user = await _repository.loginWithEmail(email, password);

    _setLoading(false);

    if (user == null) {
      _setError('Credenciales inválidas. Verifica tu correo y contraseña.');
      return false;
    }
    return true;
  }

  // CORRECCIÓN: Ahora el método acepta de forma nombrada (con {}) todos los datos requeridos
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String estado,
    required String municipio,
  }) async {
    _setLoading(true);
    _clearError();

    // Enviamos de forma correcta todos los datos hacia el repositorio actualizado
    final user = await _repository.registerWithEmail(
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
      estado: estado,
      municipio: municipio,
    );

    _setLoading(false);

    if (user == null) {
      _setError('Error al registrarse. El correo podría ya estar en uso.');
      return false;
    }
    return true;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}