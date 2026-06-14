import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Campo de teléfono venezolano segmentado: selector de código de operadora
/// + campo de exactamente 7 dígitos. Compatible con [Form.validate()].
class CampoTelefono extends StatefulWidget {
  final String? valorInicial;
  final void Function(String telefono) onChanged;

  const CampoTelefono({
    super.key,
    this.valorInicial,
    required this.onChanged,
  });

  @override
  State<CampoTelefono> createState() => _CampoTelefonoState();
}

class _CampoTelefonoState extends State<CampoTelefono> {
  static const _codigos = [
    // Móvil
    '0412', '0414', '0416', '0424', '0426',
    // Fijos CANTV (principales por estado)
    '0212', '0234', '0235', '0238', '0239',
    '0240', '0241', '0242', '0243', '0244',
    '0245', '0246', '0247', '0248', '0249',
    '0251', '0252', '0253', '0255', '0256',
    '0257', '0258', '0259', '0261', '0262',
    '0263', '0264', '0265', '0266', '0267',
    '0268', '0269', '0271', '0272', '0274',
    '0275', '0276', '0278', '0281', '0282',
    '0283', '0284', '0285', '0286', '0287',
    '0288', '0289', '0291', '0292', '0293',
    '0294', '0295', '0296',
  ];

  late String _codigo;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final (c, n) = _parsear(widget.valorInicial);
    _codigo = c;
    _ctrl = TextEditingController(text: n);
  }

  @override
  void didUpdateWidget(CampoTelefono old) {
    super.didUpdateWidget(old);
    if (old.valorInicial != widget.valorInicial &&
        widget.valorInicial != null &&
        widget.valorInicial!.isNotEmpty) {
      final (c, n) = _parsear(widget.valorInicial);
      setState(() => _codigo = c);
      _ctrl.text = n;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static (String, String) _parsear(String? v) {
    if (v == null || v.isEmpty) return ('0414', '');
    final limpio = v.replaceAll(RegExp(r'[\s\-]'), '');
    final normalizado = limpio.startsWith('58') && limpio.length > 2
        ? '0${limpio.substring(2)}'
        : limpio;
    for (final c in _codigos) {
      if (normalizado.startsWith(c)) {
        return (c, normalizado.substring(c.length));
      }
    }
    return ('0414', normalizado.length >= 7
        ? normalizado.substring(normalizado.length - 7)
        : normalizado);
  }

  void _notificar() {
    if (_ctrl.text.length == 7) {
      widget.onChanged('$_codigo-${_ctrl.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: DropdownButtonFormField<String>(
            key: ValueKey(_codigo),
            initialValue: _codigo,
            isExpanded: true,
            dropdownColor: AppColors.verde,
            style: const TextStyle(color: AppColors.blanco, fontSize: 14),
            menuMaxHeight: 260,
            decoration: const InputDecoration(
              labelText: 'Código',
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: AppColors.verdeClaro,
                size: 18,
              ),
            ),
            items: _codigos.map((c) {
              final esMovil = c.startsWith('04');
              return DropdownMenuItem<String>(
                value: c,
                child: Text(
                  c,
                  style: TextStyle(
                    color: esMovil ? AppColors.amarillo : AppColors.blanco,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
            onChanged: (c) {
              setState(() => _codigo = c!);
              _notificar();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 7,
            style: const TextStyle(color: AppColors.blanco),
            decoration: const InputDecoration(
              labelText: 'Número (7 dígitos)',
              hintText: '1234567',
              counterText: '',
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _notificar(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa el número.';
              if (v.length != 7) return 'Deben ser exactamente 7 dígitos.';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
