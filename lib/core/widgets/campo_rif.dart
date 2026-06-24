import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Campo de RIF venezolano segmentado: selector del tipo de persona
/// (J, V, E, G, C) + campo numérico de hasta 9 dígitos.
/// Compatible con [Form.validate()].
class CampoRif extends StatefulWidget {
  final String? valorInicial;
  final void Function(String rif) onChanged;

  const CampoRif({
    super.key,
    this.valorInicial,
    required this.onChanged,
  });

  @override
  State<CampoRif> createState() => _CampoRifState();
}

class _CampoRifState extends State<CampoRif> {
  static const _prefijos = ['J', 'V', 'E', 'G', 'C'];

  late String _prefijo;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final (p, n) = _parsear(widget.valorInicial);
    _prefijo = p;
    _ctrl = TextEditingController(text: n);
  }

  @override
  void didUpdateWidget(CampoRif old) {
    super.didUpdateWidget(old);
    if (old.valorInicial != widget.valorInicial &&
        widget.valorInicial != null &&
        widget.valorInicial!.isNotEmpty) {
      final (p, n) = _parsear(widget.valorInicial);
      setState(() => _prefijo = p);
      _ctrl.text = n;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static (String, String) _parsear(String? v) {
    if (v == null || v.isEmpty) return ('J', '');
    final upper = v.trim().toUpperCase();
    if (upper.isNotEmpty && 'JVEGC'.contains(upper[0])) {
      final numero = upper.substring(1).replaceAll(RegExp(r'\D'), '');
      return (upper[0], numero);
    }
    return ('J', upper.replaceAll(RegExp(r'\D'), ''));
  }

  void _notificar() {
    widget.onChanged('$_prefijo-${_ctrl.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: DropdownButtonFormField<String>(
            key: ValueKey(_prefijo),
            initialValue: _prefijo,
            isExpanded: true,
            dropdownColor: AppColors.verde,
            style: const TextStyle(
              color: AppColors.amarillo,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              labelText: 'Tipo',
            ),
            items: _prefijos
                .map((p) => DropdownMenuItem<String>(
                      value: p,
                      child: Text(
                        p,
                        style: const TextStyle(
                          color: AppColors.amarillo,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (p) {
              setState(() => _prefijo = p!);
              _notificar();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 9,
            style: const TextStyle(color: AppColors.blanco),
            decoration: const InputDecoration(
              labelText: 'RIF (hasta 9 dígitos)',
              hintText: '123456789',
              counterText: '',
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _notificar(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo obligatorio.';
              if (v.length < 5) return 'RIF inválido (mín. 5 dígitos).';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
