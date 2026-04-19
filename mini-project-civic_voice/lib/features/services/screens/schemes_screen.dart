import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/scheme_knowledge_base.dart';
import '../../../models/scheme_model.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/language_provider.dart';
import 'scheme_detail_screen.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final categorySchemes = SchemeKnowledgeBase.getSchemesByCategories();
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          lang.translate('government_schemes'),
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          if (!user.isProfileComplete)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lang.translate('unlock_eligibility_msg'),
                        style: GoogleFonts.inter(
                            color: AppColors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: categorySchemes.length,
              itemBuilder: (context, index) {
                final category = categorySchemes.keys.elementAt(index);
                final schemes = categorySchemes[category]!;
                if (schemes.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15, top: 20),
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category),
                              color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            lang.translate(category),
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Schemes in this category
                    ...schemes.map((scheme) =>
                        _buildSchemeCard(context, scheme, user, lang)),

                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, GovernmentScheme scheme,
      UserProfile user, LanguageProvider lang) {
    final isEligible = user.isProfileComplete && scheme.isEligible(user);
    final languageCode = lang.languageCode;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchemeDetailScreen(scheme: scheme),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEligible
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.white.withValues(alpha: 0.1),
            width: isEligible ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Scheme Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isEligible ? AppColors.primary : AppColors.primary)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getSchemeIcon(scheme.category),
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Scheme Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scheme.names[languageCode] ?? scheme.names['en']!,
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isEligible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lang.translate('eligible'),
                            style: GoogleFonts.inter(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheme.description,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white.withValues(alpha: 0.3),
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'senior_citizens':
        return Icons.elderly;
      case 'students':
        return Icons.school;
      case 'farmers':
        return Icons.agriculture;
      case 'health':
        return Icons.health_and_safety;
      case 'food_security':
        return Icons.restaurant;
      default:
        return Icons.account_balance;
    }
  }

  IconData _getSchemeIcon(String category) {
    switch (category) {
      case 'senior_citizens':
        return Icons.account_balance_wallet;
      case 'students':
        return Icons.menu_book;
      case 'farmers':
        return Icons.grass;
      case 'health':
        return Icons.local_hospital;
      case 'food_security':
        return Icons.food_bank;
      default:
        return Icons.description;
    }
  }
}
