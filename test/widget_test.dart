import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paonde_app/core/theme/app_colors.dart';
import 'package:paonde_app/core/widgets/paonde_stepper.dart';
import 'package:paonde_app/features/bookings/logic/price_strategy.dart';
import 'package:paonde_app/models/reserva.dart';

void main() {
  group('PaondeStepper (design system de Figma)', () {
    testWidgets('pinta los 4 pasos y marca el activo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaondeStepper(
              pasos: ['Identidad', 'Costos', 'Ubicación', 'Éxito'],
              pasoActual: 1,
            ),
          ),
        ),
      );

      expect(find.text('Identidad'), findsOneWidget);
      expect(find.text('Costos'), findsOneWidget);
      expect(find.text('Ubicación'), findsOneWidget);
      expect(find.text('Éxito'), findsOneWidget);
      // El paso 1 (completado) muestra check; el 2 está activo con número.
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('Estrategia de precios', () {
    test('aplica recargo del 15 % cuando inicia en viernes', () {
      final viernes = DateTime(2026, 6, 12); // viernes
      final total = estrategiaPara(viernes).calcularTotal(100, 2);
      expect(total, closeTo(230, 0.001));
    });

    test('tarifa regular entre semana', () {
      final lunes = DateTime(2026, 6, 8); // lunes
      final total = estrategiaPara(lunes).calcularTotal(100, 2);
      expect(total, 200);
    });
  });

  group('Flujo de estados de reserva', () {
    test('sigue el orden Solicitado → Aceptado → Pagado → Disfrutado', () {
      expect(EstadosReserva.flujo, [
        'Solicitado',
        'Aceptado',
        'Pagado',
        'Disfrutado',
      ]);
      expect(EstadosReserva.indiceDe('Pagado'), 2);
      expect(EstadosReserva.indiceDe('desconocido'), 0);
    });
  });

  group('Paleta de Figma', () {
    test('expone los tokens cromáticos oficiales', () {
      expect(AppColors.amarillo, const Color(0xFFF2DE00));
      expect(AppColors.verdeOscuro, const Color(0xFF1F261B));
      expect(AppColors.verde, const Color(0xFF293324));
      expect(AppColors.verdeClaro, const Color(0xFF5C6657));
    });
  });
}
