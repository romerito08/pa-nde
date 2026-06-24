import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget que reemplaza a [Image.network] con soporte para data URLs base64
/// (imágenes guardadas directamente en Firestore sin servicio de almacenamiento
/// externo). En web, el navegador resuelve data URLs nativamente; en
/// móvil/escritorio se decodifican con [Image.memory].
class ImagenServicio extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  const ImagenServicio({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  bool get _esDataUrl => url.startsWith('data:');

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    // En web el navegador soporta data URLs de forma nativa.
    if (!_esDataUrl || kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
      );
    }

    // En móvil/escritorio con data URL: extraer bytes y usar Image.memory.
    try {
      final b64 = url.contains(',') ? url.split(',').last : url;
      return Image.memory(
        base64Decode(b64),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
        gaplessPlayback: true,
      );
    } catch (e, st) {
      if (errorBuilder != null) {
        return Builder(builder: (ctx) => errorBuilder!(ctx, e, st));
      }
      return SizedBox(width: width, height: height);
    }
  }
}
