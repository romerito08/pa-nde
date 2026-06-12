import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pie de página común: divisor amarillo, logo y enlaces institucionales,
/// tal como aparece en las pantallas del prototipo.
class AppFooter extends StatelessWidget {
  final bool esMovil;

  const AppFooter({super.key, required this.esMovil});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.amarillo, thickness: 1),
        Padding(
          padding: EdgeInsets.symmetric(vertical: esMovil ? 6 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/Logo.png',
                  width: esMovil ? 80 : 140, fit: BoxFit.contain),
              Flexible(
                child: Wrap(
                  spacing: esMovil ? 10 : 24,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _enlace(context, 'Sobre Nosotros', () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Pa'onde",
                        applicationVersion: '1.0.0',
                        children: const [
                          Text(
                            'Plataforma de turismo low-cost y sostenible que '
                            'conecta exploradores con aliados locales.',
                          ),
                        ],
                      );
                    }),
                    _enlace(context, 'Sé un Aliado', () {
                      Navigator.of(context).pushNamed('/registro');
                    }),
                    _enlace(context, 'Ayuda', () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Centro de ayuda'),
                          content: const Text(
                            'Escríbenos a soporte@paonde.app y te '
                            'responderemos en menos de 24 horas.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _enlace(BuildContext context, String titulo, VoidCallback alPulsar) {
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          titulo,
          style: TextStyle(
            color: AppColors.blanco,
            fontSize: esMovil ? 13 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
