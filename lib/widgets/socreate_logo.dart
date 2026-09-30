import 'package:flutter/material.dart';

/// Official SoCreate logo with the "Bring Your Stories to Life" tagline.
/// Rendered from `design/socreate_logo.pdf`.
class SoCreateLogo extends StatelessWidget {
  const SoCreateLogo({super.key, this.width = 150});

  final double width;

  static const _aspectRatio = 1399 / 429;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/socreate_logo.png',
      width: width,
      height: width / _aspectRatio,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'SoCreate. Bring Your Stories to Life',
    );
  }
}
