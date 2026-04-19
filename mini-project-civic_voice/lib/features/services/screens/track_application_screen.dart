import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/models/application_model.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';
import 'package:civic_voice_interface/widgets/glass/glass_card.dart';

class TrackApplicationScreen extends StatelessWidget {
  final UserApplication application;

  const TrackApplicationScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(lang.translate('track_application')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(theme, lang),
            const SizedBox(height: 32),
            _buildApplicationDetails(theme, lang),
            const SizedBox(height: 32),
            _buildTimeline(theme, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ThemeData theme, LanguageProvider lang) {
    final statusColor = _getStatusColor(application.status);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(application.status),
            color: statusColor,
            size: 40,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.schemeName,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang.translate(application.status.name).toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: statusColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationDetails(ThemeData theme, LanguageProvider lang) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailRow(lang.translate('application_id'), application.id, theme),
          const Divider(height: 32),
          _buildDetailRow(lang.translate('submitted_on'), DateFormat('MMM dd, yyyy').format(application.submissionDate), theme),
          if (application.currentStep != null) ...[
            const Divider(height: 32),
            _buildDetailRow(lang.translate('current_step'), application.currentStep!, theme),
          ],
          if (application.nextStep != null) ...[
            const Divider(height: 32),
            _buildDetailRow(lang.translate('next_step'), application.nextStep!, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(ThemeData theme, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.translate('status_timeline'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: application.timeline.length,
          itemBuilder: (context, index) {
            final event = application.timeline[index];
            final isLast = index == application.timeline.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: event.isCompleted ? AppTheme.success : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 50,
                        color: event.isCompleted ? AppTheme.success : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: event.isCompleted ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(event.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved: return AppTheme.success;
      case ApplicationStatus.rejected: return AppTheme.error;
      case ApplicationStatus.submitted: return AppTheme.warning;
      case ApplicationStatus.verified: return AppTheme.electricBlue;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved: return Icons.check_circle_rounded;
      case ApplicationStatus.rejected: return Icons.cancel_rounded;
      case ApplicationStatus.submitted: return Icons.send_rounded;
      case ApplicationStatus.verified: return Icons.verified_user_rounded;
    }
  }
}
