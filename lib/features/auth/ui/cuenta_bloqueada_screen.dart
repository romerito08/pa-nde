import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pantalla que se muestra cuando un usuario intenta iniciar sesión con una
/// cuenta suspendida por el administrador, o cuando el administrador bloquea
/// la cuenta mientras el usuario está activo en la app.
class CuentaBloqueadaScreen extends StatelessWidget {
  const CuentaBloqueadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final esMovil = constraints.maxWidth < 850;
          return Stack(
            children: [
              // Fondo decorativo igual al login
              if (!esMovil)
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/imageninicio.png',
                              fit: BoxFit.cover),
                          Container(color: Colors.black26),
                          Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.55,
                              child: Image.asset('assets/Logo.png',
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _contenido(context, esMovil)),
                  ],
                )
              else
                _contenido(context, esMovil),
              // Botón cerrar
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  tooltip: 'Volver al inicio',
                  icon: const Icon(Icons.close,
                      color: AppColors.blanco, size: 28),
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, bool esMovil) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: esMovil ? 32 : 48, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (esMovil) ...[
                  Image.asset('assets/Logo.png', width: 120),
                  const SizedBox(height: 32),
                ],
                // Icono de bloqueo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.5),
                        width: 2),
                  ),
                  child: const Icon(Icons.block,
                      color: AppColors.error, size: 52),
                ),
                const SizedBox(height: 28),
                Text(
                  'Cuenta suspendida',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tu cuenta ha sido suspendida por el administrador de Pa\'onde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.blanco, fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Si crees que esto es un error, comunícate con el equipo de soporte para revisar tu caso.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.verdeClaro, fontSize: 14),
                ),
                const SizedBox(height: 40),
                // Botón volver a inicio
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false),
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text('Volver al inicio'),
                  ),
                ),
                const SizedBox(height: 12),
                // Enlace para iniciar sesión con otra cuenta
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false),
                  child: const Text('Iniciar sesión con otra cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
