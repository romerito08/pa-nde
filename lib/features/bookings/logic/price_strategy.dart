/// Patrón Strategy para el cálculo de tarifas. Se conserva la regla de
/// negocio existente del proyecto: las estadías que comienzan en fin de
/// semana tienen un recargo del 15 %.
abstract class PriceStrategy {
  double calcularTotal(double precioBase, int unidades);
}

/// Tarifa regular (inicio de lunes a jueves).
class RegularPriceStrategy implements PriceStrategy {
  @override
  double calcularTotal(double precioBase, int unidades) {
    return precioBase * unidades;
  }
}

/// Tarifa de fin de semana (inicio viernes o sábado): +15 %.
class WeekendPriceStrategy implements PriceStrategy {
  @override
  double calcularTotal(double precioBase, int unidades) {
    return (precioBase * unidades) * 1.15;
  }
}

/// Selecciona la estrategia según el día de inicio de la reserva.
PriceStrategy estrategiaPara(DateTime inicio) {
  if (inicio.weekday == DateTime.friday ||
      inicio.weekday == DateTime.saturday) {
    return WeekendPriceStrategy();
  }
  return RegularPriceStrategy();
}
