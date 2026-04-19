import 'package:flutter/material.dart';
import 'package:countup/countup.dart';
import '../containers/glass_card.dart';
import '../../core/constants/app_colors.dart';

class QuickStatsCard extends StatelessWidget {
  final String title;
  final double value;
  final String suffix;
  final IconData icon;
  final Color iconColor;
  final bool showProgress;
  final double progress;
  final double? width;
  final double? height;

  const QuickStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.suffix = "",
    required this.icon,
    this.iconColor = AppColors.accent,
    this.showProgress = false,
    this.progress = 0.0,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (showProgress)
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      color: iconColor,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Countup(
                        begin: 0,
                        end: value,
                        duration: const Duration(seconds: 2),
                        separator: ',',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (suffix.isNotEmpty)
                      Text(
                        suffix,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textBody.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
