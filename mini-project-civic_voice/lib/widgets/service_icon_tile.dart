import 'package:flutter/material.dart';

/// Service icon tile — colored square with icon, used in service grids/lists.
/// 56px by default, 16px border radius, service color at:
///   12% opacity for background, 100% for icon, 25% for border.
class ServiceIconTile extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;

  const ServiceIconTile({
    super.key,
    this.icon,
    this.emoji,
    required this.color,
    this.size = 56,
    this.iconSize = 28,
    this.borderRadius = 16,
  }) : assert(icon != null || emoji != null,
            'Either icon or emoji must be provided');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Center(
        child: emoji != null
            ? Text(emoji!, style: TextStyle(fontSize: iconSize * 0.9))
            : Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}
