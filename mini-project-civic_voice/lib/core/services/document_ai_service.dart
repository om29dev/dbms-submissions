// ═══════════════════════════════════════════════════════════════════════════════
// DOCUMENT AI SERVICE — Gemini Vision API for document data extraction
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'aws_bedrock_service.dart';
import '../../models/cvi_document_model.dart';

class DocumentAIService {
  // ────────────────────────────────────────────────────────────────────────────
  // EXTRACT FROM BYTES (Main entry point)
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> extractFromDocumentBytes({
    required Uint8List imageBytes,
    required String documentType,
  }) async {
    return _extractFromImage(
      imageBytes: imageBytes,
      documentType: documentType,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GEMINI EXTRACTION LOGIC
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _extractFromImage({
    required Uint8List imageBytes,
    required String documentType,
  }) async {
    try {
      // Step 1: Compress image if too large (Nova Lite handles large images well, but SigV4 payload has limits)
      Uint8List compressed = imageBytes;
      if (imageBytes.length > 1500000) {
        final result = await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: 85,
          minWidth: 1500,
          minHeight: 1500,
        );
        compressed = result;
      }

      // Step 2: Build prompts
      final systemPrompt = _buildSystemPrompt();
      final userPrompt = _buildUserPrompt(documentType);

      debugPrint(
          'DocumentAI: Sending request to Bedrock (Amazon Nova Lite) for $documentType...');

      final parsed = await AWSBedrockService.extractWithVision(
        systemPrompt: systemPrompt,
        prompt: userPrompt,
        imageBytes: compressed,
      );

      // Robust confidence check
      if (parsed['confidence'] == null && parsed['confidence_score'] != null) {
        parsed['confidence'] = parsed['confidence_score'];
      }

      debugPrint('Extraction success: $parsed');
      return parsed;
    } catch (e) {
      debugPrint('Extraction exception: $e');
      return {
        'error': e.toString(),
        'confidence': 0.0,
      };
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // EXTRACTION PROMPTS
  // ────────────────────────────────────────────────────────────────────────────

  static String _buildSystemPrompt() {
    return '''
You are a world-class Indian legal document OCR assistant.
Extract data from images into strictly valid raw JSON.
RULES:
1. Return ONLY strictly valid raw JSON. No markdown, no preambles, no explanation.
2. If a field is missing, return null.
3. Dates: Use DD/MM/YYYY format.
4. Confidence: Add a "confidence" field (0.0 to 1.0) based on OCR readability.
''';
  }

  static String _buildUserPrompt(String documentType) {
    const base = 'Examine this image. It is an Indian Government document. '
        'Extract all visible fields and populate the following JSON structure. '
        'IMPORTANT: Do not return the dots (...) - replace them with the actual extracted text or null. '
        'Mask Aadhaar and Bank accounts so only last 4 digits are visible. '
        'Analyze carefully and ensure the "confidence" is accurate.';

    switch (documentType) {
      case 'aadhaar':
        return '$base\n'
            '{"full_name":"...", "full_name_hindi":"...", "date_of_birth":"...", "gender":"...", "aadhaar_number":"...", "address_line1":"...", "district":"...", "state":"...", "pincode":"...", "confidence":...}';

      case 'pan':
        return '$base\n'
            '{"full_name":"...", "father_name":"...", "date_of_birth":"...", "pan_number":"...", "confidence":...}';

      case 'passport':
        return '$base\n'
            '{"full_name":"...", "passport_number":"...", "date_of_birth":"...", "date_of_expiry":"...", "place_of_birth":"...", "father_name":"...", "mother_name":"...", "spouse_name":"...", "address_line1":"...", "pincode":"...", "confidence":...}';

      case 'voter_id':
      case 'voterID':
        return '$base\n'
            '{"full_name":"...", "father_name":"...", "date_of_birth":"...", "gender":"...", "voter_id_number":"...", "district":"...", "state":"...", "confidence":...}';

      case 'driving_license':
      case 'drivingLicense':
        return '$base\n'
            '{"full_name":"...", "date_of_birth":"...", "driving_license_number":"...", "blood_group":"...", "address_line1":"...", "state":"...", "date_of_expiry":"...", "confidence":...}';

      case 'bank_passbook':
      case 'bankPassbook':
        return '$base\n'
            '{"full_name":"...", "account_number":"...", "bank_name":"...", "branch_name":"...", "ifsc_code":"...", "confidence":...}';

      case 'income_certificate':
      case 'incomeCertificate':
        return '$base\n'
            '{"full_name":"...", "father_name":"...", "annual_income":"...", "district":"...", "state":"...", "certificate_number":"...", "confidence":...}';

      case 'ration_card':
      case 'rationCard':
        return '$base\n'
            '{"full_name":"...", "ration_card_number":"...", "address_line1":"...", "district":"...", "state":"...", "confidence":...}';

      case 'detect':
      case 'automatic':
        return 'Analyze this document carefully. First, identify what type of Indian Government document it is (aadhaar, pan, passport, voterID, drivingLicense, bankPassbook, incomeCertificate, rationCard).\n'
            'Then, extract all visible fields into a JSON structure.\n'
            'IMPORTANT: Include a "document_type" field with the identified type and a "confidence" field.\n'
            'Example for PAN: {"document_type": "pan", "full_name": "...", "pan_number": "...", "confidence": 0.95}\n'
            'Return ONLY the JSON.';

      default:
        return 'Extract all visible fields from this document into a JSON structure with a confidence score. If possible, identify the document type and include it as "document_type".';
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MERGE EXTRACTED DATA (Keep existing logic for compatibility)
  // ────────────────────────────────────────────────────────────────────────────

  static ExtractedUserData mergeExtractedData(List<CVIDocument> documents) {
    String? pick(String key) {
      for (final doc in documents) {
        final val = doc.extractedData[key];
        if (val != null && val.toString().isNotEmpty && val != 'null') {
          return val.toString();
        }
      }
      return null;
    }

    DateTime? parseDate(String? raw) {
      if (raw == null) return null;
      try {
        final parts = raw.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
        return DateTime.tryParse(raw);
      } catch (_) {
        return DateTime.tryParse(raw);
      }
    }

    final data = ExtractedUserData();
    data.fullName = pick('full_name') ?? pick('fullName');
    data.fatherName = pick('father_name') ?? pick('fatherName');
    data.motherName = pick('mother_name') ?? pick('motherName');
    data.spouseName = pick('spouse_name') ?? pick('spouseName');
    data.dateOfBirth = parseDate(pick('date_of_birth') ?? pick('dateOfBirth'));
    data.gender = pick('gender');
    data.bloodGroup = pick('blood_group') ?? pick('bloodGroup');
    data.aadhaarNumber = pick('aadhaar_number') ?? pick('aadhaarNumber');
    data.panNumber = pick('pan_number') ?? pick('panNumber');
    data.passportNumber = pick('passport_number') ?? pick('passportNumber');
    data.voterIdNumber = pick('voter_id_number') ??
        pick('voterIdNumber') ??
        pick('voter_id_number');
    data.drivingLicenseNumber = pick('driving_license_number') ??
        pick('drivingLicenseNumber') ??
        pick('driving_license_number');
    data.addressLine1 = pick('address_line1') ?? pick('addressLine1');
    data.addressLine2 = pick('address_line2') ?? pick('addressLine2');
    data.district = pick('district');
    data.state = pick('state');
    data.pincode = pick('pincode');
    return data;
  }
}
