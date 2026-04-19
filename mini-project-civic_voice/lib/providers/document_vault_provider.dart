// ═══════════════════════════════════════════════════════════════════════════════
// DOCUMENT VAULT PROVIDER — AWS Amplify-backed state management
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

import '../core/services/document_vault_service.dart';
import '../models/cvi_document_model.dart';

class DocumentVaultProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _documents = [];
  Map<String, dynamic>? _extractedData;
  bool _isExtracting = false;
  String? _extractionStatus;
  bool _isLoading = false;

  // ─── Getters ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get documents => List.unmodifiable(_documents);
  Map<String, dynamic>? get extractedData => _extractedData;
  bool get isExtracting => _isExtracting;
  String? get extractionStatus => _extractionStatus;
  bool get isLoading => _isLoading;

  int get verifiedCount =>
      _documents.where((d) => d['is_verified'] == true).length;

  int get totalCount => _documents.length;

  /// The 8 "core" document types to track progress against.
  static const coreDocumentTypes = [
    'aadhaar',
    'pan',
    'passport',
    'voterID',
    'drivingLicense',
    'bankPassbook',
    'photo',
    'incomeCertificate',
  ];

  int get coreUploaded => coreDocumentTypes.where((t) => hasDocument(t)).length;

  double get completionPercent =>
      coreDocumentTypes.isEmpty ? 0.0 : coreUploaded / coreDocumentTypes.length;

  bool hasDocument(String documentType) =>
      _documents.any((d) => d['document_type'] == documentType);

  Map<String, dynamic>? getDocument(String documentType) {
    try {
      return _documents.firstWhere((d) => d['document_type'] == documentType);
    } catch (_) {
      return null;
    }
  }

  /// Check if a specific DocumentType enum is uploaded.
  bool hasDocumentType(DocumentType type) => hasDocument(type.name);

  // ─── Extracted data field access ────────────────────────────────────────────

  int get extractedFieldCount {
    if (_extractedData == null) return 0;
    int count = 0;
    for (final entry in _extractedData!.entries) {
      if (_isDataField(entry.key) &&
          entry.value != null &&
          entry.value.toString().isNotEmpty &&
          entry.value.toString() != 'null') {
        count++;
      }
    }
    return count;
  }

  bool _isDataField(String key) {
    const meta = {'id', 'user_id', 'created_at', 'updated_at'};
    return !meta.contains(key);
  }

  String? getFieldValue(String fieldKey) {
    if (_extractedData == null) return null;
    final val = _extractedData![fieldKey];
    if (val == null || val.toString().isEmpty || val.toString() == 'null') {
      return null;
    }
    return val.toString();
  }

  // ─── Load documents from AWS Amplify on startup ──────────────────────────

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = await DocumentVaultService.getUserDocuments();
      _extractedData = await DocumentVaultService.getUserExtractedData();
    } catch (e) {
      debugPrint('DocumentVault: Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Upload document → AWS S3 → AI Extraction → Merge ────────────────────

  Future<void> addDocument({
    required Uint8List imageBytes,
    required String documentType,
    String? customName,
    String? fileName, // keep for compatibility but optional now
  }) async {
    _isExtracting = true;
    _extractionStatus = 'AI is reading your document...';
    notifyListeners();

    try {
      final result = await DocumentVaultService.uploadDocument(
        imageBytes: imageBytes,
        documentType: documentType,
        customName: customName,
      );

      if (result['success'] == true) {
        final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;

        if (confidence > 0.6) {
          _extractionStatus = '✓ Document data extracted successfully!';
        } else {
          _extractionStatus =
              '⚠️ Low confidence extraction. Please ensure image is clear and try again.';
          debugPrint(
              'DocumentVault: Low confidence ($confidence). AI Map: ${result['extractedData']}');
        }

        // RELOAD data even if low confidence so user can see what WAS found
        _documents = await DocumentVaultService.getUserDocuments();
        _extractedData = await DocumentVaultService.getUserExtractedData();
      } else {
        final error = result['error'] ?? 'Unknown error';
        _extractionStatus = 'Upload failed: $error';
        debugPrint('DocumentVault: Upload failed - $error');
      }
    } catch (e) {
      _extractionStatus =
          'Error: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e.toString()}';
      debugPrint('DocumentVault: Upload error: $e');
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  // ─── Delete document ──────────────────────────────────────────────────────

  Future<bool> removeDocument(String documentId, String filePath) async {
    final result =
        await DocumentVaultService.deleteDocument(documentId, filePath);
    if (result['success'] == true) {
      _documents.removeWhere((d) => d['id'] == documentId);
      notifyListeners();
      return true;
    } else {
      _extractionStatus = 'Delete failed: ${result['error']}';
      notifyListeners();
      return false;
    }
  }

  // ─── Clear extraction status ──────────────────────────────────────────────

  void clearStatus() {
    _extractionStatus = null;
    notifyListeners();
  }
}
