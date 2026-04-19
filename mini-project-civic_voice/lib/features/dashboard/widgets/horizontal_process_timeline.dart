import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/containers/glass_card.dart';
import '../../../models/service_model.dart';

class HorizontalProcessTimeline extends StatelessWidget {
  final List<ProcessStep> steps;
  final int currentStep;

  const HorizontalProcessTimeline({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: steps.asMap().entries.map((entry) {
            int idx = entry.key;
            ProcessStep step = entry.value;
            bool isCompleted = idx < currentStep;
            bool isCurrent = idx == currentStep;
            bool isLast = idx == steps.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                        border: isCurrent ? Border.all(color: AppColors.accent, width: 2) : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppColors.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: isCompleted ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
