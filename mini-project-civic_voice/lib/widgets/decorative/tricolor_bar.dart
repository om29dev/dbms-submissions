import 'package:flutter/material.dart';

/// Tricolor bar widget — Indian flag saffron | white | green.
/// Used as section separators and bottom-of-screen accent.
class TricolorBar extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const TricolorBar({
    super.key,
    this.height = 2,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? MediaQuery.of(context).size.width;

    Widget bar = Container(
      height: height,
      width: w,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.333, 0.333, 0.666, 0.666, 1.0],
          colors: [
            Color(0xFFFF6B1A), // Saffron
            Color(0xFFFF6B1A),
            Color(0xFFFFF8F0), // White (warm)
            Color(0xFFFFF8F0),
            Color(0xFF0A7A3E), // India Green
            Color(0xFF0A7A3E),
          ],
        ),
      ),
    );

    return bar;
  }
}

/// Three‐dot tricolor micro divider — use between text sections.
class TricolorDivider extends StatelessWidget {
  final double dotSize;
  final double spacing;

  const TricolorDivider({
    super.key,
    this.dotSize = 4,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(const Color(0xFFFF6B1A)),
        SizedBox(width: spacing),
        _dot(const Color(0xFFFFF8F0)),
        SizedBox(width: spacing),
        _dot(const Color(0xFF0A7A3E)),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
