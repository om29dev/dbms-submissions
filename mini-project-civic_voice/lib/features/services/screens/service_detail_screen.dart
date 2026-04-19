import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/service_model.dart';
import '../../../providers/voice_provider.dart';
import '../../eligibility/widgets/civic_confidence_gauge.dart';

class ServiceDetailScreen extends StatefulWidget {
  final GovernmentService service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late ScrollController _scrollController;
  double _parallaxOffset = 0.0;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _parallaxOffset = _scrollController.offset * 0.5;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _readServiceDetails() {
    setState(() => _isReading = !_isReading);
    
    if (_isReading) {
      final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
      
      // Build comprehensive service information
      String content = "Service: ${widget.service.title}. ";
      content += "Description: ${widget.service.description}. ";
      content += "Required documents: ${widget.service.documents.join(', ')}. ";
      content += "Process steps: ";
      for (var step in widget.service.steps) {
        content += "${step.title}. ${step.instruction ?? ''}. ";
      }
      
      voiceProvider.speak(content);
    } else {
      final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
      voiceProvider.stopSilently();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Parallax Hero Header
          _buildParallaxHeader(),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Eligibility Meter
                  const Text('PRECISION SCORE', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  FadeInUp(child: const CivicConfidenceGauge(score: 85)),
                  
                  const SizedBox(height: 40),
                  
                  // 3. Document 3D Carousel
                  _buildSectionLabel('REQUIRED ASSETS'),
                  const SizedBox(height: 20),
                  _buildDocumentCarousel(),
                  
                  const SizedBox(height: 40),
                  
                  // 4. Animated Journey Timeline
                  _buildSectionLabel('NAVIGATION PATH'),
                  const SizedBox(height: 20),
                  _buildJourneyTimeline(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      actions: [
        // Voice Reading Button
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            onPressed: _readServiceDetails,
            icon: Icon(
              _isReading ? Icons.stop_circle : Icons.volume_up,
              color: _isReading ? AppColors.error : AppColors.primary,
              size: 28,
            ),
            tooltip: _isReading ? 'Stop Reading' : 'Read Service Details',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              top: -_parallaxOffset,
              left: 0,
              right: 0,
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [widget.service.color.withValues(alpha: 0.4), AppColors.background],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: widget.service.id,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: widget.service.color.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Icon(widget.service.icon, size: 60, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.service.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildDocumentCarousel() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.service.documents.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 20),
            child: _Premium3DDocCard(title: widget.service.documents[index]),
          ).animate(delay: (index * 200).ms).fadeIn().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
        },
      ),
    );
  }

  Widget _buildJourneyTimeline() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: widget.service.steps.map((step) {
          bool isCompleted = step.order < 2; // Simulated
          bool isCurrent = step.order == 2;
          return Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.success : (isCurrent ? AppColors.primary : AppColors.white.withValues(alpha: 0.1)),
                        border: isCurrent ? Border.all(color: AppColors.white, width: 2) : null,
                        boxShadow: isCurrent ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)] : null,
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 14, color: AppColors.background) : null,
                    ),
                    if (step.order != widget.service.steps.length)
                      Container(width: 2, height: 40, color: AppColors.white.withValues(alpha: 0.1)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.poppins(
                          color: isCurrent ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        step.instruction ?? 'Verify details and submit.',
                        style: TextStyle(color: AppColors.white.withValues(alpha: 0.3), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Premium3DDocCard extends StatelessWidget {
  final String title;
  const _Premium3DDocCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.file_copy_rounded, color: AppColors.primary, size: 40),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'REQUIRED',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.primary.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
