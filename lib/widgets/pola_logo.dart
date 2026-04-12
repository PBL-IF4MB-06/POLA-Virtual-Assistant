import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Brand logo from [assetPath] (default: bundled PNG under `brand/logo/`).
///
/// **Web:** also expects the same file at [webStaticPath] under the `web/`
/// folder so `flutter run -d chrome` can load it from the site root. Keep that
/// copy in sync when you change the logo.
class PolaLogo extends StatelessWidget {
  const PolaLogo({
    super.key,
    this.size = 44,
    this.assetPath = 'brand/logo/pola_logo.png',
    this.webStaticPath = 'brand/logo/pola_logo.png',
  });

  final double size;

  /// Declared under `flutter: assets:` for mobile/desktop.
  final String assetPath;

  /// Path relative to `web/` (and to the app URL origin).
  final String webStaticPath;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.smart_toy_outlined, size: size * 0.7),
        );

    return kIsWeb
        ? Image.network(
            Uri.base.resolve(webStaticPath).toString(),
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            semanticLabel: 'POLA',
            errorBuilder: (context, error, stackTrace) => fallback(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return fallback();
            },
          )
        : Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            semanticLabel: 'POLA',
            errorBuilder: (context, error, stackTrace) => fallback(),
          );
  }
}
