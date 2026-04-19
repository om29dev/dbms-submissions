import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

/// A premium neon CTA button with gradient fill, scale press animation,
/// shimmer loading state, and an outlined variant.
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? labelStyle;
  final List<Color>? gradientColors;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 54,
    this.borderRadius = 12,
    this.labelStyle,
    this.gradientColors,
  });

  /// Convenience constructor for an outlined variant.
  const NeonButton.outlined({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.borderRadius = 12,
    this.labelStyle,
    this.gradientColors,
  }) : isOutlined = true;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.isLoading || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (!_isPressed) return;
    if (mounted) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (!_isPressed) return;
    if (mounted) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null && !widget.isLoading;
    final gradColors =
        widget.gradientColors ?? [AppColors.primary, AppColors.accent];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            // Filled: gradient + glow shadow
            gradient: widget.isOutlined || disabled
                ? null
                : LinearGradient(
                    colors: gradColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            // Outlined: transparent with cyan border
            border: widget.isOutlined
                ? Border.all(
                    color: disabled ? AppColors.border : AppColors.accent,
                    width: 1.5,
                  )
                : null,
            color: disabled
                ? AppColors.surface
                : widget.isOutlined
                    ? Colors.transparent
                    : null,
            boxShadow: (!widget.isOutlined && !disabled)
                ? [
                    BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: _isPressed ? 0.50 : 0.35),
                      blurRadius: _isPressed ? 20 : 16,
                      spreadRadius: _isPressed ? 0 : -4,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: _buildContent(disabled),
        ),
      ),
    );
  }

  Widget _buildContent(bool disabled) {
    if (widget.isLoading) return _loadingContent();

    final textColor = widget.isOutlined
        ? AppColors.accent
        : disabled
            ? AppColors.textDisabled
            : AppColors.textOnPrimary;

    final style = widget.labelStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 1.2,
          fontFamily: 'Rajdhani',
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 10),
        ],
        Text(widget.label, style: style),
      ],
    );
  }

  Widget _loadingContent() {
    return Center(
      child: _ShimmerDots(
        color: widget.isOutlined ? AppColors.accent : AppColors.textOnPrimary,
      ),
    );
  }
}

/// Three pulsing dots used as the loading indicator inside NeonButton.
class _ShimmerDots extends StatefulWidget {
  final Color color;
  const _ShimmerDots({required this.color});

  @override
  State<_ShimmerDots> createState() => _ShimmerDotsState();
}

class _ShimmerDotsState extends State<_ShimmerDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true, period: Duration(milliseconds: 800 + i * 200)),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.3, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Stagger the dots
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _animations[i].value),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
