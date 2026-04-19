import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// The premium Indian card widget for the Bharat Silicon design language.
/// Dark warm background, optional gold border, saffron top accent line.
class IndianCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  /// When true, uses gold border and gradient background (featured card).
  final bool isPremium;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showTopAccent;
  final double? width;
  final double? height;

  const IndianCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.isPremium = false,
    this.onTap,
    this.backgroundColor,
    this.showTopAccent = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? (isPremium ? AppColors.bgDark : AppColors.bgMid);
    final borderColor = isPremium
        ? AppColors.gold.withValues(alpha: 0.25)
        : AppColors.surfaceBorder;

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        gradient: isPremium
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgDark, AppColors.bgMid],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          if (isPremium)
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 0,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Inner gold top accent line
            if (showTopAccent)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(borderRadius)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.saffron.withValues(alpha: 0.6),
                        AppColors.gold.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Frosted glass style card — kept for backward compatibility with legacy screens.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: padding,
      width: width,
      height: height,
      onTap: onTap,
      child: child,
    );
  }
}
