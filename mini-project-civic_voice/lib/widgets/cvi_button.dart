import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

enum CviButtonVariant { primary, secondary, gold }

/// The primary CTA button for the Bharat Silicon design language.
/// Three variants: primary (saffron), secondary (ghost), gold (premium).
class CviButton extends StatefulWidget {
  final String text;
  final CviButtonVariant variant;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final IconData? icon;
  final bool loading;

  const CviButton({
    super.key,
    required this.text,
    this.variant = CviButtonVariant.primary,
    this.onPressed,
    this.width,
    this.height = 54,
    this.icon,
    this.loading = false,
  });

  @override
  State<CviButton> createState() => _CviButtonState();
}

class _CviButtonState extends State<CviButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _textColor,
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: _textColor),
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        onTap: widget.loading ? null : widget.onPressed,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: _boxDecoration,
            child: buttonContent,
          ),
        ),
      ),
    );
  }

  BoxDecoration get _boxDecoration {
    switch (widget.variant) {
      case CviButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.saffron, AppColors.saffronDeep],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.3),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        );

      case CviButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.saffron.withValues(alpha: 0.4),
            width: 1.5,
          ),
        );

      case CviButtonVariant.gold:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gold, AppColors.goldLight],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case CviButtonVariant.primary:
        return Colors.white;
      case CviButtonVariant.secondary:
        return AppColors.saffron;
      case CviButtonVariant.gold:
        return AppColors.bgDeep;
    }
  }
}

/// Legacy NeonButton — mapped to CviButton primary for backward compatibility.
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final double? width;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 54,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CviButton(
      text: label,
      variant: CviButtonVariant.primary,
      onPressed: onTap,
      height: height,
      width: width,
    );
  }
}
