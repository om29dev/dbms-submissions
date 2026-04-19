import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../models/cvi_document_model.dart';
import '../../models/service_model.dart';
import '../../providers/document_vault_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SERVICE DETAIL SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().selectService(widget.serviceId);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<ServicesProvider>();
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final service = services.selectedService;

    if (service == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _ServiceFAB(service: service, lang: lang),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _DetailSliverAppBar(service: service, lang: lang),
          _StickyTabBar(controller: _tab),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _OverviewTab(service: service, lang: lang),
            _DocumentsTab(service: service, services: services, lang: lang),
            _StepsTab(service: service, services: services),
            _TimelineTab(service: service),
            _LinksTab(service: service, lang: lang),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SLIVER APP BAR
// ═════════════════════════════════════════════════════════════════════════════

class _DetailSliverAppBar extends StatelessWidget {
  final ServiceModel service;
  final String lang;
  const _DetailSliverAppBar({required this.service, required this.lang});

  Color get _catColor => switch (service.category) {
        ServiceCategory.identity => AppColors.accent,
        ServiceCategory.finance => AppColors.financeService,
        ServiceCategory.welfare => AppColors.success,
        ServiceCategory.transport => AppColors.info,
        ServiceCategory.property => AppColors.govtServices,
        ServiceCategory.health => AppColors.healthService,
        ServiceCategory.education => AppColors.educationService,
        ServiceCategory.business => AppColors.legalService,
        ServiceCategory.agriculture => AppColors.emerald,
        ServiceCategory.employment => AppColors.accentBlue,
      };

  @override
  Widget build(BuildContext context) {
    final hindiName = service.localizedName('hi');
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF0C0A08),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.textSecondary, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton(
            onPressed: () async {
              final uri = Uri.parse(service.officialLink);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open site')),
                  );
                }
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.saffron, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Official Site',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.saffron,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C0A08), Color(0xFF1A1208)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Tricolor bar at very top
                Row(children: [
                  Expanded(
                      child:
                          Container(height: 3, color: const Color(0xFFFF6B1A))),
                  Expanded(
                      child:
                          Container(height: 3, color: const Color(0xFFF5F5F5))),
                  Expanded(
                      child:
                          Container(height: 3, color: const Color(0xFF138808))),
                ]),
                const SizedBox(height: 44), // space for nav
                // Icon box
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: _catColor.withValues(alpha: 0.35), width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: _catColor.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Center(
                    child: Text(service.iconEmoji,
                        style: const TextStyle(fontSize: 36)),
                  ),
                ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut),
                const SizedBox(height: 10),
                // Service name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    service.localizedName(lang),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(delay: 150.ms),
                ),
                // Hindi name
                if (hindiName.isNotEmpty &&
                    hindiName != service.localizedName(lang))
                  Text(
                    hindiName,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                // Category chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B1A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(service.category.label.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.emerald.withValues(alpha: 0.4)),
                      ),
                      child: Text('● Available',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: AppColors.emeraldLight)),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sticky tab bar ────────────────────────────────────────────────────────────

class _StickyTabBar extends StatelessWidget {
  final TabController controller;
  const _StickyTabBar({required this.controller});

  static const _tabs = ['Overview', 'Documents', 'Steps', 'Timeline', 'Links'];

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.saffron,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(color: AppColors.saffron, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
          dividerColor: Colors.transparent,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.backgroundLight.withValues(alpha: 0.92),
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ═════════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ═════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final ServiceModel service;
  final String lang;
  const _OverviewTab({required this.service, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // What is this?
        const _SectionTitle(
            title: 'What is this?', icon: Icons.info_outline_rounded),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            service.localizedDescription(lang),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 20),

        // Who is eligible?
        const _SectionTitle(
            title: 'Who is eligible?', icon: Icons.people_outline_rounded),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: service.eligibilityCriteria.map((c) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      width: 1),
                ),
                child: Text(c,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 20),

        // Fees
        const _SectionTitle(title: 'Fees', icon: Icons.currency_rupee_rounded),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_rupee_rounded,
                    color: AppColors.info, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  service.fees,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 28),

        // Ask CVI
        NeonButton(
          label: 'Ask CVI about this  →',
          icon: Icons.mic_rounded,
          onTap: () {
            context.read<ServicesProvider>().selectService(service.id);
            context.go(Routes.voice);
          },
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DOCUMENTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _DocumentsTab extends StatefulWidget {
  final ServiceModel service;
  final ServicesProvider services;
  final String lang;

  const _DocumentsTab({
    required this.service,
    required this.services,
    required this.lang,
  });

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  // Local toggle state (not persisted — steps persistence is for steps)
  late final List<bool> _have;
  final Map<int, bool> _uploading = {};

  @override
  void initState() {
    super.initState();
    _have = List.filled(widget.service.requiredDocuments.length, false);
  }

  DocumentType _mapToDocumentType(String docName) {
    final name = docName.toLowerCase();
    if (name.contains('aadhaar')) return DocumentType.aadhaar;
    if (name.contains('pan')) return DocumentType.pan;
    if (name.contains('voter')) return DocumentType.voterID;
    if (name.contains('license')) return DocumentType.drivingLicense;
    if (name.contains('passport')) return DocumentType.passport;
    if (name.contains('bank') || name.contains('passbook')) {
      return DocumentType.bankPassbook;
    }
    if (name.contains('photo')) return DocumentType.photo;
    if (name.contains('income')) return DocumentType.incomeCertificate;
    if (name.contains('caste')) return DocumentType.casteCertificate;
    if (name.contains('ration')) return DocumentType.rationCard;
    if (name.contains('birth')) return DocumentType.birthCertificate;
    if (name.contains('land')) return DocumentType.landRecord;
    if (name.contains('marksheet')) return DocumentType.marksheet;
    if (name.contains('signature')) return DocumentType.signature;
    return DocumentType.other;
  }

  Future<void> _handleUpload(int index, DocumentItem doc) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _uploading[index] = true);

    try {
      final bytes = await image.readAsBytes();
      final docType = _mapToDocumentType(doc.name);

      if (!mounted) return;
      await context.read<DocumentVaultProvider>().addDocument(
            imageBytes: bytes,
            documentType: docType.name,
            customName: doc.name,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${doc.name} uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _have[index] = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading[index] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = widget.service.requiredDocuments;
    final ready = _have.where((v) => v).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Progress bar
        _DocProgressBar(ready: ready, total: docs.length),
        const SizedBox(height: 16),
        ...docs.asMap().entries.map((e) {
          final i = e.key;
          final doc = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              borderColor: doc.isOptional
                  ? AppColors.border
                  : AppColors.accent.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (doc.isOptional)
                                  const _Chip(
                                      label: 'Optional',
                                      color: AppColors.info,
                                      small: true),
                                if (!doc.isOptional)
                                  const _Chip(
                                      label: 'Required',
                                      color: AppColors.accent,
                                      small: true),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(doc.name,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontFamily: 'Rajdhani',
                                    fontWeight: FontWeight.w700)),
                            Text(doc.description,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: _have[i],
                        onChanged: (v) => setState(() => _have[i] = v ?? false),
                        activeColor: AppColors.accent,
                        checkColor: AppColors.background,
                        side: const BorderSide(
                            color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                      color: AppColors.border, thickness: 1, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _showDocDetail(context, doc),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: AppColors.textDisabled),
                            SizedBox(width: 4),
                            Text('Details',
                                style: TextStyle(
                                    color: AppColors.textDisabled,
                                    fontSize: 11,
                                    fontFamily: 'Rajdhani')),
                          ],
                        ),
                      ),
                      Consumer<DocumentVaultProvider>(
                        builder: (context, vault, child) {
                          final docType = _mapToDocumentType(doc.name);
                          final exists = vault.hasDocument(docType.name);
                          final isUploading = _uploading[i] ?? false;

                          if (exists || _have[i]) {
                            return const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.success, size: 14),
                                SizedBox(width: 4),
                                Text('In Vault',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Rajdhani')),
                              ],
                            );
                          }

                          return InkWell(
                            onTap: isUploading
                                ? null
                                : () => _handleUpload(i, doc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUploading
                                    ? AppColors.border
                                    : AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isUploading
                                      ? AppColors.border
                                      : AppColors.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: isUploading
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.accent),
                                    )
                                  : const Row(
                                      children: [
                                        Icon(Icons.upload_rounded,
                                            size: 12, color: AppColors.accent),
                                        SizedBox(width: 4),
                                        Text('Upload to Vault',
                                            style: TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Rajdhani')),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideY(
                begin: 0.06, end: 0, delay: Duration(milliseconds: 60 * i)),
          );
        }),
      ],
    );
  }

  void _showDocDetail(BuildContext context, DocumentItem doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0x1A00F5FF), width: 1)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc.name,
                style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(doc.description,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.verified_outlined,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                doc.isOptional
                    ? 'This document is optional'
                    : 'This document is required',
                style: TextStyle(
                    color: doc.isOptional ? AppColors.info : AppColors.success,
                    fontSize: 13,
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w600),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DocProgressBar extends StatelessWidget {
  final int ready;
  final int total;
  const _DocProgressBar({required this.ready, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? ready / total : 0.0;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Documents ready: $ready / $total',
                  style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text('${(pct * 100).toInt()}%',
                  style: const TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 13,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STEPS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _StepsTab extends StatefulWidget {
  final ServiceModel service;
  final ServicesProvider services;
  const _StepsTab({required this.service, required this.services});

  @override
  State<_StepsTab> createState() => _StepsTabState();
}

class _StepsTabState extends State<_StepsTab> {
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServicesProvider>();
    final progress = sp.getProgress(widget.service.id);
    final steps = widget.service.steps;
    final completed = progress.where((v) => v).length;
    final current = progress.indexWhere((v) => !v);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Overall progress
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$completed of ${steps.length} steps complete',
                  style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: steps.isNotEmpty ? completed / steps.length : 0,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Steps
        ...steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final done = i < progress.length && progress[i];
          final isCurrent = i == current;

          final circleColor = done
              ? AppColors.accent
              : isCurrent
                  ? const Color(0xFFFFB300) // amber
                  : Colors.transparent;
          final textColor = done
              ? AppColors.accent
              : isCurrent
                  ? const Color(0xFFFFB300)
                  : AppColors.textDisabled;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number circle + connector line
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor.withValues(alpha: done ? 1 : 0.1),
                        border: Border.all(
                            color: done
                                ? AppColors.accent
                                : isCurrent
                                    ? const Color(0xFFFFB300)
                                    : AppColors.border,
                            width: 2),
                        boxShadow: done || isCurrent
                            ? [
                                BoxShadow(
                                    color: textColor.withValues(alpha: 0.3),
                                    blurRadius: 12)
                              ]
                            : null,
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : Center(
                              child: Text('${step.number}',
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'SpaceMono',
                                      fontSize: 13)),
                            ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: done
                              ? AppColors.accent.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: i < steps.length - 1 ? 20 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(step.title,
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: done || isCurrent
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            )),
                        const SizedBox(height: 4),
                        Text(step.description,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.5)),
                        if (isCurrent) ...[
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () async {
                              await context
                                  .read<ServicesProvider>()
                                  .markStepComplete(widget.service.id, i);
                              if (step.actionUrl != null) {
                                final uri = Uri.tryParse(step.actionUrl!);
                                if (uri != null && await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline,
                                size: 16, color: AppColors.accent),
                            label: const Text('Mark Complete',
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontFamily: 'Rajdhani',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideX(
              begin: 0.04, end: 0, delay: Duration(milliseconds: 60 * i));
        }),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TIMELINE TAB
// ═════════════════════════════════════════════════════════════════════════════

class _TimelineTab extends StatelessWidget {
  final ServiceModel service;
  const _TimelineTab({required this.service});

  static final _phases = [
    ('Application', '1-2 days', 7),
    ('Verification', '3-7 days', 12),
    ('Processing', '7-21 days', 28),
    ('Dispatch/Ready', '3-5 days', 5),
  ];

  Color _phaseColor(int days) {
    if (days <= 7) return AppColors.success;
    if (days <= 30) return const Color(0xFFFFB300);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Overall time card
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: AppColors.accent, size: 32),
              const SizedBox(height: 8),
              const Text('Total Estimated Time',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Rajdhani')),
              const SizedBox(height: 4),
              Text(
                service.estimatedTimeline,
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 80.ms),

        const SizedBox(height: 24),
        const _SectionTitle(
            title: 'Application Phases', icon: Icons.timeline_rounded),
        const SizedBox(height: 16),

        // Horizontal timeline
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _phases.length,
            itemBuilder: (context, i) {
              final (label, duration, days) = _phases[i];
              final color = _phaseColor(days);
              final isLast = i == _phases.length - 1;

              return Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circle node
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.12),
                          border: Border.all(color: color, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 12)
                          ],
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'SpaceMono',
                                  fontSize: 18)),
                        ),
                      ).animate().scale(
                          delay: Duration(milliseconds: 100 * i),
                          duration: 400.ms,
                          curve: Curves.elasticOut),
                      const SizedBox(height: 8),
                      Text(label,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700)),
                      Text(duration,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontFamily: 'SpaceMono')),
                    ],
                  ),
                  if (!isLast)
                    Container(
                      width: 40,
                      height: 2,
                      color: AppColors.border,
                      margin: const EdgeInsets.only(bottom: 36),
                    ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Legend
        const GlassCard(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Duration Guide',
                  style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              SizedBox(height: 10),
              _LegendItem(
                  color: AppColors.success, label: 'Fast — Under 7 days'),
              _LegendItem(
                  color: Color(0xFFFFB300), label: 'Medium — 7 to 30 days'),
              _LegendItem(color: AppColors.error, label: 'Slow — Over 30 days'),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LINKS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _LinksTab extends StatelessWidget {
  final ServiceModel service;
  final String lang;
  const _LinksTab({required this.service, required this.lang});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Official portal
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.language_rounded, color: AppColors.accent, size: 22),
                SizedBox(width: 10),
                Text('Official Portal',
                    style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 8),
              Text(service.officialLink,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: 'SpaceMono'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              NeonButton(
                label: 'Open Portal  →',
                icon: Icons.open_in_new_rounded,
                height: 44,
                onTap: () => _launchUrl(context, service.officialLink),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // Helpline
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.phone_outlined,
                    color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Helpline Number',
                        style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(service.helplineNumber,
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontFamily: 'SpaceMono')),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    _launchUrl(context, 'tel:${service.helplineNumber}'),
                child: const Text('Call',
                    style: TextStyle(
                        color: AppColors.success,
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // Ask CVI
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderColor: AppColors.primary.withValues(alpha: 0.3),
          backgroundColor: AppColors.primary.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.mic_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text('Ask CVI for Help',
                    style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 8),
              const Text(
                'Speak with CVI to get step-by-step guidance for this service.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 14),
              NeonButton.outlined(
                label: '🎤 Ask CVI Now',
                icon: Icons.mic_none_rounded,
                height: 44,
                onTap: () {
                  context.read<ServicesProvider>().selectService(service.id);
                  context.go(Routes.voice);
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.06, end: 0),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FAB
// ═════════════════════════════════════════════════════════════════════════════

class _ServiceFAB extends StatelessWidget {
  final ServiceModel service;
  final String lang;
  const _ServiceFAB({required this.service, required this.lang});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.read<ServicesProvider>().selectService(service.id);
        context.go(Routes.voice);
      },
      backgroundColor: AppColors.primary,
      elevation: 8,
      icon: const Text('🎤', style: TextStyle(fontSize: 16)),
      label: Text(
        'Ask about ${service.localizedName(lang)}',
        style: const TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED
// ═════════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            )),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;
  const _Chip({required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 7 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'SpaceMono')),
    );
  }
}
