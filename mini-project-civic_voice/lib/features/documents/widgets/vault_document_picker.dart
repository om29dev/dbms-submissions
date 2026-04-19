import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/document_vault_provider.dart';
import '../../../core/services/document_vault_service.dart';
import '../../../models/cvi_document_model.dart';
import '../../../providers/notification_provider.dart';

class VaultDocumentPicker extends StatefulWidget {
  final List<DocumentType>? requiredTypes;
  final List<DocumentType>? optionalTypes;

  const VaultDocumentPicker({
    super.key,
    this.requiredTypes,
    this.optionalTypes,
  });

  @override
  State<VaultDocumentPicker> createState() => _VaultDocumentPickerState();
}

class _VaultDocumentPickerState extends State<VaultDocumentPicker> {
  bool _isLoadingUrl = false;
  String? _loadingDocId;

  Future<void> _viewDocument(
      String filePath, String docId, String type, String? fileName) async {
    setState(() {
      _isLoadingUrl = true;
      _loadingDocId = docId;
    });

    try {
      final url = await DocumentVaultService.getDocumentSignedUrl(filePath);
      if (url != null) {
        if (mounted) {
          // Show embedded viewer for images (standard in this app)
          showDialog(
            context: context,
            builder: (ctx) => _DocumentViewer(
              url: url,
              title: _formatDocString(type),
              storageKey: filePath,
              fileName: fileName ?? '${_formatDocString(type)}.jpg',
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get document access URL.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUrl = false;
          _loadingDocId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<DocumentVaultProvider>();
    final allDocs = vault.documents;

    // Intelligent Filtering Logic
    final List<Map<String, dynamic>> filteredDocs = [];
    final List<Map<String, dynamic>> otherDocs = [];

    final targetTypes = [
      ...?(widget.requiredTypes?.map((e) => e.name)),
      ...?(widget.optionalTypes?.map((e) => e.name)),
    ];

    for (var doc in allDocs) {
      final type = doc['document_type'] as String?;
      if (targetTypes.contains(type)) {
        filteredDocs.add(doc);
      } else {
        otherDocs.add(doc);
      }
    }

    // Display relevant ones first
    final docs = [...filteredDocs, ...otherDocs];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_shared_rounded,
                  color: AppColors.gold, size: 24),
              const SizedBox(width: 10),
              Text(
                'Smart Vault Access',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.requiredTypes != null
                ? 'Showing relevant documents for this form first.'
                : 'Quickly view your stored documents while filling out this form.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (vault.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.saffron),
              ),
            )
          else if (docs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Your vault is empty.\nUpload documents first.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final type = doc['document_type'] as String?;
                  final isRequired =
                      widget.requiredTypes?.any((e) => e.name == type) ?? false;
                  final isCurrentlyLoading =
                      _isLoadingUrl && _loadingDocId == doc['id'];

                  return GestureDetector(
                    onTap: () {
                      if (!isCurrentlyLoading && doc['file_path'] != null) {
                        _viewDocument(doc['file_path'], doc['id'],
                            type ?? 'other', doc['name']);
                      }
                    },
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: AppColors.bgMid,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRequired
                              ? AppColors.saffron
                              : AppColors.surfaceBorder,
                          width: isRequired ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconForDocType(type),
                                    color: isRequired
                                        ? AppColors.saffron
                                        : AppColors.emeraldLight,
                                    size: 42,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _formatDocString(type),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isRequired ? 'Required ★' : 'Tap to view',
                                    style: GoogleFonts.poppins(
                                      color: isRequired
                                          ? AppColors.saffron
                                          : AppColors.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isCurrentlyLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.bgDeep.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.saffron,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
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

  IconData _getIconForDocType(String? type) {
    if (type == null) return Icons.description_rounded;
    final lower = type.toLowerCase();
    if (lower.contains('aadhaar')) return Icons.fingerprint_rounded;
    if (lower.contains('pan')) return Icons.credit_card_rounded;
    if (lower.contains('passport')) return Icons.airplanemode_active_rounded;
    if (lower.contains('driving')) return Icons.directions_car_rounded;
    if (lower.contains('voter')) return Icons.how_to_vote_rounded;
    if (lower.contains('bank')) return Icons.account_balance_rounded;
    if (lower.contains('photo')) return Icons.portrait_rounded;
    return Icons.description_rounded;
  }

  String _formatDocString(String? key) {
    if (key == null) return 'Document';
    switch (key) {
      case 'aadhaar':
        return 'Aadhaar Card';
      case 'pan':
        return 'PAN Card';
      case 'passport':
        return 'Passport';
      case 'voterID':
        return 'Voter ID';
      case 'drivingLicense':
        return 'Driving License';
      case 'bankPassbook':
        return 'Bank Passbook';
      case 'photo':
        return 'Photograph';
      case 'incomeCertificate':
        return 'Income Cert';
      default:
        return key.substring(0, 1).toUpperCase() + key.substring(1);
    }
  }
}

class _DocumentViewer extends StatefulWidget {
  final String url;
  final String title;
  final String storageKey;
  final String fileName;

  const _DocumentViewer({
    required this.url,
    required this.title,
    required this.storageKey,
    required this.fileName,
  });

  @override
  State<_DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<_DocumentViewer> {
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);

    try {
      final result = await DocumentVaultService.downloadDocument(
        storageKey: widget.storageKey,
        fileName: widget.fileName,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Trigger system notification via Provider
          Provider.of<NotificationProvider>(context, listen: false)
              .addNotification(
            title: 'Download Complete',
            body: '${widget.fileName} has been saved to your Downloads folder.',
            type: NotificationType.system,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Downloaded successfully to Downloads/${widget.fileName}'),
              backgroundColor: AppColors.emeraldLight,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${result['error']}'),
              backgroundColor: AppColors.semanticError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: AppColors.bgDark,
            title: Text(widget.title, style: GoogleFonts.poppins(fontSize: 14)),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_isDownloading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.saffron,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.file_download_rounded,
                      color: AppColors.gold),
                  tooltip: 'Download to Device',
                  onPressed: _handleDownload,
                ),
            ],
          ),
          Flexible(
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Image.network(
                widget.url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.saffron));
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 16),
                        Text('Could not load image preview',
                            style: GoogleFonts.poppins(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
