import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../providers/gamification_provider.dart' as game;

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<game.GamificationProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Civic Progress',
          style: GoogleFonts.poppins(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score Arc Gauge (pure Flutter)
            SizedBox(
              height: 250,
              child: CustomPaint(
                painter: _ScoreArcPainter(
                  score: gameProvider.civicScore.toDouble(),
                  maxScore: 1000,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        gameProvider.civicScore.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.electricBlue,
                        ),
                      ),
                      Text(
                        'CIVIC SCORE',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.pureWhite.withValues(alpha: 0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Level Card
            GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppTheme.warning, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Level ${gameProvider.level}: Citizen',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Badges Grid
            Text(
              'Your Badges',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: gameProvider.badges.length,
              itemBuilder: (context, index) {
                final badge = gameProvider.badges[index];
                return _buildBadgeCard(badge);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(game.Badge badge) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      gradientColors: badge.isUnlocked 
          ? [AppTheme.electricBlue.withValues(alpha: 0.1), AppTheme.electricBlue.withValues(alpha: 0.05)]
          : [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.05)],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge.icon, 
            size: 40, 
            color: badge.isUnlocked ? AppTheme.electricBlue : Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: badge.isUnlocked ? AppTheme.pureWhite : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: badge.isUnlocked ? AppTheme.pureWhite.withValues(alpha: 0.7) : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  final double score;
  final double maxScore;
  
  _ScoreArcPainter({required this.score, required this.maxScore});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.7;
    final radius = math.min(cx, cy) * 0.9;
    const startAngle = math.pi;
    const sweepFull = math.pi;

    // Background arc
    final bgPaint = Paint()
      ..color = AppTheme.glassBorder
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepFull, false, bgPaint,
    );

    // Filled arc
    final percentage = (score / maxScore).clamp(0.0, 1.0);
    final fgPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepFull,
        colors: [AppTheme.electricBlue, AppTheme.neonCyan],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepFull * percentage, false, fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) => old.score != score;
}

