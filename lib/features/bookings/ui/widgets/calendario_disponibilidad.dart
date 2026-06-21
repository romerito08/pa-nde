import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/feedback_helper.dart';
import '../../logic/booking_controller.dart';

/// Calendario mensual interactivo (RF05). Pinta en rojo tachado los días
/// ocupados según la colección `calendarios`, en amarillo la selección del
/// usuario y deshabilita el pasado. La selección delega en el
/// [BookingController] (primer toque = inicio, segundo = fin).
class CalendarioDisponibilidad extends StatefulWidget {
  const CalendarioDisponibilidad({super.key});

  @override
  State<CalendarioDisponibilidad> createState() =>
      _CalendarioDisponibilidadState();
}

class _CalendarioDisponibilidadState extends State<CalendarioDisponibilidad> {
  late DateTime _mesVisible;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _mesVisible = DateTime(hoy.year, hoy.month);
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<BookingController>();

    if (controlador.cargandoCalendario) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controlador.error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controlador.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.blanco)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.read<BookingController>().recargarCalendario(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Nombres en español sin depender de la inicialización de locales de intl.
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    final nombreMes = '${meses[_mesVisible.month - 1]} ${_mesVisible.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.blanco),
                onPressed: () => _cambiarMes(-1),
              ),
              Text(
                nombreMes,
                style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.blanco),
                onPressed: () => _cambiarMes(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((dia) => Expanded(
                      child: Center(
                        child: Text(
                          dia,
                          style: const TextStyle(
                              color: AppColors.verdeClaro,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          ..._filasDelMes(controlador),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: const [
              _Leyenda(color: AppColors.amarillo, texto: 'Tu selección'),
              _Leyenda(color: AppColors.error, texto: 'Ocupado'),
              _Leyenda(color: AppColors.verdeClaro, texto: 'Disponible'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _filasDelMes(BookingController controlador) {
    final primerDia = DateTime(_mesVisible.year, _mesVisible.month, 1);
    final diasEnMes =
        DateTime(_mesVisible.year, _mesVisible.month + 1, 0).day;
    // weekday: lunes = 1 ... domingo = 7 → casillas vacías iniciales.
    final huecosIniciales = primerDia.weekday - 1;
    final hoy = DateTime.now();
    final hoyNormalizado = DateTime(hoy.year, hoy.month, hoy.day);

    final celdas = <Widget>[];
    for (var i = 0; i < huecosIniciales; i++) {
      celdas.add(const Expanded(child: SizedBox(height: 40)));
    }

    for (var dia = 1; dia <= diasEnMes; dia++) {
      final fecha = DateTime(_mesVisible.year, _mesVisible.month, dia);
      final esPasado = fecha.isBefore(hoyNormalizado);
      final ocupado = controlador.diaOcupado(fecha);
      final seleccionado = controlador.diaEnRangoSeleccionado(fecha);

      celdas.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: InkWell(
              onTap: esPasado || ocupado
                  ? null
                  : () {
                      final advertencia = context
                          .read<BookingController>()
                          .seleccionarDia(fecha);
                      if (advertencia != null && context.mounted) {
                        FeedbackHelper.mostrarAdvertencia(context, advertencia);
                      }
                    },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? AppColors.amarillo
                      : ocupado
                          ? AppColors.error.withValues(alpha: 0.25)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: ocupado
                      ? Border.all(color: AppColors.error, width: 0.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$dia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          seleccionado ? FontWeight.w700 : FontWeight.w400,
                      color: seleccionado
                          ? Colors.black
                          : esPasado
                              ? AppColors.verdeClaro.withValues(alpha: 0.4)
                              : ocupado
                                  ? AppColors.error
                                  : AppColors.blanco,
                      decoration:
                          ocupado ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Completa la última fila con huecos.
    while (celdas.length % 7 != 0) {
      celdas.add(const Expanded(child: SizedBox(height: 40)));
    }

    final filas = <Widget>[];
    for (var i = 0; i < celdas.length; i += 7) {
      filas.add(Row(children: celdas.sublist(i, i + 7)));
    }
    return filas;
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto,
            style: const TextStyle(color: AppColors.verdeClaro, fontSize: 12)),
      ],
    );
  }
}
