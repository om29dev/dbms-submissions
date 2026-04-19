import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/achievement_provider.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const AchievementBadge({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return FadeInScale(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? AppColors.white
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: achievement.isUnlocked
                ? AppColors.accent
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: achievement.isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              achievement.icon,
              size: 40,
              color: achievement.isUnlocked
                  ? AppColors.accent
                  : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: achievement.isUnlocked
                    ? AppColors.primary
                    : Colors.grey,
              ),
            ),
            if (achievement.isUnlocked)
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }
}

class FadeInScale extends StatefulWidget {
  final Widget child;
  const FadeInScale({super.key, required this.child});

  @override
  State<FadeInScale> createState() => _FadeInScaleState();
}

class _FadeInScaleState extends State<FadeInScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // ✅ FIXED (Flutter 3.27+)
      ),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
