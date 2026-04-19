import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class EligibilityChecker extends StatefulWidget {
  const EligibilityChecker({super.key});

  @override
  State<EligibilityChecker> createState() => _EligibilityCheckerState();
}

class _EligibilityCheckerState extends State<EligibilityChecker> {
  double _score = 0.0;
  bool _calculating = false;

  void _runCheck() {
    setState(() {
      _calculating = true;
      _score = 0.0;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _calculating = false;
        _score = 0.92;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Eligibility Score',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: _score,
                  strokeWidth: 12,
                  backgroundColor: AppColors.background,
                  color: _score > 0.8 ? AppColors.accent : AppColors.warning,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(_score * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _score > 0.8 ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  const Text('Confidence', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (!_calculating && _score == 0)
            ElevatedButton(
              onPressed: _runCheck,
              child: const Text('RUN ELIGIBILITY CHECK'),
            )
          else if (_calculating)
            const Text('Processing your data...')
          else
            FadeInUp(
              child: const Column(
                children: [
                  Text(
                    '🎉 You are likely eligible!',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your voice profile matches 9/10 criteria for the Ration Card scheme.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
