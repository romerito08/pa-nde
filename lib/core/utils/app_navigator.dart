import 'package:flutter/material.dart';

/// Clave global del Navigator raíz de la app.
/// Permite navegar programáticamente desde fuera del árbol de widgets
/// (p. ej. cuando el AuthController detecta que la cuenta fue bloqueada
/// mientras el usuario estaba activo en sesión).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
