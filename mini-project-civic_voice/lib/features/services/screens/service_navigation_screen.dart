import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/service_model.dart';
import '../../../widgets/cards/service_card.dart';

class ServiceNavigationScreen extends StatelessWidget {
  const ServiceNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Government Services'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInLeft(
              child: const Text(
                'Explore Programs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Find and apply for government initiatives matching your voice profile.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textBody.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ...appServices.map((service) => ServiceCard(
                  service: service,
                  onTap: () {
                    // Navigate to details
                  },
                )),
          ],
        ),
      ),
    );
  }
}
