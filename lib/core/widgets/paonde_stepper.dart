import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Stepper lineal del design system de Figma (frame "Steppers"): círculos
/// numerados de 40×40 px unidos por una línea de 5 px. El paso activo y los
/// completados se pintan en amarillo #F2DE00 con número negro; los pendientes
/// en verde con borde verde claro.
class PaondeStepper extends StatelessWidget {
  final List<String> pasos;
  final int pasoActual;

  const PaondeStepper({
    super.key,
    required this.pasos,
    required this.pasoActual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < pasos.length; i++) ...[
              _circulo(i),
              if (i < pasos.length - 1) Expanded(child: _linea(i)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < pasos.length; i++)
              SizedBox(
                width: 80,
                child: Text(
                  pasos[i],
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == pasos.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        i == pasoActual ? FontWeight.w700 : FontWeight.w400,
                    color: i <= pasoActual
                        ? AppColors.amarillo
                        : AppColors.verdeClaro,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _circulo(int indice) {
    final alcanzado = indice <= pasoActual;
    final completado = indice < pasoActual;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: alcanzado ? AppColors.amarillo : AppColors.verde,
        border: Border.all(
          color: alcanzado ? AppColors.amarillo : AppColors.verdeClaro,
          width: 1.5,
        ),
      ),
      child: Center(
        child: completado
            ? const Icon(Icons.check, size: 20, color: Colors.black)
            : Text(
                '${indice + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: alcanzado ? Colors.black : AppColors.verdeClaro,
                ),
              ),
      ),
    );
  }

  Widget _linea(int indice) {
    final completado = indice < pasoActual;
    return Container(
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: completado ? AppColors.amarillo : AppColors.verde,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
