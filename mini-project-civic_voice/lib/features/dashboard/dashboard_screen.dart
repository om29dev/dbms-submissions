import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/decorative/jali_pattern.dart';
import '../../widgets/decorative/tricolor_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _micPulse;

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _micPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ───────────────────────────────────────────────────
          _HeroHeader(micPulse: _micPulse),

          // ── Main Content ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // Stats Row
                const _StatsRow().animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),

                // Smart AI Features
                const _SectionHeader(
                  hindi: 'स्मार्ट सुविधाएं',
                  english: 'Smart Features',
                ),
                const SizedBox(height: 14),
                const _SmartFeaturesGrid()
                    .animate()
                    .fadeIn(delay: 250.ms)
                    .slideY(begin: 0.08, end: 0, delay: 250.ms),

                const SizedBox(height: 28),

                // Popular Services
                _SectionHeader(
                  hindi: 'सेवाएं',
                  english: 'Popular Services',
                  onAction: () => context.go(Routes.services),
                ),
                const SizedBox(height: 14),
                _ServicesGrid(
                  services: context
                      .watch<ServicesProvider>()
                      .allServices
                      .take(6)
                      .toList(),
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.08, end: 0, delay: 300.ms),
                const SizedBox(height: 28),

                // Govt Scheme Banner
                const _SchemeBanner().animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 28),

                // Recent Activity
                const _SectionHeader(
                    hindi: 'हाल की गतिविधि', english: 'Recent Activity'),
                const SizedBox(height: 14),
                const _RecentActivity().animate().fadeIn(delay: 500.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERO HEADER SLIVER
// ═══════════════════════════════════════════════════════════════════════════════

class _HeroHeader extends StatefulWidget {
  final AnimationController micPulse;
  const _HeroHeader({required this.micPulse});

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader> {
  int _queryIndex = 0;
  int _charIndex = 0;

  static const _queries = [
    'Passport kaise banao?',
    'पेंशन के लिए कैसे आवेदन करें?',
    'Ration Card eligibility check?',
    'வாகன உரிமம் பெறுவது எப்படி?',
  ];

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  Future<void> _startTypewriter() async {
    while (mounted) {
      final target = _queries[_queryIndex];
      while (_charIndex < target.length && mounted) {
        await Future.delayed(const Duration(milliseconds: 45));
        if (!mounted) return;
        setState(() => _charIndex++);
      }
      await Future.delayed(const Duration(milliseconds: 2400));
      while (_charIndex > 0 && mounted) {
        await Future.delayed(const Duration(milliseconds: 22));
        if (!mounted) return;
        setState(() => _charIndex--);
      }
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() => _queryIndex = (_queryIndex + 1) % _queries.length);
      }
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    final lang = context.read<LanguageProvider>().currentLanguage;
    final name =
        context.read<AuthProvider>().currentUser?.name.split(' ').first ??
            'there';
    if (lang == 'hi' || lang == 'mr') return 'नमस्ते, $name 🙏';
    final gr = h < 12
        ? 'Good Morning'
        : h < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    return '$gr, $name';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayText = _queries[_queryIndex].substring(0, _charIndex);
    final initials = auth.currentUser?.initials ?? 'G';

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          border: Border(
            bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
        ),
        child: Stack(
          children: [
            // Jali watermark
            const Positioned.fill(
              child: JaliPattern(opacity: 0.04, color: AppColors.gold),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tricolor bar at very top
                  const TricolorBar(height: 2),
                  const SizedBox(height: 18),

                  // Top row — greeting + avatar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'नमस्ते',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 12,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _greeting,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'सोमवार, ${_formattedDate()}',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Avatar
                        GestureDetector(
                          onTap: () => context.go(Routes.profile),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.saffron,
                                  AppColors.saffronDeep
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.saffron.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ask CVI bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => context.go(Routes.voice),
                      child: AnimatedBuilder(
                        animation: widget.micPulse,
                        builder: (_, child) {
                          return Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.bgMid,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.saffron.withValues(
                                      alpha:
                                          0.05 + widget.micPulse.value * 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            // Mic icon square
                            AnimatedBuilder(
                              animation: widget.micPulse,
                              builder: (_, __) {
                                return Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.saffron,
                                        AppColors.saffronDeep
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(13),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.saffron.withValues(
                                            alpha: 0.3 +
                                                widget.micPulse.value * 0.25),
                                        blurRadius:
                                            10 + widget.micPulse.value * 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.mic_rounded,
                                      color: Colors.white, size: 20),
                                );
                              },
                            ),

                            const SizedBox(width: 12),

                            // Typewriter text
                            Expanded(
                              child: Text(
                                displayText.isEmpty
                                    ? 'Ask CVI · CVI से पूछें'
                                    : displayText,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: displayText.isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Pulse dot
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.saffron,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.saffron.withValues(
                                        alpha: widget.micPulse.value),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
    final d = DateTime.now();
    final days = [
      'रविवार',
      'सोमवार',
      'मंगलवार',
      'बुधवार',
      'गुरुवार',
      'शुक्रवार',
      'शनिवार'
    ];
    final months = [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर'
    ];
    return '${days[d.weekday % 7]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<ServicesProvider>().getStats();
    final cards = [
      _StatData('${stats['totalQueries']}', 'Queries', 'आज की बातें',
          AppColors.saffron, Icons.chat_bubble_outline_rounded),
      _StatData('${stats['activeApplications']}', 'Applications', 'आवेदन',
          AppColors.gold, Icons.assignment_outlined),
      _StatData('${stats['totalServices']}', 'Services', 'सेवाएं देखी',
          AppColors.emeraldLight, Icons.grid_view_rounded),
      const _StatData('94%', 'Accuracy', 'सटीकता', AppColors.accentBlue,
          Icons.verified_outlined),
    ];

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _StatCard(data: cards[i], index: i),
      ),
    );
  }
}

class _StatData {
  final String value, label, hindi;
  final Color color;
  final IconData icon;
  const _StatData(this.value, this.label, this.hindi, this.color, this.icon);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  final int index;
  const _StatCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gold top border accent
          Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [data.color.withValues(alpha: 0.8), Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.color, size: 16),
                ),
                const Spacer(),
                // Value
                Text(
                  data.value,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: data.color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (context.watch<LanguageProvider>().languageCode == 'hi')
                  Text(
                    data.hindi,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 150 + index * 80)).slideX(
        begin: 0.12, end: 0, delay: Duration(milliseconds: 150 + index * 80));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String hindi;
  final String english;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.hindi,
    required this.english,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.watch<LanguageProvider>().languageCode == 'hi'
                  ? hindi
                  : english,
              style: context.watch<LanguageProvider>().languageCode == 'hi'
                  ? GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    )
                  : GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
            ),
          ],
        ),
        const Spacer(),
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.saffron.withValues(alpha: 0.25)),
              ),
              child: Text(
                'View All →',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.saffron,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICES GRID
// ═══════════════════════════════════════════════════════════════════════════════

class _ServicesGrid extends StatelessWidget {
  final List<ServiceModel> services;
  const _ServicesGrid({required this.services});

  Color _colorForCategory(ServiceCategory cat) => switch (cat) {
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: services.length.clamp(0, 6),
      itemBuilder: (context, i) {
        final s = services[i];
        final color = _colorForCategory(s.category);
        return GestureDetector(
          onTap: () {
            context.read<ServicesProvider>().selectService(s.id);
            context.go(Routes.serviceDetailPath(s.id));
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Icon band
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(17)),
                    ),
                    child: Center(
                      child: Text(
                        s.iconEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                // Label band
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.localizedName('en'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (s.isPopular)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.saffron.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Popular',
                              style: GoogleFonts.poppins(
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                color: AppColors.saffron,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 300 + i * 60)).slideY(
            begin: 0.1, end: 0, delay: Duration(milliseconds: 300 + i * 60));
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GOVERNMENT SCHEME BANNER
// ═══════════════════════════════════════════════════════════════════════════════

class _SchemeBanner extends StatelessWidget {
  const _SchemeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Stack(
        children: [
          // Top accent
          Container(
            height: 2,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [AppColors.saffron, AppColors.gold, Colors.transparent],
              ),
            ),
          ),
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.saffron, AppColors.gold],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldLight],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'SCHEME',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bgDeep,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PM Kisan Samman Nidhi',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'पीएम किसान सम्मान निधि',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹6,000/year benefit · Check eligibility →',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌾', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RECENT ACTIVITY
// ═══════════════════════════════════════════════════════════════════════════════

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    final items = [
      const _ActivityData('🛂', 'Passport Application', 'पासपोर्ट आवेदन',
          '2 min ago', AppColors.accentBlue),
      const _ActivityData('🌾', 'Kisan Credit Card Query',
          'किसान क्रेडिट कार्ड', '1 hr ago', AppColors.emeraldLight),
      const _ActivityData('🏥', 'Ayushman Bharat Check', 'आयुष्मान भारत',
          '2 days ago', AppColors.accentTeal),
    ];

    return Column(
      children: items
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgMid,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: AppColors.saffron, width: 2),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: e.value.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            e.value.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value.english,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              e.value.hindi,
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        e.value.time,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 500 + e.key * 80))
                  .slideX(
                      begin: -0.05,
                      end: 0,
                      delay: Duration(milliseconds: 500 + e.key * 80)),
            ),
          )
          .toList(),
    );
  }
}

class _ActivityData {
  final String emoji, english, hindi, time;
  final Color color;
  const _ActivityData(
      this.emoji, this.english, this.hindi, this.time, this.color);
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMART FEATURES GRID
// ═══════════════════════════════════════════════════════════════════════════════

class _SmartFeaturesGrid extends StatelessWidget {
  const _SmartFeaturesGrid();

  @override
  Widget build(BuildContext context) {
    final features = [
      const _FeatureData('💬', 'Voice Complaint', 'शिकायत दर्ज करें',
          AppColors.accentBlue, Routes.voiceComplaint),
      const _FeatureData('📄', 'AI Scanner', 'दस्तावेज़ स्कैन',
          AppColors.accentTeal, Routes.documentScanner),
      const _FeatureData('🔍', 'Scheme Finder', 'योजना खोजें', AppColors.gold,
          Routes.schemeDiscovery),
      const _FeatureData('📊', 'App Tracker', 'आवेदन स्थिति',
          AppColors.emeraldLight, Routes.appTracker),
      const _FeatureData('📶', 'Offline Guide', 'ऑफ़लाइन मदद',
          AppColors.accentPurple, Routes.offlineGuidance),
      const _FeatureData('👤', 'Citizen Profile', 'नागरिक प्रोफाइल',
          AppColors.accentAmber, Routes.citizenProfile),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final f = features[i];
        return GestureDetector(
          onTap: () => context.push(f.route),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: f.color.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: f.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    f.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  f.english,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  f.hindi,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 50)).scale(
            begin: const Offset(0.9, 0.9),
            delay: Duration(milliseconds: 200 + i * 50));
      },
    );
  }
}

class _FeatureData {
  final String emoji, english, hindi, route;
  final Color color;
  const _FeatureData(
      this.emoji, this.english, this.hindi, this.color, this.route);
}
