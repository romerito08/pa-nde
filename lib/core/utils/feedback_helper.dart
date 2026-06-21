import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Utilidades de retroalimentación visual (RNF03): toda excepción capturada
/// en los controladores se comunica con SnackBars o AlertDialogs amigables,
/// garantizando que la app nunca quede congelada ni en carga infinita.
class FeedbackHelper {
  FeedbackHelper._();

  static void mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(mensaje,
                      style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
  }

  static void mostrarExito(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.exito,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(mensaje,
                      style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
  }

  static void mostrarAdvertencia(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.advertencia,
          content: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Colors.black, size: 20),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(mensaje,
                      style: const TextStyle(color: Colors.black))),
            ],
          ),
        ),
      );
  }

  /// Diálogo de confirmación reutilizable. Devuelve `true` solo si el usuario
  /// pulsa la acción afirmativa.
  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(textoCancelar,
                style: const TextStyle(color: AppColors.verdeClaro)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}
