import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../models/scheme_model.dart';
import '../../../providers/citizen_profile_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/t_text.dart';
import '../../../core/services/csv_scheme_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();

  bool _isMatching = false;
  bool _showResults = false;
  List<GovernmentScheme> _matchedSchemes = [];
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Health',
    'Education',
    'Agriculture',
    'Finance',
    'Housing',
    'Welfare',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill from profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CitizenProfileProvider>();
      if (provider.profile != null) {
        _ageController.text = provider.profile!.age.toString();
        _incomeController.text = provider.profile!.income.toString();
      } else {
        provider.fetchProfile().then((_) {
          if (mounted && provider.profile != null) {
            setState(() {
              _ageController.text = provider.profile!.age.toString();
              _incomeController.text = provider.profile!.income.toString();
            });
          }
        });
      }
    });
  }

  void _findMatches() async {
    setState(() {
      _isMatching = true;
      _showResults = false;
    });

    // Ensure CSV is initialized
    await CsvSchemeService.init();

    // Simulate AI Processing time for UX
    await Future.delayed(1500.ms);

    final age = int.tryParse(_ageController.text) ?? 30;
    final income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;

    setState(() {
      _matchedSchemes = CsvSchemeService.findMatches(age, income);
      _isMatching = false;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AppColors.saffron.withValues(alpha: 0.05),
              AppColors.bgDeep,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: 500.ms,
            child: _isMatching
                ? _buildMatchingView()
                : (_showResults ? _buildResultsView() : _buildFormView()),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Scheme Discovery',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Enter your details to find exclusive benefits and government schemes tailored for you.',
            style:
                GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 40),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInputField(
                  label: 'Current Age',
                  controller: _ageController,
                  icon: Icons.calendar_today,
                  hint: 'e.g. 25',
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Annual Income (₹)',
                  controller: _incomeController,
                  icon: Icons.currency_rupee,
                  hint: 'e.g. 500000',
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffron,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.saffron.withValues(alpha: 0.5),
                    ),
                    onPressed: _findMatches,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Discover Schemes',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 3.seconds),
              ],
            ),
          ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          _buildInfoNote(),
        ],
      ),
    );
  }

  Widget _buildMatchingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.saffron, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.search, size: 64, color: AppColors.saffron),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1.seconds,
                  curve: Curves.easeInOut)
              .blur(begin: const Offset(0, 0), end: const Offset(10, 10))
              .fadeOut(delay: 800.ms),
          const SizedBox(height: 40),
          Text(
            'Analyzing Bharat Database...',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          const SizedBox(height: 12),
          Text(
            'Matching eligibility criteria with 500+ schemes',
            style:
                GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.bgDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => setState(() => _showResults = false),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Matched for You',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.gold, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Results: Age ${_ageController.text}, Income ₹${_incomeController.text}',
                        style: GoogleFonts.poppins(
                            color: AppColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _showResults = false),
                      child: Text('Refine Params',
                          style: GoogleFonts.poppins(
                              color: AppColors.saffron,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.bgMid,
                      icon: const Icon(Icons.filter_list,
                          color: AppColors.saffron),
                      isExpanded: true,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 14),
                      items: _categories.map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_matchedSchemes.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sentiment_dissatisfied,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No direct matches found.',
                    style: GoogleFonts.poppins(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showResults = false),
                    child: const Text('Try broader criteria'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          (() {
            final filtered = _matchedSchemes.where((s) {
              if (_selectedCategory == 'All') return true;
              final cat = s.category.toLowerCase();
              final filter = _selectedCategory.toLowerCase();
              if (filter == 'housing') {
                return cat.contains('home') ||
                    cat.contains('housing') ||
                    cat.contains('aswas');
              }
              if (filter == 'education') {
                return cat.contains('students') ||
                    cat.contains('education') ||
                    cat.contains('shiksha');
              }
              return cat.contains(filter);
            }).toList();

            if (filtered.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No schemes found for "$_selectedCategory"',
                    style: GoogleFonts.poppins(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RecommendationCard(
                      scheme: filtered[index], index: index),
                  childCount: filtered.length,
                ),
              ),
            );
          })(),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.saffron, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your privacy matters. CVI does not share this search data with third parties. It is only used to query the Bharat Scheme Knowledge Base.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _RecommendationCard extends StatelessWidget {
  final GovernmentScheme scheme;
  final int index;

  const _RecommendationCard({required this.scheme, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: InkWell(
        onTap: () => context.push(Routes.serviceDetailPath(scheme.id),
            extra: scheme.toServiceModel()),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.saffron.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      scheme.category.replaceAll('_', ' ').toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.saffron,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.verified,
                      color: AppColors.emerald, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              TText(
                scheme.names['en'] ?? 'Scheme Title',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scheme.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.gold, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Exclusive Match',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.saffron,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.1, end: 0);
  }
}
