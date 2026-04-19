import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';
import 'package:civic_voice_interface/widgets/glass/glass_card.dart';
import 'package:civic_voice_interface/core/services/emergency_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final service = EmergencyService();
    try {
      final position = await service.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false; // Ensure loading state is updated
        });
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        setState(() {
          _isLoadingLocation =
              false; // Ensure loading state is updated even on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505), // Dark red tint
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.translate('emergency_mode'),
          style: GoogleFonts.poppins(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            onPressed: () {
              setState(() => _isLoadingLocation = true);
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // SOS Button
            GestureDetector(
              onTap: _emergencyService.callEmergencyNumber,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.red, Color(0xFF8B0000)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sos, size: 64, color: Colors.white),
                      Text(
                        lang.translate('tap_for_112'),
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white24),

            const SizedBox(height: 32),

            // Location Card
            GlassCard(
              gradientColors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.red.withValues(alpha: 0.05)
              ],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.my_location, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text(
                        lang.translate('your_coordinates'),
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingLocation)
                    const CircularProgressIndicator(color: Colors.redAccent)
                  else if (_currentPosition != null)
                    Column(
                      children: [
                        Text(
                          'LAT: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: GoogleFonts.robotoMono(
                            color: AppTheme.pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'LNG: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: GoogleFonts.robotoMono(
                            color: AppTheme.pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share these with rescue teams', // Could translate
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      lang.translate('location_unavailable'),
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Disaster Guides
            Text(
              lang.translate('offline_guides'),
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
              itemCount: _emergencyService.guides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final guide = _emergencyService.guides[index];
                return ExpansionTile(
                  collapsedBackgroundColor: AppTheme.glassBackground,
                  backgroundColor: AppTheme.glassBackground,
                  iconColor: guide.color,
                  collapsedIconColor: guide.color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.info),
                  title: Text(
                    guide.title,
                    style: GoogleFonts.poppins(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepSection(
                              'DO:', guide.doSteps, Colors.greenAccent),
                          const SizedBox(height: 16),
                          _buildStepSection(
                              'DON\'T:', guide.dontSteps, Colors.redAccent),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepSection(String title, List<String> steps, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.7))),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.inter(
                        color: AppTheme.pureWhite.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
