import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../models/cvi_document_model.dart';
import '../../../models/service_model.dart';
import '../../../providers/document_vault_provider.dart';
import '../../../providers/language_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICE DETAIL SCREEN V2
// ═══════════════════════════════════════════════════════════════════════════════

class ServiceDetailScreenV2 extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreenV2({super.key, required this.service});

  @override
  State<ServiceDetailScreenV2> createState() => _ServiceDetailScreenV2State();
}

class _ServiceDetailScreenV2State extends State<ServiceDetailScreenV2>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  int _currentStep = -1; // -1 = not started
  final _appIdCtrl = TextEditingController();
  bool _statusChecked = false;

  ServiceModel get s => widget.service;

  // Derive a color from the category
  Color get _accentColor => switch (s.category) {
        ServiceCategory.identity => AppColors.accentBlue,
        ServiceCategory.health => AppColors.accentTeal,
        ServiceCategory.education => AppColors.accentPurple,
        ServiceCategory.finance => AppColors.gold,
        ServiceCategory.welfare => AppColors.emeraldLight,
        ServiceCategory.agriculture => AppColors.accentGreen,
        ServiceCategory.transport => const Color(0xFF0277BD),
        ServiceCategory.property => AppColors.accentPurple,
        ServiceCategory.business => AppColors.accentAmber,
        ServiceCategory.employment => AppColors.emeraldLight,
      };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _appIdCtrl.dispose();
    super.dispose();
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open: $url'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  String _buildChecklist() {
    final buf = StringBuffer();
    buf.writeln('DOCUMENT CHECKLIST — ${s.localizedName("en")}');
    buf.writeln('=' * 42);
    for (final doc in s.requiredDocuments) {
      buf.writeln(
          '\n${doc.isOptional ? "[ ] OPTIONAL" : "[*] MANDATORY"} — ${doc.name}');
      buf.writeln('    ${doc.description}');
    }
    return buf.toString();
  }

  // ─── AI Scheme Guide (CVI Guide) ──────────────────────────────────────────

  void _onAskCVI() {
    context.push(Routes.voice, extra: widget.service);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Column(
        children: [
          // ── Hero Header ──────────────────────────────────────────────────
          _ServiceHeader(
            service: s,
            accentColor: _accentColor,
            onBack: () => Navigator.of(context).pop(),
            onLaunchUrl: () => _launch(s.officialLink),
          ),

          // ── Tab Bar ──────────────────────────────────────────────────────
          _CVITabBar(controller: _tabCtrl, accentColor: _accentColor),

          // ── Tab Content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              physics: const BouncingScrollPhysics(),
              children: [
                // Tab 1 — Overview
                _OverviewTab(service: s, accentColor: _accentColor),

                // Tab 2 — Documents
                _DocumentsTab(
                  service: s,
                  accentColor: _accentColor,
                  onDownload: () {
                    final text = _buildChecklist();
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checklist copied to clipboard ✓'),
                        backgroundColor: AppColors.emeraldLight,
                      ),
                    );
                  },
                ),

                // Tab 3 — Steps
                _StepsTab(
                  service: s,
                  accentColor: _accentColor,
                  currentStep: _currentStep,
                  onStartStep: (i) => setState(() => _currentStep = i),
                  onLaunchUrl: () => _launch(s.officialLink),
                ),

                // Tab 4 — Track
                _TrackTab(
                  service: s,
                  accentColor: _accentColor,
                  appIdCtrl: _appIdCtrl,
                  statusChecked: _statusChecked,
                  onCheckStatus: () {
                    setState(() => _statusChecked = true);
                    _launch(s.officialLink);
                  },
                ),
              ],
            ),
          ),

          // ── Sticky Bottom Bar ─────────────────────────────────────────────
          _StickyBar(
            accentColor: _accentColor,
            onApplyNow: () {
              // Route to Smart AI Form (with voice readout + profile auto-fill)
              context.push(Routes.smartFormPath(s.id), extra: s);
            },
            onAskCVI: _onAskCVI,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICE HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _ServiceHeader extends StatelessWidget {
  final ServiceModel service;
  final Color accentColor;
  final VoidCallback onBack;
  final VoidCallback onLaunchUrl;

  const _ServiceHeader({
    required this.service,
    required this.accentColor,
    required this.onBack,
    required this.onLaunchUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.25),
            AppColors.bgDark,
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textSecondary, size: 20),
                  ),
                  const Spacer(),
                  // Official site button
                  GestureDetector(
                    onTap: onLaunchUrl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.35),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new_rounded,
                              color: accentColor, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'Official Site',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Service icon + names
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with glow
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.3), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(service.iconEmoji,
                          style: const TextStyle(fontSize: 36)),
                    ),
                  ).animate().scale(
                      begin: const Offset(0.85, 0.85),
                      duration: 450.ms,
                      curve: Curves.easeOutBack),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            service.category.label.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.watch<LanguageProvider>().languageCode == 'hi'
                              ? service.localizedName('hi')
                              : service.localizedName('en'),
                          style:
                              context.watch<LanguageProvider>().languageCode ==
                                      'hi'
                                  ? GoogleFonts.notoSansDevanagari(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    )
                                  : GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                        ),
                        const SizedBox(height: 6),
                        // Popular badge
                        if (service.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [AppColors.saffron, AppColors.gold]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '⭐ Popular Service',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _CVITabBar extends StatelessWidget {
  final TabController controller;
  final Color accentColor;

  const _CVITabBar({
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: TabBar(
        controller: controller,
        indicatorColor: accentColor,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: accentColor,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Documents'),
          Tab(text: 'Steps'),
          Tab(text: 'Track'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — OVERVIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final ServiceModel service;
  final Color accentColor;

  const _OverviewTab({required this.service, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Description card
        _SectionCard(
          title: 'About this Service',
          hindiTitle: 'इस सेवा के बारे में',
          accentColor: accentColor,
          child: Text(
            service.localizedDescription('en'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // At a Glance row
        _SectionCard(
          title: 'At a Glance',
          hindiTitle: 'एक नज़र में',
          accentColor: accentColor,
          child: Row(
            children: [
              Expanded(
                child: _GlanceItem(
                  icon: Icons.schedule_rounded,
                  label: 'Timeline',
                  value: service.estimatedTimeline,
                  color: AppColors.accentBlue,
                ),
              ),
              Expanded(
                child: _GlanceItem(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Fee',
                  value: service.fees,
                  color: AppColors.gold,
                ),
              ),
              Expanded(
                child: _GlanceItem(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: 'Difficulty',
                  value: service.eligibilityCriteria.length <= 2
                      ? 'Easy'
                      : service.eligibilityCriteria.length <= 4
                          ? 'Medium'
                          : 'Complex',
                  color: service.eligibilityCriteria.length <= 2
                      ? AppColors.emeraldLight
                      : service.eligibilityCriteria.length <= 4
                          ? AppColors.gold
                          : AppColors.accentRed,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // Eligibility
        if (service.eligibilityCriteria.isNotEmpty)
          _SectionCard(
            title: 'Who Can Apply',
            hindiTitle: 'कौन आवेदन कर सकता है',
            accentColor: accentColor,
            child: Column(
              children: service.eligibilityCriteria
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded,
                                color: accentColor, size: 13),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // AI Quick Tip
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gold.withValues(alpha: 0.10),
                AppColors.saffron.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.saffron, AppColors.gold]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                    child: Text('💡', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CVI Quick Tip',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep all documents in a dedicated folder. Many offices accept both original and self-attested photocopies. For online applications, scan at 200 DPI minimum.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 340.ms),
      ],
    );
  }
}

class _GlanceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _GlanceItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — DOCUMENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _DocumentsTab extends StatelessWidget {
  final ServiceModel service;
  final Color accentColor;
  final VoidCallback onDownload;

  const _DocumentsTab({
    required this.service,
    required this.accentColor,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final docs = service.requiredDocuments;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Header counts
        Row(
          children: [
            _CountBadge(
              count: docs.where((d) => !d.isOptional).length,
              label: 'Mandatory',
              color: AppColors.accentRed,
            ),
            const SizedBox(width: 10),
            _CountBadge(
              count: docs.where((d) => d.isOptional).length,
              label: 'Optional',
              color: AppColors.textSecondary,
            ),
            const Spacer(),
            // Download button
            GestureDetector(
              onTap: onDownload,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, color: accentColor, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Copy Checklist',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (docs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No specific documents listed.\nCheck the official website for requirements.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...docs.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocumentCard(
                    doc: e.value,
                    index: e.key,
                    accentColor: accentColor,
                  ),
                ),
              ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CountBadge(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$count $label',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DocumentCard extends StatefulWidget {
  final DocumentItem doc;
  final int index;
  final Color accentColor;

  const _DocumentCard({
    required this.doc,
    required this.index,
    required this.accentColor,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _expanded = false;
  bool _isUploading = false;

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

  Future<void> _handleUpload() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      final docType = _mapToDocumentType(widget.doc.name);

      if (!mounted) return;
      await context.read<DocumentVaultProvider>().addDocument(
            imageBytes: bytes,
            documentType: docType.name,
            customName: widget.doc.name,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.doc.name} uploaded successfully!'),
          backgroundColor: AppColors.emeraldLight,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded
                ? widget.accentColor.withValues(alpha: 0.3)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Doc icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.doc.isOptional
                          ? AppColors.textMuted.withValues(alpha: 0.12)
                          : widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: widget.doc.isOptional
                          ? AppColors.textMuted
                          : widget.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doc.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.doc.isOptional
                                ? AppColors.textMuted.withValues(alpha: 0.10)
                                : widget.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.doc.isOptional ? 'Optional' : 'Mandatory',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: widget.doc.isOptional
                                  ? AppColors.textMuted
                                  : widget.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Expanded content
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.surfaceBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doc.description,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                                color: AppColors.surfaceBorder, height: 1),
                            const SizedBox(height: 12),
                            Consumer<DocumentVaultProvider>(
                              builder: (context, vault, child) {
                                final docType =
                                    _mapToDocumentType(widget.doc.name);
                                final exists = vault.hasDocument(docType.name);

                                if (exists) {
                                  return Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.emeraldLight,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Already in Vault',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.emeraldLight,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return InkWell(
                                  onTap: _isUploading ? null : _handleUpload,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: widget.accentColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.accentColor
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: _isUploading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.textPrimary),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cloud_upload_outlined,
                                                  size: 16,
                                                  color: widget.accentColor),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Upload to Vault',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: widget.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 + widget.index * 50))
        .slideY(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: 80 + widget.index * 50));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3 — STEPS
// ═══════════════════════════════════════════════════════════════════════════════

class _StepsTab extends StatelessWidget {
  final ServiceModel service;
  final Color accentColor;
  final int currentStep;
  final ValueChanged<int> onStartStep;
  final VoidCallback onLaunchUrl;

  const _StepsTab({
    required this.service,
    required this.accentColor,
    required this.currentStep,
    required this.onStartStep,
    required this.onLaunchUrl,
  });

  @override
  Widget build(BuildContext context) {
    final steps = service.steps;

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // Progress indicator
            if (currentStep >= 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.25), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          steps.isEmpty ? 0 : (currentStep + 1) / steps.length,
                      backgroundColor: AppColors.surfaceBorder,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Step ${currentStep + 1} of ${steps.length}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (steps.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Visit the official website for step-by-step guidance.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ...steps.asMap().entries.map(
                    (e) => _StepTile(
                      step: e.value,
                      index: e.key,
                      accentColor: accentColor,
                      isDone: e.key < currentStep,
                      isActive: e.key == currentStep,
                      isLast: e.key == steps.length - 1,
                      onTap: () => onStartStep(e.key),
                    ),
                  ),
          ],
        ),

        // Sticky CTA
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.bgDeep],
              ),
            ),
            child: SafeArea(
              top: false,
              child: GestureDetector(
                onTap: onLaunchUrl,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        Color.lerp(accentColor, Colors.black, 0.25)!
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Start Application Online',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final StepItem step;
  final int index;
  final Color accentColor;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final VoidCallback onTap;

  const _StepTile({
    required this.step,
    required this.index,
    required this.accentColor,
    required this.isDone,
    required this.isActive,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
            Column(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? accentColor
                          : isActive
                              ? accentColor.withValues(alpha: 0.15)
                              : AppColors.bgMid,
                      border: Border.all(
                        color: isDone || isActive
                            ? accentColor
                            : AppColors.surfaceBorder,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : Text(
                              '${step.number}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? accentColor
                                    : AppColors.textMuted,
                              ),
                            ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDone
                          ? accentColor.withValues(alpha: 0.5)
                          : AppColors.surfaceBorder,
                    ),
                  ),
                if (isLast) const SizedBox(height: 16),
              ],
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor.withValues(alpha: 0.07)
                        : AppColors.bgMid,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? accentColor.withValues(alpha: 0.3)
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.textPrimary
                              : isDone
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                      if (step.actionUrl != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new_rounded,
                                size: 11, color: accentColor),
                            const SizedBox(width: 4),
                            Text(
                              'Open Link',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 + index * 70)).slideX(
        begin: 0.04, end: 0, delay: Duration(milliseconds: 60 + index * 70));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 4 — TRACK
// ═══════════════════════════════════════════════════════════════════════════════

class _TrackTab extends StatelessWidget {
  final ServiceModel service;
  final Color accentColor;
  final TextEditingController appIdCtrl;
  final bool statusChecked;
  final VoidCallback onCheckStatus;

  const _TrackTab({
    required this.service,
    required this.accentColor,
    required this.appIdCtrl,
    required this.statusChecked,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Application ID field
        _SectionCard(
          title: 'Track Your Application',
          hindiTitle: 'आवेदन की स्थिति',
          accentColor: accentColor,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.tag_rounded,
                        color: AppColors.textMuted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: appIdCtrl,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Application ID',
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onCheckStatus,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, color: accentColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Check Status on Official Site',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 80.ms),

        const SizedBox(height: 14),

        // Status Timeline
        _SectionCard(
          title: 'Application Journey',
          hindiTitle: 'आवेदन की प्रक्रिया',
          accentColor: accentColor,
          child: _StatusTimeline(
            accentColor: accentColor,
            active: statusChecked ? 1 : 0,
          ),
        ).animate().fadeIn(delay: 160.ms),

        const SizedBox(height: 14),

        // Helpline numbers
        _SectionCard(
          title: 'Contact & Support',
          hindiTitle: 'संपर्क करें',
          accentColor: accentColor,
          child: Column(
            children: [
              _ContactRow(
                icon: Icons.phone_rounded,
                label: 'Helpline',
                value: service.helplineNumber,
                color: AppColors.emeraldLight,
                onTap: () async {
                  final uri = Uri.parse('tel:${service.helplineNumber}');
                  await launchUrl(uri);
                },
              ),
              const SizedBox(height: 12),
              _ContactRow(
                icon: Icons.language_rounded,
                label: 'Official Website',
                value: service.officialLink.replaceFirst('https://', ''),
                color: accentColor,
                onTap: () async {
                  final uri = Uri.parse(service.officialLink);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 12),
              _ContactRow(
                icon: Icons.near_me_rounded,
                label: 'Nearest Office',
                value: 'Find on Google Maps',
                color: AppColors.accentBlue,
                onTap: () async {
                  final query = Uri.encodeComponent(
                      '${service.category.label} office near me');
                  await launchUrl(
                      Uri.parse('https://www.google.com/maps/search/$query'),
                      mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: 240.ms),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Color accentColor;
  final int active; // which stage is current (0-indexed)

  static const _stages = [
    ('Submitted', '📤', 'Application received'),
    ('Under Review', '🔍', 'Verification in progress'),
    ('Processing', '⚙️', 'Being processed'),
    ('Completed', '✅', 'Approved & dispatched'),
  ];

  const _StatusTimeline({
    required this.accentColor,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _stages.asMap().entries.map((e) {
        final isDone = e.key < active;
        final isCurrent = e.key == active;
        final (label, emoji, sub) = e.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? accentColor
                      : isCurrent
                          ? accentColor.withValues(alpha: 0.15)
                          : AppColors.bgDark,
                  border: Border.all(
                    color: isDone || isCurrent
                        ? accentColor
                        : AppColors.surfaceBorder,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Center(
                  child:
                      Text(emoji, style: TextStyle(fontSize: isDone ? 16 : 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.textPrimary
                            : isDone
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      sub,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Current',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textMuted)),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted, size: 13),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final String hindiTitle;
  final Color accentColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.hindiTitle,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Stack(
        children: [
          // Top accent line
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.7),
                  Colors.transparent
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hindiTitle,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 10,
                    color: accentColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STICKY BOTTOM BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _StickyBar extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onApplyNow;
  final VoidCallback onAskCVI;

  const _StickyBar({
    required this.accentColor,
    required this.onApplyNow,
    required this.onAskCVI,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border:
            Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Ask CVI
            GestureDetector(
              onTap: onAskCVI,
              child: Container(
                height: 52,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.bgMid,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.saffron.withValues(alpha: 0.3),
                      width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded,
                        color: AppColors.saffron, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      'Ask CVI',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.saffron,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Apply Now
            Expanded(
              child: GestureDetector(
                onTap: onApplyNow,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        Color.lerp(accentColor, AppColors.bgDeep, 0.3)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Apply Now',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '→',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
