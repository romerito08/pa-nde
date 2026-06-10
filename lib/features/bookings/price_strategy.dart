/// Interfaz base para la estrategia de precios
abstract class PriceStrategy {
  double calcularTotal(double precioPorNoche, int noches);
}

/// Estrategia 1: Tarifa Regular (Lunes a Jueves)
class RegularPriceStrategy implements PriceStrategy {
  @override
  double calcularTotal(double precioPorNoche, int noches) {
    return precioPorNoche * noches;
  }
}

/// Estrategia 2: Tarifa de Fin de Semana (Viernes a Domingo con +15%)
class WeekendPriceStrategy implements PriceStrategy {
  @override
  double calcularTotal(double precioPorNoche, int noches) {
    return (precioPorNoche * noches) * 1.15;
  }
}