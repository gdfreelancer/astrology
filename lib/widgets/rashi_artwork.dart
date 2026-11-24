import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/rashi/rashi_info.dart';

class RashiArtwork extends StatelessWidget {
  const RashiArtwork({
    super.key,
    required this.rashi,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final RashiInfo rashi;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          rashi.image,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => const ColoredBox(color: Color(0xFF35264F)),
        ),
        Center(
          child: Text(
            rashi.symbol,
            style: const TextStyle(
              fontFamily: 'Noto Sans Symbols',
              fontSize: 88,
              height: 1,
              color: Color(0xFFFFDCA0),
              shadows: [Shadow(color: Color(0xAA000000), blurRadius: 12, offset: Offset(0, 3))],
            ),
          ),
        ),
      ],
    ),
  );
}
