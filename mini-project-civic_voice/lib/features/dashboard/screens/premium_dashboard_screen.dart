import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../widgets/decorative/jali_pattern.dart';
import '../../../widgets/decorative/tricolor_bar.dart';
import '../../../widgets/bilingual_label.dart';
import '../../../widgets/indian_card.dart';
// import '../../../models/service_model_new.dart'; // Unused
import '../../../providers/user_provider.dart';
import '../../../providers/conversation_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/language_provider.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120), // Space for bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 24),
              _buildStatCards(),
              const SizedBox(height: 32),
              _buildPopularServices(),
              const SizedBox(height: 32),
              _buildGovernmentSchemeBanner(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HERO HEADER ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    // In a real app, use an intl/date formatting package for Hindi date
    const String hindiDate = 'सोमवार, ३ मार्च २०२५';

    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Jali Pattern Overlay
          const Positioned.fill(
            child: JaliPattern(opacity: 0.04),
          ),

          Column(
            children: [
              // Top Tricolor Strip
              const TricolorBar(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (context.watch<LanguageProvider>().languageCode ==
                              'hi')
                            Text(
                              hindiDate,
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 13,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            user.name.isNotEmpty
                                ? '${context.watch<LanguageProvider>().languageCode == 'hi' ? 'शुभ संध्या' : 'Good Evening'}, ${user.name.split(' ')[0]}'
                                : (context
                                            .watch<LanguageProvider>()
                                            .languageCode ==
                                        'hi'
                                    ? 'शुभ संध्या'
                                    : 'Good Evening'),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.watch<LanguageProvider>().languageCode ==
                                    'hi'
                                ? hindiDate
                                : formattedDate,
                            style: context
                                        .watch<LanguageProvider>()
                                        .languageCode ==
                                    'hi'
                                ? GoogleFonts.notoSansDevanagari(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  )
                                : GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar & Bell
                    Row(
                      children: [
                        Consumer<NotificationProvider>(
                          builder: (context, np, _) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: () => context.push(Routes.notifications),
                                child: const Icon(Icons.notifications_none,
                                    color: AppColors.gold, size: 28),
                              ),
                              if (np.hasUnread)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        color: AppColors.accentRed,
                                        shape: BoxShape.circle),
                                    constraints: const BoxConstraints(
                                        minWidth: 16, minHeight: 16),
                                    child: Text(
                                      '${np.unreadCount}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.saffron,
                                AppColors.saffronDeep
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Ask CVI Bar
              GestureDetector(
                onTap: () {
                  context.push(Routes.voice);
                },
                child: Container(
                  height: 56,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      // Mic Icon Square
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.saffronGlow,
                                blurRadius: 12,
                                spreadRadius: 2),
                          ],
                        ),
                        child: const Icon(Icons.mic,
                            color: AppColors.saffron, size: 20),
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Text(
                        context.watch<LanguageProvider>().languageCode == 'hi'
                            ? 'CVI से पूछें'
                            : 'Ask CVI',
                        style: context.watch<LanguageProvider>().languageCode ==
                                'hi'
                            ? GoogleFonts.notoSansDevanagari(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                      ),
                      const Spacer(),
                      // Hint
                      Text(
                        'Passport kaise banao?',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STAT CARDS ─────────────────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Consumer3<UserProvider, AnalyticsProvider, ConversationProvider>(
      builder: (context, userProvider, analytics, convoProvider, child) {
        final user = userProvider.currentUser;

        final stats = [
          {
            'value': '${convoProvider.messages.length}',
            'title': 'Queries',
            'hindi': 'आज की बातें',
            'color': AppColors.saffron,
          },
          {
            'value': '${analytics.servicesExploredCount}',
            'title': 'Services',
            'hindi': 'सेवाएं देखी',
            'color': AppColors.emerald,
          },
          {
            'value': '${user.applicationsCount}',
            'title': 'Applications',
            'hindi': 'आवेदन',
            'color': AppColors.gold,
          },
          {
            'value': analytics.queriesCount > 0 ? '98%' : '100%',
            'title': 'Accuracy',
            'hindi': 'सटीकता',
            'color': AppColors.accentBlue,
          },
        ];

        return SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final stat = stats[index];
              final color = stat['color'] as Color;

              return AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  final sweep =
                      sin((_shimmerController.value * 2 * pi) + (index * 0.5));
                  final opacity = (sweep + 1) / 2;

                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        top: BorderSide(
                            color:
                                color.withValues(alpha: 0.5 + (0.5 * opacity)),
                            width: 2),
                        left: const BorderSide(color: AppColors.surfaceBorder),
                        right: const BorderSide(color: AppColors.surfaceBorder),
                        bottom:
                            const BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['value'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BilingualLabel(
                          englishText: stat['title'] as String,
                          hindiText: stat['hindi'] as String,
                          englishColor: AppColors.textSecondary,
                          hindiColor: AppColors.textMuted,
                          scale: 0.85,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ─── POPULAR SERVICES ───────────────────────────────────────────────────────
  Widget _buildPopularServices() {
    final services = [
      {
        'emoji': '🪪',
        'name': 'Aadhaar Card',
        'hindi': 'आधार कार्ड',
        'color': AppColors.saffron
      },
      {
        'emoji': '📘',
        'name': 'Passport',
        'hindi': 'पासपोर्ट',
        'color': AppColors.accentBlue
      },
      {
        'emoji': '💳',
        'name': 'PAN Card',
        'hindi': 'पैन कार्ड',
        'color': AppColors.gold
      },
      {
        'emoji': '🗳️',
        'name': 'Voter ID',
        'hindi': 'मतदाता पत्र',
        'color': AppColors.emerald
      },
      {
        'emoji': '🚗',
        'name': 'Driving License',
        'hindi': 'ड्राइविंग लाइसेंस',
        'color': AppColors.saffron
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BilingualLabel(
                englishText: 'Popular Services',
                hindiText: 'लोकप्रिय सेवाएं',
                englishColor: AppColors.textPrimary,
                hindiColor: AppColors.textMuted,
                scale: 1.1,
              ),
              GestureDetector(
                onTap: () => context.go(Routes.services),
                child: Text(
                  'View All →',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final s = services[index];
                final color = s['color'] as Color;
                return GestureDetector(
                  onTap: () => context.go(Routes.services),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s['emoji'] as String,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          (context.watch<LanguageProvider>().languageCode ==
                                  'hi')
                              ? (s['hindi'] as String)
                              : (s['name'] as String),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              context.watch<LanguageProvider>().languageCode ==
                                      'hi'
                                  ? GoogleFonts.notoSansDevanagari(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)
                                  : GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── GOVERNMENT SCHEME BANNER ──────────────────────────────────────────────
  Widget _buildGovernmentSchemeBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IndianCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏛️ Government Schemes',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PM Kisan, Ayushman Bharat & more — Ask CVI to check eligibility',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push(Routes.voice),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mic_rounded,
                    color: AppColors.emerald, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RECENT ACTIVITY ────────────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final userProvider = Provider.of<UserProvider>(context);
    final apps = userProvider.currentUser.applications;

    if (apps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BilingualLabel(
              englishText: 'Recent Activity',
              hindiText: 'हाल की गतिविधि',
              englishColor: AppColors.textPrimary,
              hindiColor: AppColors.textMuted,
              scale: 1.1,
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.history_rounded,
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                      size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No recent activity to show',
                    style: GoogleFonts.poppins(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BilingualLabel(
            englishText: 'Recent Activity',
            hindiText: 'हाल की गतिविधि',
            englishColor: AppColors.textPrimary,
            hindiColor: AppColors.textMuted,
            scale: 1.1,
          ),
          const SizedBox(height: 16),
          ...apps.take(3).map((app) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActivityItem(
                  icon: Icons.assignment_rounded,
                  title: 'Applied for ${app.schemeName}',
                  hindiTitle: '${app.schemeName} के लिए आवेदन किया',
                  time: DateFormat.MMMd().format(app.submissionDate),
                  color: AppColors.saffron,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String hindiTitle,
    required String time,
    required Color color,
  }) {
    return IndianCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left Border via Container inside row
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: BilingualLabel(
              englishText: title,
              hindiText: hindiTitle,
              englishColor: AppColors.textPrimary,
              hindiColor: AppColors.textMuted,
              scale: 0.9,
            ),
          ),

          // Time
          Text(
            time,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
