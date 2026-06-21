abstract class PriceStrategy {
  double calcularTotal(double precioBase, int unidades);
}

class RegularPriceStrategy implements PriceStrategy {
  @override
  double calcularTotal(double precioBase, int unidades) {
    return precioBase * unidades;
  }
}

/// Siempre devuelve la tarifa regular, independientemente del día.
PriceStrategy estrategiaPara(DateTime fechaInicio) => RegularPriceStrategy();
