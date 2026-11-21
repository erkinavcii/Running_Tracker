import 'package:flutter/material.dart';

/// Running pictograms generated locally (Qwen-Image via ComfyUI) and stored
/// as single-colour alpha masks, so they can be tinted with any theme colour.
enum Picto {
  sprint('assets/pictograms/sprint.png'),
  jog('assets/pictograms/jog.png'),
  start('assets/pictograms/start.png'),
  finish('assets/pictograms/finish.png');

  const Picto(this.asset);
  final String asset;
}

class Pictogram extends StatelessWidget {
  final Picto picto;
  final double size;
  final Color color;
  final String? semanticLabel;

  const Pictogram(
    this.picto, {
    super.key,
    required this.size,
    required this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      picto.asset,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
