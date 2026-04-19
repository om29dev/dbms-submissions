import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/scheme_discovery_provider.dart';
import '../../../../providers/voice_provider.dart';
import '../../../../widgets/glass_card.dart';

class SchemeDiscoveryScreen extends StatefulWidget {
  const SchemeDiscoveryScreen({super.key});

  @override
  State<SchemeDiscoveryScreen> createState() => _SchemeDiscoveryScreenState();
}

class _SchemeDiscoveryScreenState extends State<SchemeDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(SchemeDiscoveryProvider provider, String val) {
    provider.searchSchemes(val);
  }

  void _voiceSearch(SchemeDiscoveryProvider provider) {
    final voice = context.read<VoiceProvider>();

    if (voice.isListening) {
      voice.stopListening();
      return;
    }

    voice.startListening(
      onFinalResult: (text) {
        if (text.isNotEmpty) {
          _searchController.text = text;
          provider.searchSchemes(text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Searching for: "$text"'),
              backgroundColor: AppColors.gold,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SchemeDiscoveryProvider(),
      child: Consumer<SchemeDiscoveryProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            appBar: AppBar(
              backgroundColor: AppColors.bgDeep,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                'Scheme Discovery',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.saffron,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgMid,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Search schemes by keyword...',
                                hintStyle:
                                    TextStyle(color: AppColors.textMuted),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search,
                                    color: AppColors.accentBlue),
                              ),
                              onChanged: (v) => _onSearch(provider, v),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _voiceSearch(provider),
                          child: Consumer<VoiceProvider>(
                            builder: (context, voice, _) {
                              final isListening = voice.isListening;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isListening
                                      ? AppColors.gold.withValues(alpha: 0.3)
                                      : AppColors.gold.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isListening
                                        ? Colors.white
                                        : AppColors.gold,
                                    width: isListening ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  isListening ? Icons.mic : Icons.mic_none,
                                  color: isListening
                                      ? Colors.white
                                      : AppColors.gold,
                                ),
                              ).animate(target: isListening ? 1 : 0).shimmer(
                                    duration: 1000.ms,
                                    color: Colors.white24,
                                  );
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  // Filters
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final cat = provider.categories[index];
                        final isSelected =
                            provider.currentCategoryFilter == cat;
                        return GestureDetector(
                          onTap: () => provider.filterByCategory(cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.saffron
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.saffron
                                    : AppColors.surfaceBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // List
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accentBlue))
                        : provider.filteredSchemes.isEmpty
                            ? Center(
                                child: Text('No schemes found.',
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textMuted)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(24),
                                itemCount: provider.filteredSchemes.length,
                                itemBuilder: (context, index) {
                                  final scheme =
                                      provider.filteredSchemes[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.accentBlue
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(scheme.category,
                                                    style:
                                                        GoogleFonts.spaceMono(
                                                            color: AppColors
                                                                .accentBlue,
                                                            fontSize: 12)),
                                              ),
                                              const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: AppColors.textMuted)
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            scheme.title,
                                            style: GoogleFonts.playfairDisplay(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            scheme.description,
                                            style: GoogleFonts.inter(
                                                color: AppColors.textSecondary,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(
                                              color: AppColors.surfaceBorder),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.check_circle_outline,
                                                  color: AppColors.emerald,
                                                  size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Eligibility: ${scheme.eligibilityCriteria.join(', ')}',
                                                  style: GoogleFonts.inter(
                                                      color:
                                                          AppColors.textMuted,
                                                      fontSize: 12),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ).animate().slideX(
                                        begin: 0.1,
                                        end: 0,
                                        delay: Duration(
                                            milliseconds: 100 * (index % 5))),
                                  );
                                },
                              ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
