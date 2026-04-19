import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class OfficeFinderScreen extends StatelessWidget {
  const OfficeFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Office Finder')),
      body: Stack(
        children: [
          // Simulated Map
          Container(
            color: AppColors.background,
            child: const Center(
              child: Opacity(
                opacity: 0.3,
                child: Icon(Icons.map, size: 400, color: AppColors.primary),
              ),
            ),
          ),
          // Pins
          _buildMapPin(200, 100, 'Main Seva Kendra'),
          _buildMapPin(350, 250, 'Zonal Office'),
          _buildMapPin(150, 400, 'Citizen Help Desk'),

          Align(
            alignment: Alignment.bottomCenter,
            child: FadeInUp(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Nearest: Main Seva Kendra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('1.2 km away • Open until 5:00 PM'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Open Google Maps directions to Main Seva Kendra
                        final uri = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=Main+Seva+Kendra&travelmode=driving',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('GET DIRECTIONS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(double top, double left, String name) {
    return Positioned(
      top: top,
      left: left,
      child: FadeInDown(
        duration: const Duration(seconds: 1),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
            const Icon(Icons.location_pin, color: AppColors.primary, size: 40),
          ],
        ),
      ),
    );
  }
}
