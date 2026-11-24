import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/rashi/rashi_info.dart';

class RashiArtwork extends StatelessWidget {
  const RashiArtwork({super.key, required this.rashi, this.borderRadius = const BorderRadius.all(Radius.circular(18))});
  final RashiInfo rashi;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: SvgPicture.asset(
      rashi.image,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => Container(
        color: const Color(0xFF35264F),
        alignment: Alignment.center,
        child: Text(rashi.symbol, style: const TextStyle(color: Color(0xFFFFDCA0), fontSize: 58)),
      ),
    ),
  );
}
