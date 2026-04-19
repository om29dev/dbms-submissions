// DOCUMENT VAULT SCREEN — AWS-backed upload + AI extraction UI

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/document_vault_provider.dart';
import '../../../core/services/document_vault_service.dart';

/// The 8 document slot definitions for the vault grid.
const _docCategories = [
  (
    'Identity Documents',
    'पहचान पत्र',
    '🪪',
    [
      _DocSlot(
          'aadhaar', 'Aadhaar Card', 'आधार कार्ड', '🪪', Color(0xFF2E7D32)),
      _DocSlot('pan', 'PAN Card', 'पैन कार्ड', '💳', Color(0xFF1565C0)),
      _DocSlot('passport', 'Passport', 'पासपोर्ट', '📘', Color(0xFF6A1B9A)),
      _DocSlot('voterID', 'Voter ID', 'मतदाता पहचान', '🗳️', Color(0xFFE65100)),
    ]
  ),
  (
    'Legal & Financial',
    'कानूनी और वित्तीय',
    '🏦',
    [
      _DocSlot('drivingLicense', 'Driving License', 'वाहन परवाना', '🚗',
          Color(0xFF00838F)),
      _DocSlot('bankPassbook', 'Bank Passbook', 'बैंक पासबुक', '🏦',
          Color(0xFF4527A0)),
      _DocSlot('incomeCertificate', 'Income Certificate', 'आय प्रमाण पत्र',
          '📄', Color(0xFF558B2F)),
    ]
  ),
  (
    'Personal',
    'व्यक्तिगत',
    '📷',
    [
      _DocSlot(
          'photo', 'Passport Photo', 'पासपोर्ट फोटो', '📷', Color(0xFFC62828)),
    ]
  ),
];

class _DocSlot {
  final String type;
  final String label;
  final String labelHindi;
  final String emoji;
  final Color color;
  const _DocSlot(
      this.type, this.label, this.labelHindi, this.emoji, this.color);
}

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});
  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    // Load documents from AWS Amplify on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentVaultProvider>().loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentVaultProvider>(
      builder: (context, vault, _) => Scaffold(
        backgroundColor: const Color(0xFF0D0B07),
        body: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildHeader(vault),
                  const SizedBox(height: 20),
                  _buildProgressBar(vault),
                  const SizedBox(height: 16),
                  if (vault.extractionStatus != null) ...[
                    _buildExtractionStatus(vault),
                    const SizedBox(height: 16),
                  ],
                  _buildPrivacyBanner(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  ..._buildGroupedDocumentList(vault),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0B07),
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '🔒 Document Vault',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(DocumentVaultProvider vault) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'दस्तावेज़ तिजोरी',
          style: GoogleFonts.outfit(
            color: const Color(0xFFD4930A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload once — AI fills all your forms forever',
          style: GoogleFonts.outfit(
            color: const Color(0xFFB8A898),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${vault.totalCount} documents · ${vault.extractedFieldCount} fields extracted',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  // ─── Progress Bar ─────────────────────────────────────────────────────────

  Widget _buildProgressBar(DocumentVaultProvider vault) {
    final pct = vault.completionPercent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A1F10), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vault Progress',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              Text(
                '${vault.coreUploaded}/${DocumentVaultProvider.coreDocumentTypes.length}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFD4930A),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: const Color(0xFF2A1F10),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 0.75 ? const Color(0xFF2E7D32) : const Color(0xFFFF6B1A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pct >= 1.0
                ? '✓ Vault complete — AI can fill any form instantly!'
                : pct >= 0.5
                    ? 'Good progress! Upload more for better auto-fill.'
                    : 'Upload documents to enable AI form filling',
            style: GoogleFonts.outfit(
              color: pct >= 1.0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFB8A898),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  // ─── Privacy Banner ───────────────────────────────────────────────────────

  Widget _buildPrivacyBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A0A),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '🔐 Your documents are encrypted and stored securely in your private account. Only you can access them.',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF81C784), fontSize: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1814),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A1F10)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.outfit(color: Colors.white),
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search your vault...',
          hintStyle: GoogleFonts.outfit(color: Colors.white38),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFFD4930A)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ─── Grouped Document List ────────────────────────────────────────────────

  Widget _buildCategoryHeader(String title, String hindi, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              color: const Color(0xFFD4930A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hindi,
            style: GoogleFonts.notoSansDevanagari(
              color: Colors.white24,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedDocumentList(DocumentVaultProvider vault) {
    final allDocs = vault.documents;
    final displayedIds = <String>{};
    final widgets = <Widget>[];

    // Core Categories
    for (final category in _docCategories) {
      final (title, titleHindi, emoji, slots) = category;

      final filteredSlots = slots.where((slot) {
        if (_searchQuery.isEmpty) return true;
        return slot.label.toLowerCase().contains(_searchQuery) ||
            slot.labelHindi.contains(_searchQuery);
      }).toList();

      if (filteredSlots.isEmpty && _searchQuery.isNotEmpty) continue;

      final categoryChildren = <Widget>[];

      for (final slot in slots) {
        // Find ALL documents of this type
        final matchingDocs =
            allDocs.where((d) => d['document_type'] == slot.type).toList();

        if (matchingDocs.isEmpty) {
          // Show empty slot placeholder if not searching
          if (_searchQuery.isEmpty ||
              slot.label.toLowerCase().contains(_searchQuery) ||
              slot.labelHindi.contains(_searchQuery)) {
            categoryChildren.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DocumentSlotCard(
                  slot: slot,
                  isUploaded: false,
                  isVerified: false,
                  confidence: 0,
                  doc: null,
                  isExtracting: vault.isExtracting,
                  onTap: () => _showUploadSheet(slot),
                ),
              ),
            );
          }
        } else {
          for (final doc in matchingDocs) {
            displayedIds.add(doc['id'].toString());
            categoryChildren.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DocumentSlotCard(
                  slot: slot,
                  isUploaded: true,
                  isVerified: doc['is_verified'] == true,
                  confidence:
                      (doc['confidence_score'] as num?)?.toDouble() ?? 0.0,
                  doc: doc,
                  isExtracting: vault.isExtracting,
                  onTap: () => _showExtractedDataPreview(vault, slot, doc: doc),
                  onDelete: () => _confirmDelete(
                      vault, doc['id'].toString(), doc['file_path'] as String),
                ),
              ),
            );
          }
        }
      }

      if (categoryChildren.isNotEmpty) {
        widgets.add(_buildCategoryHeader(title, titleHindi, emoji));
        widgets.addAll(categoryChildren);
      }
    }

    // Other Documents (Misc Section)
    final otherDocs = allDocs
        .where((d) => !displayedIds.contains(d['id'].toString()))
        .toList();

    if (otherDocs.isNotEmpty) {
      final filteredOther = otherDocs.where((d) {
        if (_searchQuery.isEmpty) return true;
        final name = (d['name'] as String? ?? '').toLowerCase();
        return name.contains(_searchQuery);
      }).toList();

      if (filteredOther.isNotEmpty) {
        widgets.add(
            _buildCategoryHeader('Other Documents', 'अन्य दस्तावेज़', '📂'));

        for (final doc in filteredOther) {
          final slot = _DocSlot(
            'other',
            doc['name'] ?? 'Document',
            'दस्तावेज़',
            '📄',
            const Color(0xFF643D2A),
          );

          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DocumentSlotCard(
                slot: slot,
                isUploaded: true,
                isVerified: doc['is_verified'] == true,
                confidence:
                    (doc['confidence_score'] as num?)?.toDouble() ?? 0.0,
                doc: doc,
                isExtracting: vault.isExtracting,
                onTap: () => _showExtractedDataPreview(vault, slot, doc: doc),
                onDelete: () => _confirmDelete(
                    vault, doc['id'].toString(), doc['file_path'] as String),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  // ─── Extraction Status ────────────────────────────────────────────────────

  Widget _buildExtractionStatus(DocumentVaultProvider vault) {
    final isSuccess = vault.extractionStatus?.startsWith('✓') ?? false;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFF0A1A0A) : const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? const Color(0xFF2E7D32).withValues(alpha: 0.4)
              : const Color(0xFFE65100).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          if (vault.isExtracting)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF6B1A),
              ),
            )
          else
            Icon(
              isSuccess ? Icons.check_circle : Icons.warning_amber_rounded,
              color:
                  isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF6B1A),
              size: 20,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              vault.extractionStatus ?? '',
              style: GoogleFonts.outfit(
                color: isSuccess ? const Color(0xFF81C784) : Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          if (!vault.isExtracting)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white38, size: 18),
              onPressed: vault.clearStatus,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05);
  }

  // ─── Upload Bottom Sheet ──────────────────────────────────────────────────

  void _showUploadSheet(_DocSlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1208),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Text(slot.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.label,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      slot.labelHindi,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4930A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upload options
            _UploadOption(
              icon: Icons.camera_alt_rounded,
              label: '📷 Take Photo',
              subtitle: 'Capture document with camera',
              onTap: () {
                Navigator.pop(context);
                _capturePhoto(slot.type);
              },
            ),
            const SizedBox(height: 10),
            _UploadOption(
              icon: Icons.photo_library_rounded,
              label: '🖼️ From Gallery',
              subtitle: 'Select from saved photos',
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(slot.type);
              },
            ),
            const SizedBox(height: 10),
            _UploadOption(
              icon: Icons.picture_as_pdf_rounded,
              label: '📄 Upload PDF',
              subtitle: 'Select PDF document',
              onTap: () {
                Navigator.pop(context);
                _pickPDF(slot.type);
              },
            ),
            const SizedBox(height: 16),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1A0A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded,
                      color: Color(0xFF4CAF50), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stored securely in your encrypted account',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF81C784), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Capture / Pick methods ───────────────────────────────────────────────

  Future<void> _capturePhoto(String docType) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1500,
      maxHeight: 1500,
    );
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      _processUpload(bytes, photo.name, docType);
    }
  }

  Future<void> _pickFromGallery(String docType) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1500,
      maxHeight: 1500,
    );
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      _processUpload(bytes, photo.name, docType);
    }
  }

  Future<void> _pickPDF(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      _processUpload(
        result.files.single.bytes!,
        result.files.single.name,
        docType,
      );
    }
  }

  void _processUpload(Uint8List bytes, String fileName, String docType) {
    context.read<DocumentVaultProvider>().addDocument(
          imageBytes: bytes,
          documentType: docType,
          fileName: fileName,
        );
  }

  // ─── Extracted Data Preview ───────────────────────────────────────────────

  void _showExtractedDataPreview(DocumentVaultProvider vault, _DocSlot slot,
      {Map<String, dynamic>? doc}) {
    // Priority 1: Specific document extraction if provided
    // Priority 2: Full vault merged data
    Map<String, dynamic> data = {};

    if (doc != null && doc['extracted_text'] != null) {
      try {
        data = SafeDecode.decode(doc['extracted_text'] as String);
      } catch (_) {}
    }

    if (data.isEmpty) {
      data = vault.extractedData ?? {};
    }

    if (data.isEmpty) return;

    // Show relevant fields based on document type
    List<Map<String, String>> fieldsToShow = _getFieldsForDocType(slot.type);

    // For 'other' or if generic extracted data exists, expand fields
    if (slot.type == 'other' || data.length > fieldsToShow.length) {
      final existingKeys = fieldsToShow.map((f) => f['key']).toSet();
      final extraFields = <Map<String, String>>[];

      // Filter out internal keys
      final ignore = {
        'confidence',
        'confidence_score',
        'document_type',
        'raw_text',
        'id',
        'user_id'
      };

      data.forEach((key, value) {
        if (!existingKeys.contains(key) &&
            !ignore.contains(key) &&
            value != null) {
          // Format keys better (e.g. 'full_name' -> 'Full Name')
          final label = key
              .split('_')
              .map((s) =>
                  s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s)
              .join(' ');
          extraFields.add({'key': key, 'label': label});
        }
      });
      fieldsToShow = [...fieldsToShow, ...extraFields];
    }

    String formatValue(dynamic val, String key) {
      if (val == null || val.toString().isEmpty || val.toString() == 'null') {
        return 'Not found';
      }
      final s = val.toString();
      // Simple date formatting check
      if (key.contains('date') || s.contains('T')) {
        try {
          final dt = DateTime.tryParse(s);
          if (dt != null) {
            return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
          }
        } catch (_) {}
      }
      return s;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1208),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                children: [
                  Text(slot.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${doc?['name'] ?? slot.label} — Extracted Data',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Smart Insight Section
              _buildSmartInsight(slot, data),
              const SizedBox(height: 24),
              ...fieldsToShow.map((field) {
                final rawValue = data[field['key']];
                final value = formatValue(rawValue, field['key'] ?? '');
                final hasValue = value != 'Not found';

                // For 'other' documents, hide 'Not found' fields to reduce clutter
                if (!hasValue && slot.type == 'other') {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        hasValue
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: hasValue
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF666666),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              field['label'] as String,
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              value,
                              style: GoogleFonts.outfit(
                                color: hasValue
                                    ? const Color(0xFFD4930A)
                                    : const Color(0xFF666666),
                                fontSize: 14,
                                fontWeight: hasValue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              // View Document Button
              ElevatedButton.icon(
                onPressed: () {
                  final doc = vault.getDocument(slot.type);
                  if (doc != null && doc['file_path'] != null) {
                    _showDocumentViewer(doc['file_path'] as String, slot.label);
                  }
                },
                icon: const Icon(Icons.remove_red_eye_rounded, size: 20),
                label: Text(
                  'View Original Document',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4930A),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Document Viewer (Full Screen) ────────────────────────────────────────

  void _showDocumentViewer(String storageKey, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
          ),
        ),
        body: Center(
          child: FutureBuilder<String?>(
            future: DocumentVaultService.getDocumentSignedUrl(storageKey),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                    color: Color(0xFFD4930A));
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load document',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                  ],
                );
              }

              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  snapshot.data!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFD4930A)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getFieldsForDocType(String docType) {
    switch (docType) {
      case 'aadhaar':
        return [
          {'key': 'full_name', 'label': 'Full Name'},
          {'key': 'date_of_birth', 'label': 'Date of Birth'},
          {'key': 'gender', 'label': 'Gender'},
          {'key': 'aadhaar_number', 'label': 'Aadhaar Number'},
          {'key': 'address_line1', 'label': 'Address'},
          {'key': 'district', 'label': 'District'},
          {'key': 'state', 'label': 'State'},
          {'key': 'pincode', 'label': 'PIN Code'},
        ];
      case 'pan':
        return [
          {'key': 'full_name', 'label': 'Full Name'},
          {'key': 'father_name', 'label': 'Father\'s Name'},
          {'key': 'date_of_birth', 'label': 'Date of Birth'},
          {'key': 'pan_number', 'label': 'PAN Number'},
        ];
      case 'passport':
        return [
          {'key': 'full_name', 'label': 'Full Name'},
          {'key': 'passport_number', 'label': 'Passport Number'},
          {'key': 'date_of_birth', 'label': 'Date of Birth'},
          {'key': 'father_name', 'label': 'Father\'s Name'},
          {'key': 'mother_name', 'label': 'Mother\'s Name'},
          {'key': 'address_line1', 'label': 'Address'},
        ];
      case 'bankPassbook':
        return [
          {'key': 'full_name', 'label': 'Account Holder'},
          {'key': 'account_number', 'label': 'Account Number'},
          {'key': 'bank_name', 'label': 'Bank Name'},
          {'key': 'branch_name', 'label': 'Branch'},
          {'key': 'ifsc_code', 'label': 'IFSC Code'},
        ];
      default:
        return [
          {'key': 'full_name', 'label': 'Full Name'},
          {'key': 'date_of_birth', 'label': 'Date of Birth'},
          {'key': 'address_line1', 'label': 'Address'},
          {'key': 'state', 'label': 'State'},
        ];
    }
  }

  Widget _buildSmartInsight(_DocSlot slot, Map<String, dynamic> data) {
    String insight = '';
    final name = data['full_name'] ?? 'Citizen';
    final type = slot.type;

    if (type == 'aadhaar') {
      insight =
          'AI Insight: $name, this Aadhaar is verified. It can be used for most government subsidies and address verification.';
    } else if (type == 'pan') {
      insight =
          'AI Insight: This PAN card is ready for tax filing or opening a bank account. Make sure it is linked with Aadhaar.';
    } else if (type == 'bankPassbook') {
      insight =
          'AI Insight: Account linked at ${data['bank_name'] ?? 'your bank'}. Use this for Direct Benefit Transfer (DBT) schemes.';
    } else {
      insight =
          'AI Insight: Document processed. The data extracted can assist you in auto-filling many civic forms.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4930A).withValues(alpha: 0.1),
            const Color(0xFFFF6B1A).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFD4930A).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFD4930A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: GoogleFonts.outfit(
                color: const Color(0xFFE0D0B0),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Delete Confirmation ──────────────────────────────────────────────────

  void _confirmDelete(
      DocumentVaultProvider vault, String docId, String filePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1208),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Document?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'This will permanently remove this document from your vault.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await vault.removeDocument(docId, filePath);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Document deleted successfully'
                        : 'Failed to delete document'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete',
                style: GoogleFonts.outfit(color: const Color(0xFFC62828))),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOCUMENT SLOT CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _DocumentSlotCard extends StatelessWidget {
  final _DocSlot slot;
  final bool isUploaded;
  final bool isVerified;
  final double confidence;
  final Map<String, dynamic>? doc;
  final bool isExtracting;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _DocumentSlotCard({
    required this.slot,
    required this.isUploaded,
    required this.isVerified,
    required this.confidence,
    required this.doc,
    required this.isExtracting,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1208),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isVerified
                ? const Color(0xFF2E7D32).withValues(alpha: 0.4)
                : isUploaded
                    ? const Color(0xFFD4930A).withValues(alpha: 0.3)
                    : const Color(0xFF2A1F10),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (doc?['document_type'] == 'other'
                        ? const Color(0xFF666666)
                        : slot.color)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(slot.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),

            // Name + Hindi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc?['name'] ?? slot.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc?['document_type'] == 'other'
                        ? 'Uncategorized'
                        : slot.labelHindi,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFB8A898),
                      fontSize: 12,
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${(confidence * 100).toInt()}% confidence',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4930A),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status badge & Delete button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(),
                if (isUploaded && onDelete != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFC62828),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (isExtracting && !isUploaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B1A).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Color(0xFFFF6B1A)),
            ),
            const SizedBox(width: 6),
            Text(
              'AI reading...',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF6B1A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '✓ Verified',
          style: GoogleFonts.outfit(
            color: const Color(0xFF4CAF50),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (isUploaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFD4930A).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Uploaded',
          style: GoogleFonts.outfit(
            color: const Color(0xFFD4930A),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Not uploaded',
        style: GoogleFonts.outfit(
          color: const Color(0xFF888888),
          fontSize: 11,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// UPLOAD OPTION TILE
// ═══════════════════════════════════════════════════════════════════════════════

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0B07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A1F10)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF6B1A), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(subtitle,
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFB8A898), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
