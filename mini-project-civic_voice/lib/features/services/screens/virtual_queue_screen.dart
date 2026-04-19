import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../core/services/queue_service.dart';
import '../../../models/queue_token_model.dart';
import 'package:intl/intl.dart';

import '../../../providers/language_provider.dart';

class VirtualQueueScreen extends StatefulWidget {
  const VirtualQueueScreen({super.key});

  @override
  State<VirtualQueueScreen> createState() => _VirtualQueueScreenState();
}

class _VirtualQueueScreenState extends State<VirtualQueueScreen> {
  final QueueService _queueService = QueueService();
  QueueToken? _activeToken;

  @override
  void initState() {
    super.initState();
    _activeToken = _queueService.getActiveToken();
  }

  void _bookToken() {
    setState(() {
      _activeToken = _queueService.generateToken("Aadhaar Update", "MeeSeva Center, Hyderabad");
    });
  }

  void _cancelToken() {
    setState(() {
      _queueService.cancelToken();
      _activeToken = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
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
          lang.translate('smart_queue'),
          style: GoogleFonts.poppins(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_activeToken == null) _buildBookingView(lang) else _buildTokenView(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingView(LanguageProvider lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(Icons.confirmation_number_outlined, size: 80, color: AppTheme.electricBlue.withValues(alpha: 0.5)),
        const SizedBox(height: 24),
        Text(
          lang.translate('skip_the_line'),
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.pureWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Book a virtual token and arrive only when your turn is near.', // Maybe translate this later if key exists
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.pureWhite.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _bookToken,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.electricBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              lang.translate('get_token'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepSpaceBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenView(LanguageProvider lang) {
    final token = _activeToken!;
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
             children: [
               Text(
                 lang.translate('your_token'),
                 style: GoogleFonts.inter(
                   color: AppTheme.pureWhite.withValues(alpha: 0.6),
                   letterSpacing: 2,
                   fontWeight: FontWeight.w600,
                 ),
               ),
               const SizedBox(height: 16),
               Text(
                 '#${token.tokenNumber}',
                 style: GoogleFonts.poppins(
                   fontSize: 64,
                   fontWeight: FontWeight.bold,
                   color: AppTheme.electricBlue,
                 ),
               ),
               const SizedBox(height: 24),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   _buildInfoItem(lang.translate('serving'), '#${token.currentServing}'),
                   _buildInfoItem(lang.translate('wait_time'), '${token.waitTimeMinutes} min'),
                 ],
               ),
               const SizedBox(height: 24),
               const Divider(color: Colors.white24),
               const SizedBox(height: 16),
               _buildDetailRow(Icons.business, token.officeName),
               const SizedBox(height: 12),
               _buildDetailRow(Icons.category, token.serviceName),
               const SizedBox(height: 12),
               _buildDetailRow(Icons.schedule, 'Est. Time: ${DateFormat('h:mm a').format(token.estimatedTime)}'),
             ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _cancelToken,
            icon: const Icon(Icons.cancel, color: AppTheme.error),
            label: Text(
              lang.translate('cancel_token'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.error, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.pureWhite.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.neonCyan, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            color: AppTheme.pureWhite,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
