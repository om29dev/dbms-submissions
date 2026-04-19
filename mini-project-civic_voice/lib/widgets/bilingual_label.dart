import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/language_provider.dart';

/// Bilingual label widget — English text on top, Hindi (Devanagari) below.
/// Used throughout the app for culturally authentic, accessible labeling.
/// In English mode, only English text is shown to keep UI clean.
class BilingualLabel extends StatelessWidget {
  final String englishText;
  final String hindiText;

  /// Scale multiplier applied to default font sizes.
  final double scale;
  final TextAlign align;
  final Color? englishColor;
  final Color? hindiColor;
  final FontWeight englishWeight;

  const BilingualLabel({
    super.key,
    required this.englishText,
    required this.hindiText,
    this.scale = 1.0,
    this.align = TextAlign.start,
    this.englishColor,
    this.hindiColor,
    this.englishWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglishOnly = languageProvider.languageCode == 'en';

    return Text(
      isEnglishOnly ? englishText : hindiText,
      textAlign: align,
      style: isEnglishOnly
          ? GoogleFonts.poppins(
              fontSize: 14 * scale,
              fontWeight: englishWeight,
              color: englishColor ?? AppColors.textPrimary,
              height: 1.2,
            )
          : GoogleFonts.notoSansDevanagari(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w400,
              color: hindiColor ?? AppColors.textPrimary,
              height: 1.2,
            ),
    );
  }
}
