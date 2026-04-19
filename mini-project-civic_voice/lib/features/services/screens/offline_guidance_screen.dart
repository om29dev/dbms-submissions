import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/offline_guidance_provider.dart';
import '../../../../widgets/glass_card.dart';

class OfflineGuidanceScreen extends StatefulWidget {
  const OfflineGuidanceScreen({super.key});

  @override
  State<OfflineGuidanceScreen> createState() => _OfflineGuidanceScreenState();
}

class _OfflineGuidanceScreenState extends State<OfflineGuidanceScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OfflineGuidanceProvider(),
      child: Consumer<OfflineGuidanceProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            appBar: AppBar(
              backgroundColor: AppColors.bgDeep,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Guides',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentBlue))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Row(
                            children: [
                              'All',
                              ...provider.guides.map((g) => g.category).toSet()
                            ].map((category) {
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(category,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(
                                          () => _selectedCategory = category);
                                    }
                                  },
                                  selectedColor: AppColors.saffron,
                                  backgroundColor: AppColors.bgMid,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide.none),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Filtered List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            itemCount: provider.guides
                                .where((g) =>
                                    _selectedCategory == 'All' ||
                                    g.category == _selectedCategory)
                                .length,
                            itemBuilder: (context, index) {
                              final filteredGuides = provider.guides
                                  .where((g) =>
                                      _selectedCategory == 'All' ||
                                      g.category == _selectedCategory)
                                  .toList();
                              final guide = filteredGuides[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.gold
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(guide.category,
                                                style: GoogleFonts.spaceMono(
                                                    color: AppColors.gold,
                                                    fontSize: 12)),
                                          ),
                                          const Icon(Icons.bookmark_added,
                                              color: AppColors.emeraldLight,
                                              size: 20),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        guide.title,
                                        style: GoogleFonts.playfairDisplay(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 24),
                                      Text('Steps to Follow',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 12),
                                      ...guide.steps
                                          .asMap()
                                          .entries
                                          .map((step) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 10,
                                                backgroundColor: AppColors
                                                    .accentBlue
                                                    .withValues(alpha: 0.2),
                                                child: Text('${step.key + 1}',
                                                    style:
                                                        GoogleFonts.spaceMono(
                                                            fontSize: 10,
                                                            color: AppColors
                                                                .accentBlue)),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Text(step.value,
                                                      style: GoogleFonts.inter(
                                                          color: AppColors
                                                              .textSecondary,
                                                          height: 1.4))),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                      const Divider(
                                          color: AppColors.surfaceBorder),
                                      const SizedBox(height: 16),
                                      Text('Required Documents',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      ...guide.requiredDocuments
                                          .map((doc) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.check,
                                                        color: AppColors
                                                            .emeraldLight,
                                                        size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(doc,
                                                        style: GoogleFonts.inter(
                                                            color: AppColors
                                                                .textSecondary)),
                                                  ],
                                                ),
                                              )),
                                      if (guide.tip.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.saffron
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: AppColors.saffron
                                                    .withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.lightbulb,
                                                  color: AppColors.saffron,
                                                  size: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  guide.tip,
                                                  style: GoogleFonts.inter(
                                                      color: AppColors.saffron,
                                                      fontSize: 13,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ]
                                    ],
                                  ),
                                ).animate().slideY(
                                    begin: 0.1,
                                    end: 0,
                                    delay: Duration(milliseconds: 100 * index)),
                              )
                                  .animate(key: ValueKey(guide.id))
                                  .fadeIn()
                                  .slideY(
                                      begin: 0.1,
                                      end: 0,
                                      delay:
                                          Duration(milliseconds: 50 * index));
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
