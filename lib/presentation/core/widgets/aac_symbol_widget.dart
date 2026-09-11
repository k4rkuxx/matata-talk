import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

class AACSymbolWidget extends StatelessWidget {
  final String? assetPath;
  final int? arasaacId;
  final String? fallbackEmoji;
  final double size;

  const AACSymbolWidget({
    super.key,
    this.assetPath,
    this.arasaacId,
    this.fallbackEmoji,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Si hay un asset vectorial local compilado (.vg o .svg)
    if (assetPath != null && assetPath!.isNotEmpty) {
      if (assetPath!.endsWith('.vg')) {
        return VectorGraphic(
          loader: AssetBytesLoader(assetPath!),
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      } else {
        return Image.asset(
          assetPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
    }

    // 2. Si se proporciona un ID de ARASAAC, cargar desde la API oficial con caché
    if (arasaacId != null) {
      final url = 'https://api.arasaac.org/api/pictograms/$arasaacId?url=true&download=false';
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    // 3. Fallback a emoji o ícono por defecto
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Text(
      fallbackEmoji ?? '💬',
      style: TextStyle(fontSize: size * 0.7),
    );
  }
}
