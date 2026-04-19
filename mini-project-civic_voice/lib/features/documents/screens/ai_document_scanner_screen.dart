import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/document_scanner_provider.dart';
import '../../../../providers/document_vault_provider.dart';
import '../../../../widgets/cvi_button.dart';
import '../../../../widgets/glass_card.dart';

class AIDocumentScannerScreen extends StatelessWidget {
  const AIDocumentScannerScreen({super.key});

  Future<void> _scanAction(DocumentScannerProvider provider) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      provider.processImage(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentScannerProvider(),
      child: Consumer<DocumentScannerProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                'AI Smart Scanner',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
              actions: [
                if (provider.extractedData != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: provider.clearScan,
                  )
              ],
            ),
            body: SafeArea(
              child: provider.extractedData == null
                  ? _buildUploadState(context, provider)
                  : _buildResultState(context, provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadState(
      BuildContext context, DocumentScannerProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.isScanning) ...[
              const CircularProgressIndicator(color: AppColors.saffron),
              const SizedBox(height: 24),
              Text(
                'Extracting details safely via AI...',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Processing with Amazon Nova Lite...',
                style: GoogleFonts.spaceMono(
                    color: AppColors.textMuted, fontSize: 10),
              ).animate().fadeIn(delay: 600.ms)
            ] else ...[
              if (provider.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Error: ${provider.lastError}',
                    style: GoogleFonts.inter(
                        color: Colors.redAccent, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    size: 80, color: AppColors.accentBlue),
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text(
                'Secure AI Document Scan',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Upload your document and let AI extract the details for your vault.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              CviButton(
                text: 'Scan Document',
                icon: Icons.camera_alt,
                onPressed: () => _scanAction(provider),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultState(
      BuildContext context, DocumentScannerProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.emeraldLight, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Successful',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Document parsed automatically',
                      style: GoogleFonts.inter(
                          color: AppColors.emeraldLight, fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ).animate().slideX(begin: -0.1, end: 0),
          const SizedBox(height: 32),
          if (provider.scannedImageBytes != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  provider.scannedImageBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().fadeIn(),
          const SizedBox(height: 32),
          Text('Extracted Data',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDataRow('Document Type',
                    (provider.documentType ?? 'Unknown').toUpperCase()),
                const Divider(color: AppColors.surfaceBorder, height: 24),
                ...provider.extractedData!.entries.map((e) {
                  return Column(
                    children: [
                      _buildDataRow(e.key.replaceAll('_', ' ').toUpperCase(),
                          e.value.toString()),
                      if (e.key != provider.extractedData!.entries.last.key)
                        const Divider(
                            color: AppColors.surfaceBorder, height: 24),
                    ],
                  );
                }),
              ],
            ),
          ).animate().slideY(begin: 0.1, end: 0, delay: 200.ms),
          const SizedBox(height: 32),
          CviButton(
            text: 'Save to Vault',
            variant: CviButtonVariant.gold,
            onPressed: () async {
              final success = await provider.saveToVault();
              if (context.mounted) {
                final errorMsg =
                    provider.lastError ?? 'Failed to save to Vault.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'Successfully saved to Vault!' : errorMsg),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  context.read<DocumentVaultProvider>().loadDocuments();
                  Navigator.pop(context);
                }
              }
            },
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 13))),
        const SizedBox(width: 8),
        Text(value,
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
