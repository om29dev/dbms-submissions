import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A reusable glassmorphism card widget.
/// Provides a frosted glass surface with neon cyan border and electric blue glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final double blurSigma;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.borderColor,
    this.shadows,
    this.blurSigma = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg    = backgroundColor ?? AppColors.glassWhite;
    final bdr   = borderColor    ?? AppColors.accent.withValues(alpha: 0.15);
    final shdws = shadows ?? [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 20,
        spreadRadius: -4,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: AppColors.accent.withValues(alpha: 0.06),
        blurRadius: 40,
        spreadRadius: -8,
      ),
    ];

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: bdr, width: 1),
            boxShadow: shdws,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.accentGlow,
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A GlassCard with a horizontal colored accent stripe at top.
class GlassCardAccented extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCardAccented({
    super.key,
    required this.child,
    this.accentColor = AppColors.accent,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: borderRadius,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.2)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
