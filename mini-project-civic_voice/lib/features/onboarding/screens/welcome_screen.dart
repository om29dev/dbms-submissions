import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: _GlowBlob(color: AppColors.primary.withValues(alpha: 0.15), size: 400),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Logo
                FadeInDown(
                  child: Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 30,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        size: 80,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                FadeInUp(
                  child: Text(
                    'CIVIC VOICE\nINTERFACE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Subtitle
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'PRECISION GOVERNMENT NAVIGATION',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Action Area
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/auth'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('INITIALIZE LINK'),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'VERSION 1.0.4 - SECURE CHANNEL',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppColors.white.withValues(alpha: 0.2),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
