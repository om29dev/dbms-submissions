import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/service_model.dart';
import '../../../../widgets/glass_card.dart';

class EligibilityCheckerScreen extends StatefulWidget {
  final ServiceModel service;

  const EligibilityCheckerScreen({super.key, required this.service});

  @override
  State<EligibilityCheckerScreen> createState() => _EligibilityCheckerScreenState();
}

class _EligibilityCheckerScreenState extends State<EligibilityCheckerScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form State
  int? _age;
  String? _state;
  String? _income;
  String? _category;
  final List<String> _documents = [];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showResult();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showResult() {
    setState(() {
      _currentStep = _totalSteps; // Move to result state
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == _totalSteps) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Eligibility Check',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.saffron,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: AppColors.bgMid,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
                  minHeight: 8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step ${_currentStep + 1} of $_totalSteps', 
                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                  Text(widget.service.localizedName('en'), 
                      style: GoogleFonts.poppins(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Questions PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildAgeStep(),
                  _buildStateStep(),
                  _buildIncomeStep(),
                  _buildCategoryStep(),
                  _buildDocumentsStep(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _prevStep,
                      child: Text('Back', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 16)),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffron,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Check Eligibility' : 'Next',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ─── Steps ─────────────────────────────────────────────────────────────

  Widget _buildAgeStep() {
    return _StepContent(
      title: 'What is your age?',
      subtitle: 'Some services have age restrictions.',
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 24),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter age e.g. 25',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
          onChanged: (val) => _age = int.tryParse(val),
        ),
      ),
    );
  }

  Widget _buildStateStep() {
    final states = ['Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu', 'Other'];
    return _StepContent(
      title: 'Which state do you reside in?',
      subtitle: 'Schemes vary by state.',
      child: Column(
        children: states.map((s) => _ChoiceTile(
          title: s,
          isSelected: _state == s,
          onTap: () => setState(() => _state = s),
        )).toList(),
      ),
    );
  }

  Widget _buildIncomeStep() {
    final brackets = ['Below ₹2.5L', '₹2.5L - ₹5L', '₹5L - ₹10L', 'Above ₹10L'];
    return _StepContent(
      title: 'Annual Family Income?',
      subtitle: 'Required for financial aid and subsidies.',
      child: Column(
        children: brackets.map((b) => _ChoiceTile(
          title: b,
          isSelected: _income == b,
          onTap: () => setState(() => _income = b),
        )).toList(),
      ),
    );
  }

  Widget _buildCategoryStep() {
    final categories = ['General', 'OBC', 'SC', 'ST'];
    return _StepContent(
      title: 'Select your Category',
      subtitle: 'Reservation benefits apply to specific categories.',
      child: Column(
        children: categories.map((c) => _ChoiceTile(
          title: c,
          isSelected: _category == c,
          onTap: () => setState(() => _category = c),
        )).toList(),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    final docs = ['Aadhaar Card', 'PAN Card', 'Income Certificate', 'Caste Certificate'];
    return _StepContent(
      title: 'Which documents do you have?',
      subtitle: 'Select all that apply.',
      child: Column(
        children: docs.map((d) {
          final isSelected = _documents.contains(d);
          return _ChoiceTile(
            title: d,
            isSelected: isSelected,
            isMulti: true,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _documents.remove(d);
                } else {
                  _documents.add(d);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // ─── Results ──────────────────────────────────────────────────────────

  Widget _buildResultScreen() {
    // Mock logic: 80% chance of eligibility for demo
    bool isEligible = (_age ?? 0) > 18; 

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEligible ? AppColors.emeraldLight.withValues(alpha: 0.1) : AppColors.semanticError.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isEligible ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isEligible ? AppColors.emeraldLight : AppColors.semanticError,
                  size: 64,
                ),
              ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
              const SizedBox(height: 24),
              Text(
                isEligible ? 'You are Eligible!' : 'Not Eligible',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isEligible ? AppColors.emeraldLight : AppColors.semanticError,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Text(
                isEligible 
                  ? 'Based on the details provided, you meet all criteria to apply for ${widget.service.localizedName('en')}.'
                  : 'Unfortunately, your profile does not meet the age or income requirements for this scheme.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              
              if (isEligible)
                ElevatedButton(
                  onPressed: () {
                    // Navigate to actual application or tracking
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application process starting...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Start Application', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                ).animate().fadeIn(delay: 600.ms)
              else
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.saffron),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Explore Alternatives', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.saffron)),
                ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepContent({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          child,
        ],
      ).animate().fadeIn().slideX(begin: 0.1, end: 0, duration: 300.ms),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMulti;

  const _ChoiceTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isMulti = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.1) : AppColors.bgMid.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isMulti
                 ? (isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
                 : (isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded),
              color: isSelected ? AppColors.accentBlue : AppColors.textMuted,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
