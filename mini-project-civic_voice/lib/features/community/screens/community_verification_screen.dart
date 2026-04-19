import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/widgets/glass/glass_card.dart';
import 'package:civic_voice_interface/providers/community_provider.dart';
import 'package:intl/intl.dart';

import 'package:civic_voice_interface/providers/language_provider.dart';

class CommunityVerificationScreen extends StatelessWidget {
  const CommunityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final requests = communityProvider.requests;

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
          lang.translate('community_trust'),
          style: GoogleFonts.poppins(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExplanationCard(lang),
            const SizedBox(height: 32),
            Text(
              lang.translate('pending_verifications'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final req = requests[index];
                return _buildRequestCard(context, communityProvider, req);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(LanguageProvider lang) {
    return GlassCard(
      gradientColors: [AppTheme.electricBlue.withValues(alpha: 0.1), AppTheme.electricBlue.withValues(alpha: 0.05)],
      child: Column(
        children: [
          const Icon(Icons.verified_user, size: 48, color: AppTheme.electricBlue),
          const SizedBox(height: 12),
          Text(
            lang.translate('vouch_explanation').split('.')[0], // "Vouch for Neighbors" usually part of explanation or header
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang.translate('vouch_explanation'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, CommunityProvider provider, VerificationRequest req) {
    final isVerified = req.status == VerificationStatus.verified;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.2),
                child: Text(
                  req.requesterAvatar,
                  style: GoogleFonts.poppins(
                    color: AppTheme.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.requesterName,
                      style: GoogleFonts.poppins(
                        color: AppTheme.pureWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Requested ${DateFormat('MMM d').format(req.requestDate)}',
                      style: GoogleFonts.inter(
                        color: AppTheme.pureWhite.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                const Icon(Icons.check_circle, color: AppTheme.success),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Purpose:',
            style: GoogleFonts.inter(
              color: AppTheme.pureWhite.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            req.purpose,
            style: GoogleFonts.inter(
              color: AppTheme.pureWhite,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: req.currentEndorsements / req.endorsementsRequired,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.electricBlue),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${req.currentEndorsements}/${req.endorsementsRequired}',
                style: GoogleFonts.inter(
                  color: AppTheme.electricBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.endorseRequest(req.id),
                icon: const Icon(Icons.thumb_up, size: 16),
                label: Text(Provider.of<LanguageProvider>(context, listen: false).translate('vouch')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.electricBlue,
                  foregroundColor: AppTheme.deepSpaceBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
              ),
              child: Text(
                Provider.of<LanguageProvider>(context, listen: false).translate('verification_complete'),
                style: GoogleFonts.inter(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
