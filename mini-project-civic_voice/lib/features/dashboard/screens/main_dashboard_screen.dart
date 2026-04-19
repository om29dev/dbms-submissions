import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../models/service_model.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/conversation_provider.dart';
import '../../../widgets/t_text.dart';
import '../../../providers/services_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/flag/waving_flag_widget.dart';
import '../../../providers/language_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN DASHBOARD SCREEN (DATA-RICH)
// ═══════════════════════════════════════════════════════════════════════════════

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  late String _greeting;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initGreeting();
  }

  void _initGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  String _formattedDate() {
    final date = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A08),
      body: WavingFlagWidget(
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // Tricolor bar at very top
              const SizedBox(
                height: 3,
                child: Row(children: [
                  Expanded(
                      child: SizedBox(
                          child: ColoredBox(color: Color(0xFFFF6B1A)))),
                  Expanded(
                      child: SizedBox(
                          child: ColoredBox(color: Color(0xFFF5F5F5)))),
                  Expanded(
                      child: SizedBox(
                          child: ColoredBox(color: Color(0xFF138808)))),
                ]),
              ),
              _buildHeroGreeting(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildSmartFeatures(),
              const SizedBox(height: 32),
              _buildPopularServices(),
              const SizedBox(height: 32),
              _buildGovSchemesBanner(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section 1: Hero Greeting ───────────────────────────────────────────────
  Widget _buildHeroGreeting() {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUser?.name ?? 'Citizen';
    final userInitials = auth.currentUser?.initials ?? 'C';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formattedDate(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.saffron,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                TText(
                  '$_greeting, $userName',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFF8F0),
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 4),
                TText(
                  'How can we serve you today?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
          // Notifications Bell
          Consumer<NotificationProvider>(
            builder: (context, np, _) => GestureDetector(
              onTap: () => context.push(Routes.notifications),
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgMid.withValues(alpha: 0.5),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary, size: 24),
                    if (np.hasUnread)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.saffron, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ).animate().scale(delay: 350.ms, curve: Curves.easeOutBack),
          // User Avatar
          GestureDetector(
            onTap: () => context.go(Routes.profile),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.saffron, AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.saffron.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
                border: Border.all(color: AppColors.bgDeep, width: 2),
              ),
              child: Center(
                child: Text(
                  userInitials,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  // ─── Section 2: Stats Row ───────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Consumer2<AnalyticsProvider, UserProvider>(
      builder: (context, analytics, userProv, child) {
        final activeApps = userProv.currentUser.pendingCount;
        final savedDocs = userProv.currentUser.documents.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _StatCard(
                        label: 'Queries Today',
                        hindiLabel: 'आज की बातें',
                        value: '${analytics.queriesCount}',
                        icon: Icons.forum_rounded,
                        color: AppColors.saffron,
                        delay: 0),
                    const SizedBox(height: 12),
                    _StatCard(
                        label: 'Active Apps',
                        hindiLabel: 'सक्रिय आवेदन',
                        value: '$activeApps',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFF138808),
                        delay: 100),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _StatCard(
                        label: 'Services Explored',
                        hindiLabel: 'देखी गई सेवाएं',
                        value: '${analytics.servicesExploredCount}',
                        icon: Icons.travel_explore_rounded,
                        color: AppColors.gold,
                        delay: 50),
                    const SizedBox(height: 12),
                    _StatCard(
                        label: 'Saved Docs',
                        hindiLabel: 'सहेजे दस्तावेज़',
                        value: '$savedDocs',
                        icon: Icons.folder_special_rounded,
                        color: const Color(0x4DFFFFFF),
                        delay: 150),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Section 3: Quick Actions ───────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      (
        'Ask CVI',
        Icons.mic_rounded,
        AppColors.saffron,
        () => context.push(Routes.voice)
      ),
      (
        'Complaints',
        Icons.report_problem_rounded,
        AppColors.accentRed,
        () => context.push(Routes.voiceComplaint)
      ),
      (
        'Services',
        Icons.apps_rounded,
        AppColors.gold,
        () => context.go(Routes.services)
      ),
      (
        'My Apps',
        Icons.assignment_rounded,
        AppColors.gold,
        () => context.push(Routes.myApplications)
      ),
      (
        'Secure Vault',
        Icons.lock_person_rounded,
        AppColors.saffron,
        () => context.push(Routes.documentVault)
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeading('Quick Actions'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final (label, icon, color, onTap) = actions[index];
              return _QuickActionBtn(
                  label: label,
                  icon: icon,
                  color: color,
                  onTap: onTap,
                  index: index);
            },
          ),
        ),
      ],
    );
  }

  // ─── Section 3.5: Smart Features ──────────────────────────────────────────────
  Widget _buildSmartFeatures() {
    final features = [
      (
        'Voice Complaint',
        'शिकायत दर्ज',
        Icons.record_voice_over_rounded,
        AppColors.accentBlue,
        Routes.voiceComplaint
      ),
      (
        'AI Scanner',
        'दस्तावेज़ स्कैन',
        Icons.document_scanner_rounded,
        AppColors.accentTeal,
        Routes.documentScanner
      ),
      (
        'Scheme Finder',
        'योजना खोजें',
        Icons.search_rounded,
        AppColors.gold,
        Routes.schemeDiscovery
      ),
      (
        'App Tracker',
        'स्थिति',
        Icons.track_changes_rounded,
        AppColors.emeraldLight,
        Routes.appTracker
      ),
      (
        'Offline Guide',
        'ऑफ़लाइन',
        Icons.download_done_rounded,
        AppColors.accentPurple,
        Routes.offlineGuidance
      ),
      (
        'Profile Recs',
        'प्रोफाइल',
        Icons.person_search_rounded,
        AppColors.accentAmber,
        Routes.citizenProfile
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeading('Smart Features & AI'),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final f = features[index];
            return GestureDetector(
              onTap: () => context.push(f.$5),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1814),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: f.$4.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: f.$4.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f.$3, color: f.$4, size: 24),
                    ),
                    const SizedBox(height: 8),
                    TText(
                      f.$1,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (context.watch<LanguageProvider>().languageCode == 'hi')
                      Text(
                        f.$2,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 200 + index * 50))
                .scale(delay: Duration(milliseconds: 200 + index * 50));
          },
        ),
      ],
    );
  }

  // ─── Section 4: Popular Services Grid ───────────────────────────────────────
  Widget _buildPopularServices() {
    final services = context.watch<ServicesProvider>().allServices;
    final popular = services
        .where((s) =>
            s.isPopular ||
            s.id == 'aadhaar_card' ||
            s.id == 'pan_card' ||
            s.id == 'passport')
        .take(6)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionHeading('Popular Services'),
              GestureDetector(
                onTap: () => context.go(Routes.services),
                child: TText(
                  'View All',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.saffron),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: popular.length,
          itemBuilder: (context, index) {
            final s = popular[index];
            return _PopularServiceCard(service: s, index: index);
          },
        ),
      ],
    );
  }

  // ─── Section 5: Gov Schemes Banner ──────────────────────────────────────────
  Widget _buildGovSchemesBanner() {
    final schemes = <(String, String, String)>[
      ('PM Kisan Samman Nidhi', '₹6,000/year to farmers', 'Ongoing'),
      ('Ayushman Bharat', 'Free ₹5L health cover', '31 Mar'),
      ('Pradhan Mantri Awas Yojana', 'Housing for All', 'Ongoing'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeading('Government Schemes'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: schemes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final (name, benefit, deadline) = schemes[index];
              return _SchemeCard(
                  name: name,
                  benefit: benefit,
                  deadline: deadline,
                  index: index);
            },
          ),
        ),
      ],
    );
  }

  // ─── Section 6: Recent Activity Timeline ────────────────────────────────────
  Widget _buildRecentActivity() {
    return Consumer<ConversationProvider>(
      builder: (context, conv, child) {
        final messages = conv.modernMessages
            .where((m) => m.isUser)
            .toList()
            .reversed
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeading('Recent Voice Queries'),
            ),
            const SizedBox(height: 16),
            if (messages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Center(
                    child: TText(
                      'No recent queries.\nTap the mic below to start a conversation with CVI!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_rounded,
                              size: 16, color: AppColors.saffron),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgDark,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(msg.text,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(_formatTime(msg.timestamp),
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * index)),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    String p = dt.hour >= 12 ? 'PM' : 'AM';
    int h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    String m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $p';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUBCOMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String hindiLabel;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard(
      {required this.label,
      required this.hindiLabel,
      required this.value,
      required this.icon,
      required this.color,
      required this.delay});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colored top border
            SizedBox(
              height: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(value,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.0)),
                        const SizedBox(height: 2),
                        TText(label,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(hindiLabel,
                            style: GoogleFonts.notoSansDevanagari(
                                fontSize: 9, color: AppColors.textMuted)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 300 + delay))
        .slideY(begin: 0.1, end: 0);
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int index;

  const _QuickActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1814),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          TText(label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + index * 50))
        .scale(delay: Duration(milliseconds: 400 + index * 50));
  }
}

class _PopularServiceCard extends StatelessWidget {
  final ServiceModel service;
  final int index;

  const _PopularServiceCard({required this.service, required this.index});

  static const _categoryColors = {
    ServiceCategory.identity: AppColors.saffron,
    ServiceCategory.health: AppColors.gold,
    ServiceCategory.education: AppColors.saffron,
    ServiceCategory.finance: AppColors.gold,
    ServiceCategory.welfare: AppColors.emeraldLight,
    ServiceCategory.agriculture: Color(0xFF138808),
    ServiceCategory.transport: AppColors.saffron,
    ServiceCategory.property: AppColors.gold,
    ServiceCategory.business: AppColors.goldLight,
    ServiceCategory.employment: AppColors.emeraldLight,
  };

  @override
  Widget build(BuildContext context) {
    final serviceColor = _categoryColors[service.category] ?? AppColors.gold;
    // Stable view count per card index (not random on every rebuild)
    final views = [2340, 5120, 1890, 4300, 3210, 1560][index % 6];
    final hindiName = service.localizedName('hi');

    return GestureDetector(
      onTap: () {
        context.read<AnalyticsProvider>().recordServiceView(service.id);
        context.push(Routes.serviceDetailPath(service.id), extra: service);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1F14), Color(0xFF1E1814)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3D2E1E), width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top — icon box + arrow
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: serviceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: serviceColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        service.iconEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.textMuted, size: 12),
                  ),
                ],
              ),
              const Spacer(),
              // Bottom — name, hindi, views
              Flexible(
                child: Text(
                  context.watch<LanguageProvider>().languageCode == 'hi'
                      ? (hindiName.isNotEmpty
                          ? hindiName
                          : service.localizedName('en'))
                      : service.localizedName('en'),
                  style: context.watch<LanguageProvider>().languageCode == 'hi'
                      ? GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)
                      : GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$views views',
                    style:
                        GoogleFonts.poppins(fontSize: 9, color: AppColors.gold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 500 + index * 50))
        .slideY(begin: 0.1, end: 0);
  }
}

class _SchemeCard extends StatelessWidget {
  final String name;
  final String benefit;
  final String deadline;
  final int index;

  const _SchemeCard(
      {required this.name,
      required this.benefit,
      required this.deadline,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1208), Color(0xFF0C1A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A3D1E), width: 1),
        ),
        child: Row(
          children: [
            // Left green accent bar
            Container(width: 3, color: const Color(0xFF0A7A3E)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A7A3E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Gov Scheme',
                              style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        const Icon(Icons.verified_rounded,
                            color: Color(0xFF0A7A3E), size: 14),
                      ],
                    ),
                    TText(name,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(benefit,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (deadline != 'Ongoing')
                          Text('Ends: $deadline',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentRed))
                        else
                          Text(deadline,
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: AppColors.emeraldLight)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 600 + index * 100))
        .slideX(begin: 0.1, end: 0);
  }
}

class _FloatingMicButton extends StatefulWidget {
  @override
  State<_FloatingMicButton> createState() => _FloatingMicButtonState();
}

class _FloatingMicButtonState extends State<_FloatingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.saffron
                    .withValues(alpha: 0.3 + 0.3 * _pulseCtrl.value),
                blurRadius: 20 + 10 * _pulseCtrl.value,
                spreadRadius: 2 + 4 * _pulseCtrl.value,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push(Routes.voice),
            backgroundColor: AppColors.saffron,
            child: const Icon(Icons.mic_rounded, size: 28, color: Colors.white),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADING
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Row(children: [
          Container(width: 20, height: 2, color: const Color(0xFFFF6B1A)),
          Container(
              width: 20,
              height: 2,
              color: const Color(0xFFF5F5F5).withValues(alpha: 0.4)),
          Container(width: 20, height: 2, color: const Color(0xFF138808)),
        ]),
      ],
    );
  }
}
