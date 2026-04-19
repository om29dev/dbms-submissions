import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass/glass_card.dart';

class ARGuidanceScreen extends StatefulWidget {
  final String imagePath;
  const ARGuidanceScreen({super.key, required this.imagePath});

  @override
  State<ARGuidanceScreen> createState() => _ARGuidanceScreenState();
}

class _ARGuidanceScreenState extends State<ARGuidanceScreen> {
  bool _isAnalyzing = true;
  List<Rect> _signatureZones = [];

  @override
  void initState() {
    super.initState();
    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    if (widget.imagePath.isEmpty) {
      if (mounted) setState(() => _isAnalyzing = false);
      return;
    }
    // Mocking AI analysis for signature zones
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        // Mock zone: Bottom right of an image
        _signatureZones = [
          const Rect.fromLTWH(0.6, 0.7, 0.3, 0.1), // Relative coordinates
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Smart Guidance (AR)',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          // Image
          widget.imagePath.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.document_scanner, size: 64, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'No Document Selected',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      'Could not load image',
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  ),
                ),

          // AR Overlay (Zones)
          if (!_isAnalyzing)
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _signatureZones.map((rect) {
                    return Positioned( // Calculating absolute position
                      left: rect.left * constraints.maxWidth,
                      top: rect.top * constraints.maxHeight,
                      width: rect.width * constraints.maxWidth,
                      height: rect.height * constraints.maxHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.electricBlue, width: 3),
                          color: AppTheme.electricBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: AppTheme.deepSpaceBlue,
                            child: Text(
                              'SIGN HERE',
                              style: GoogleFonts.poppins(
                                color: AppTheme.electricBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .boxShadow(
                         begin: const BoxShadow(color: Colors.transparent, blurRadius: 0),
                         end: const BoxShadow(color: AppTheme.electricBlue, blurRadius: 10, spreadRadius: 2),
                       ),
                    );
                  }).toList(),
                );
              },
            ),

          // Status Indicator
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isAnalyzing ? Icons.radar : Icons.check_circle,
                    color: _isAnalyzing ? AppTheme.warning : AppTheme.success,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _isAnalyzing 
                        ? 'Scanning document layout...' 
                        : '1 Signature Zone Detected',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_isAnalyzing)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.electricBlue),
            ),
        ],
      ),
    );
  }
}
