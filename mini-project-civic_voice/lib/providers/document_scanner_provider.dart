import 'package:flutter/foundation.dart';
import '../core/services/document_ai_service.dart';
import '../core/services/document_vault_service.dart';

class DocumentScannerProvider with ChangeNotifier {
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Uint8List? _scannedImageBytes;
  Uint8List? get scannedImageBytes => _scannedImageBytes;

  Map<String, dynamic>? _extractedData;
  Map<String, dynamic>? get extractedData => _extractedData;

  String? _documentType;
  String? get documentType => _documentType;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> processImage(Uint8List imageBytes,
      {String docType = 'detect'}) async {
    _isScanning = true;
    _scannedImageBytes = imageBytes;
    _extractedData = null;
    _lastError = null;
    _documentType = docType == 'detect' ? null : docType;
    notifyListeners();

    try {
      final result = await DocumentAIService.extractFromDocumentBytes(
        imageBytes: _scannedImageBytes!,
        documentType: docType,
      );

      if (result.containsKey('error')) {
        _lastError = result['error'].toString();
      } else {
        _extractedData = Map<String, dynamic>.from(result);

        // If we were in detection mode, capture the AI recognized type
        if (docType == 'detect' &&
            _extractedData?.containsKey('document_type') == true) {
          final rawType =
              _extractedData!['document_type'].toString().toLowerCase();
          // Map to standard vault types
          if (rawType.contains('aadhaar')) {
            _documentType = 'aadhaar';
          } else if (rawType.contains('pan'))
            _documentType = 'pan';
          else if (rawType.contains('passport'))
            _documentType = 'passport';
          else if (rawType.contains('voter'))
            _documentType = 'voterID';
          else if (rawType.contains('driving') || rawType.contains('license'))
            _documentType = 'drivingLicense';
          else if (rawType.contains('passbook') || rawType.contains('bank'))
            _documentType = 'bankPassbook';
          else if (rawType.contains('income'))
            _documentType = 'incomeCertificate';
          else if (rawType.contains('ration'))
            _documentType = 'rationCard';
          else
            _documentType = rawType;
        }

        // Remove internal technical keys from UI display if they exist
        _extractedData?.remove('confidence');
        _extractedData?.remove('raw_text');
        _extractedData?.remove('document_type');
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> saveToVault() async {
    if (_scannedImageBytes == null) {
      _lastError = 'No image to save.';
      notifyListeners();
      return false;
    }
    if (_documentType == null) {
      _lastError = 'Document type not recognized. Please try scanning again.';
      notifyListeners();
      return false;
    }

    final result = await DocumentVaultService.uploadDocument(
      imageBytes: _scannedImageBytes!,
      documentType: _documentType!,
    );

    if (result['success'] != true) {
      _lastError = result['error'] ?? 'Upload failed.';
      notifyListeners();
      return false;
    }

    return true;
  }

  void clearScan() {
    _scannedImageBytes = null;
    _extractedData = null;
    _documentType = null;
    _lastError = null;
    notifyListeners();
  }
}
