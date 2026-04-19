import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/containers/glass_card.dart';

class AnalyticsPanel extends StatelessWidget {
  const AnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildUsageChart(),
              const SizedBox(height: 20),
              _buildDistributionChart(),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildUsageChart(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildDistributionChart(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsageChart() {
    return GlassCard(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Usage Over Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 1),
                        const FlSpot(2, 4),
                        const FlSpot(3, 2),
                        const FlSpot(4, 5),
                        const FlSpot(5, 3),
                        const FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart() {
    return GlassCard(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: AppColors.primary, value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                    PieChartSectionData(color: AppColors.secondary, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                    PieChartSectionData(color: AppColors.accent, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
