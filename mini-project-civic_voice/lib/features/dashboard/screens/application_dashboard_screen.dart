import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/application_tracker_provider.dart';
import '../../../../widgets/glass_card.dart';

class ApplicationDashboardScreen extends StatelessWidget {
  const ApplicationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApplicationTrackerProvider(),
      child: Consumer<ApplicationTrackerProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            appBar: AppBar(
              backgroundColor: AppColors.bgDeep,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                'Status Tracker',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: provider.refreshData,
                )
              ],
            ),
            body: SafeArea(
              child: provider.isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.saffron))
                  : RefreshIndicator(
                      onRefresh: () async => provider.refreshData(),
                      color: AppColors.saffron,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildSummaryMetrics(provider),
                          const SizedBox(height: 32),
                          Text('Recent Applications',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ...provider.applications.map((app) {
                            return _buildStatusCard(app);
                          }),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryMetrics(ApplicationTrackerProvider provider) {
    int total = provider.applications.length;
    int pending = provider.applications
        .where((a) => a.status == 'Pending' || a.status == 'In Progress')
        .length;
    int done =
        provider.applications.where((a) => a.status == 'Completed').length;

    return Row(
      children: [
        Expanded(
            child:
                _metricCard('Total', total.toString(), AppColors.accentBlue)),
        const SizedBox(width: 16),
        Expanded(
            child:
                _metricCard('Pending', pending.toString(), AppColors.saffron)),
        const SizedBox(width: 16),
        Expanded(
            child:
                _metricCard('Done', done.toString(), AppColors.emeraldLight)),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _metricCard(String label, String count, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(count,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(dynamic app) {
    Color statusColor;
    IconData statusIcon;

    switch (app.status) {
      case 'Completed':
        statusColor = AppColors.emeraldLight;
        statusIcon = Icons.check_circle;
        break;
      case 'In Progress':
        statusColor = AppColors.saffron;
        statusIcon = Icons.hourglass_top;
        break;
      case 'Rejected':
        statusColor = AppColors.semanticError;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.accentBlue;
        statusIcon = Icons.access_time_filled;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ID: ${app.id}',
                    style: GoogleFonts.spaceMono(
                        color: AppColors.textMuted, fontSize: 13)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(app.status,
                          style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(app.schemeName,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(app.department,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            const Divider(color: AppColors.surfaceBorder),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Submitted',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textMuted)),
                    Text(DateFormat('dd MMM, yyyy').format(app.submittedDate),
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.white)),
                  ],
                ),
                if (app.estimatedCompletion != null &&
                    app.status != 'Completed')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Est. Completion',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMuted)),
                      Text(
                          DateFormat('dd MMM, yyyy')
                              .format(app.estimatedCompletion!),
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.saffron)),
                    ],
                  ),
              ],
            )
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
