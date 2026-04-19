import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final String text;

  const LoadingOverlay({
    super.key,
    this.text = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeep.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Logo / Loader
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.saffron, Colors.transparent],
                  stops: [0.2, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    strokeWidth: 3,
                  ),
                  const Icon(Icons.mic_rounded, color: AppColors.bgDeep, size: 32)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1500.ms, color: Colors.white),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms),
             
            const SizedBox(height: 24),
            
            // Text
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .shimmer(duration: 2.seconds, color: AppColors.saffron),
          ],
        ),
      ),
    );
  }
}
