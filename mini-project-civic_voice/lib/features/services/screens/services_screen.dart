import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/services_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../models/service_model.dart';
import '../../../widgets/decorative/tricolor_bar.dart';
import '../../../widgets/service_icon_tile.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICES SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _searchQuery = '';
  String? _activeCategory;
  final _searchCtrl = TextEditingController();

  // Categories now built dynamically per language — see _buildCategories(lang)
  List<(String label, String? code)> _buildCategories(LanguageProvider lang) =>
      [
        (lang.t('services_cat_all'), null),
        (lang.t('services_cat_identity'), 'identity'),
        (lang.t('services_cat_finance'), 'finance'),
        (lang.t('services_cat_health'), 'health'),
        (lang.t('services_cat_agriculture'), 'agriculture'),
        (lang.t('services_cat_education'), 'education'),
        (lang.t('services_cat_business'), 'business'),
      ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final allServices = context.watch<ServicesProvider>().allServices;
    final filtered = allServices.where((s) {
      final matchCat =
          _activeCategory == null || s.category.name == _activeCategory;
      final matchQ = _searchQuery.isEmpty ||
          s
              .localizedName('en')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchCat && matchQ;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgDark,
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : MediaQuery.of(context).size.width;
                    return SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TricolorBar(height: 2),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.t('services_sub_hi'),
                                  style: GoogleFonts.notoSansDevanagari(
                                    fontSize: 12,
                                    color:
                                        AppColors.gold.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  lang.t('services_title'),
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${filtered.length} ${lang.t('services_count_suffix')} · ${lang.t('services_choose')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Search bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.bgMid,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const SizedBox(width: 14),
                                  const Icon(Icons.search_rounded,
                                      color: AppColors.saffron, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      onChanged: (v) =>
                                          setState(() => _searchQuery = v),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            lang.t('services_search_hint'),
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: Icon(Icons.close_rounded,
                                            color: AppColors.textMuted,
                                            size: 18),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category pills
                          SizedBox(
                            height: 36,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _buildCategories(lang).length,
                              itemBuilder: (_, i) {
                                final (label, code) = _buildCategories(lang)[i];
                                final active = _activeCategory == code;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _activeCategory = code),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? AppColors.saffron
                                            : AppColors.bgMid,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: active
                                              ? AppColors.saffron
                                              : AppColors.surfaceBorder,
                                        ),
                                        boxShadow: active
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.saffron
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 10,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: active
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Service cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ServiceCard(service: filtered[i], index: i),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICE CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final int index;
  const _ServiceCard({required this.service, required this.index});

  Color get _color => switch (service.category) {
        ServiceCategory.identity => AppColors.accentBlue,
        ServiceCategory.health => AppColors.accentTeal,
        ServiceCategory.education => AppColors.accentPurple,
        ServiceCategory.finance => AppColors.gold,
        ServiceCategory.welfare => AppColors.emeraldLight,
        ServiceCategory.agriculture => AppColors.accentGreen,
        ServiceCategory.transport => AppColors.accentBlue,
        ServiceCategory.property => AppColors.accentPurple,
        ServiceCategory.business => AppColors.accentAmber,
        ServiceCategory.employment => AppColors.emeraldLight,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          context.read<AnalyticsProvider>().recordServiceView(service.id);
          context.push(
            Routes.serviceDetailPath(service.id),
            extra: service,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder, width: 1),
          ),
          child: Stack(
            children: [
              // Top accent
              Container(
                height: 1,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [_color.withValues(alpha: 0.5), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon tile
                    ServiceIconTile(
                      emoji: service.iconEmoji,
                      color: _color,
                      size: 56,
                      iconSize: 28,
                    ),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<LanguageProvider>().languageCode ==
                                    'hi'
                                ? service.localizedName('hi')
                                : service.localizedName('en'),
                            style: context
                                        .watch<LanguageProvider>()
                                        .languageCode ==
                                    'hi'
                                ? GoogleFonts.notoSansDevanagari(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  )
                                : GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Builder(builder: (ctx) {
                                  final lang = ctx.read<LanguageProvider>();
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (service.isPopular)
                                        _tag(lang.t('services_popular'),
                                            AppColors.saffron),
                                      if (service.fees == '0' ||
                                          service.fees.toLowerCase() ==
                                              'free') ...[
                                        const SizedBox(width: 6),
                                        _tag(lang.t('services_free'),
                                            AppColors.emeraldLight),
                                      ],
                                      const SizedBox(width: 6),
                                      _tag(lang.t('services_online'),
                                          AppColors.accentBlue),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          if (service.estimatedTimeline.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Est. ${service.estimatedTimeline} · Fee: ${service.fees}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.textMuted, size: 14),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + index * 50))
            .slideY(
                begin: 0.06,
                end: 0,
                delay: Duration(milliseconds: 100 + index * 50)),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}
