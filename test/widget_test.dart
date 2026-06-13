import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paonde_app/core/data/venezuela_geo.dart';
import 'package:paonde_app/core/theme/app_colors.dart';
import 'package:paonde_app/core/utils/validadores.dart';
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

  group('Validación de correo institucional UNIMET (RegEx)', () {
    test('acepta los dominios institucionales exactos', () {
      expect(Validadores.esCorreoUnimet('ana.perez@unimet.edu.ve'), isTrue);
      expect(
          Validadores.esCorreoUnimet('j.gomez@correo.unimet.edu.ve'), isTrue);
      expect(Validadores.esCorreoUnimet('MAYUS@UNIMET.EDU.VE'), isTrue);
    });

    test('bloquea cualquier otro dominio o sufijo parecido', () {
      expect(Validadores.esCorreoUnimet('ana@gmail.com'), isFalse);
      expect(Validadores.esCorreoUnimet('ana@unimet.edu.ve.evil.com'), isFalse);
      expect(Validadores.esCorreoUnimet('ana@otracorreo.unimet.com'), isFalse);
      expect(Validadores.esCorreoUnimet('ana@falso-unimet.edu.ve'), isFalse);
      expect(Validadores.esCorreoUnimet(''), isFalse);
    });
  });

  group('Estructura geográfica estandarizada de Venezuela', () {
    test('contiene las 24 entidades federales', () {
      expect(VenezuelaGeo.estados.length, 24);
      expect(VenezuelaGeo.estados, contains('Distrito Capital'));
      expect(VenezuelaGeo.estados, contains('Miranda'));
    });

    test('encadena municipios por estado y valida pares', () {
      expect(VenezuelaGeo.municipiosDe('Distrito Capital'), ['Libertador']);
      expect(VenezuelaGeo.municipiosDe('Miranda'), contains('Chacao'));
      expect(VenezuelaGeo.municipiosDe('Miranda'), contains('Baruta'));
      expect(VenezuelaGeo.esUbicacionValida('Miranda', 'Chacao'), isTrue);
      expect(VenezuelaGeo.esUbicacionValida('Miranda', 'Maracaibo'), isFalse);
      expect(VenezuelaGeo.esUbicacionValida(null, 'Chacao'), isFalse);
      expect(VenezuelaGeo.municipiosDe('Narnia'), isEmpty);
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

  group('Flujo de reserva directa', () {
    test('sigue el orden Pendiente de Pago → Pagado → Disfrutado', () {
      expect(EstadosReserva.flujo, [
        'Pendiente de Pago',
        'Pagado',
        'Disfrutado',
      ]);
      expect(EstadosReserva.indiceDe('Pagado'), 1);
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
