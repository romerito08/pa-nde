import 'package:flutter/material.dart';

import '../data/venezuela_geo.dart';
import '../theme/app_colors.dart';

/// Par de dropdowns encadenados Estado → Municipio que consumen la
/// estructura estandarizada de [VenezuelaGeo]. Reemplaza a todos los inputs
/// de texto libre de Estado/Municipio del sistema (registro, publicación de
/// servicios, filtros y perfil).
class SelectorGeografico extends StatelessWidget {
  final String? estado;
  final String? municipio;
  final void Function(String? estado, String? municipio) onChanged;

  /// Si es `true`, agrega la opción "Todos" (valor `null`) en ambos
  /// dropdowns — usado en los filtros de búsqueda del Explorador.
  final bool permitirTodos;

  /// Coloca los dropdowns en fila (escritorio) o en columna (móvil).
  final bool enFila;

  const SelectorGeografico({
    super.key,
    required this.estado,
    required this.municipio,
    required this.onChanged,
    this.permitirTodos = false,
    this.enFila = true,
  });

  @override
  Widget build(BuildContext context) {
    final campoEstado = _dropdownEstado();
    final campoMunicipio = _dropdownMunicipio();

    if (enFila) {
      return Row(
        children: [
          Expanded(child: campoEstado),
          const SizedBox(width: 12),
          Expanded(child: campoMunicipio),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        campoEstado,
        const SizedBox(height: 12),
        campoMunicipio,
      ],
    );
  }

  Widget _dropdownEstado() {
    return DropdownButtonFormField<String?>(
      key: ValueKey('estado-$estado'),
      initialValue: estado,
      isExpanded: true,
      dropdownColor: AppColors.verde,
      style: const TextStyle(color: AppColors.blanco, fontSize: 14),
      decoration: const InputDecoration(
        labelText: 'Estado',
        prefixIcon:
            Icon(Icons.map_outlined, color: AppColors.verdeClaro, size: 20),
      ),
      items: [
        if (permitirTodos)
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todos los estados',
                style: TextStyle(color: AppColors.verdeClaro)),
          ),
        ...VenezuelaGeo.estados.map(
          (nombre) => DropdownMenuItem<String?>(
            value: nombre,
            child: Text(nombre,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.blanco)),
          ),
        ),
      ],
      // Al cambiar de estado se invalida el municipio anterior.
      onChanged: (nuevoEstado) => onChanged(nuevoEstado, null),
    );
  }

  Widget _dropdownMunicipio() {
    final municipios = VenezuelaGeo.municipiosDe(estado);
    return DropdownButtonFormField<String?>(
      key: ValueKey('municipio-$estado-$municipio'),
      initialValue: municipios.contains(municipio) ? municipio : null,
      isExpanded: true,
      dropdownColor: AppColors.verde,
      style: const TextStyle(color: AppColors.blanco, fontSize: 14),
      decoration: const InputDecoration(
        labelText: 'Municipio',
        prefixIcon: Icon(Icons.location_city_outlined,
            color: AppColors.verdeClaro, size: 20),
      ),
      items: [
        if (permitirTodos || municipios.isEmpty)
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              municipios.isEmpty
                  ? 'Elige un estado primero'
                  : 'Todos los municipios',
              style: const TextStyle(color: AppColors.verdeClaro),
            ),
          ),
        ...municipios.map(
          (nombre) => DropdownMenuItem<String?>(
            value: nombre,
            child: Text(nombre,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.blanco)),
          ),
        ),
      ],
      onChanged:
          municipios.isEmpty ? null : (nuevo) => onChanged(estado, nuevo),
    );
  }
}
