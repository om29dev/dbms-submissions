// ═══════════════════════════════════════════════════════════════════════════════
// FORM TEMPLATE SERVICE — JSON-based dynamic form template engine
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

import '../models/auto_form_model.dart';

// Future AWS Textract integration point for document data extraction
// Future AWS Translate integration point for dynamic template translation

/// Loads and caches JSON form templates from the assets/forms/ directory.
class FormTemplateService {
  FormTemplateService._();

  /// In-memory template cache keyed by serviceId.
  static final Map<String, SmartFormTemplate> _cache = {};

  /// All known template file names mapped by serviceId.
  static const Map<String, String> _templateFiles = {
    'pan_card': 'assets/forms/pan_card.json',
    'passport': 'assets/forms/passport.json',
    'driving_license': 'assets/forms/driving_license.json',
    'ration_card': 'assets/forms/ration_card.json',
    'senior_citizen_pension': 'assets/forms/senior_citizen_pension.json',
    'bpl_certificate': 'assets/forms/bpl_certificate.json',
    'caste_certificate': 'assets/forms/caste_certificate.json',
  };

  /// Load a form template by serviceId.  Returns cached version if available.
  static Future<SmartFormTemplate?> loadTemplate(String serviceId) async {
    // Return from cache
    if (_cache.containsKey(serviceId)) {
      return _cache[serviceId];
    }

    final assetPath = _templateFiles[serviceId];
    if (assetPath == null) {
      debugPrint(
          '[FormTemplateService] No specific template for $serviceId. Using generic fallback.');
      return _getGenericFallback(serviceId);
    }

    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      final template = SmartFormTemplate.fromJson(jsonMap);
      _cache[serviceId] = template;
      return template;
    } catch (e) {
      debugPrint('[FormTemplateService] Error loading template $serviceId: $e');
      return null;
    }
  }

  /// Get all available template service IDs.
  static List<String> get availableTemplateIds => _templateFiles.keys.toList();

  /// Check if a template exists for a serviceId.
  static bool hasTemplate(String serviceId) =>
      _templateFiles.containsKey(serviceId);

  /// Clear the template cache (useful for hot reload during development).
  static void clearCache() => _cache.clear();

  static SmartFormTemplate _getGenericFallback(String serviceId) {
    return SmartFormTemplate(
      serviceId: serviceId,
      formTitle: {
        'en': 'Standard Civic Application',
        'hi': 'मानक नागरिक आवेदन'
      },
      portalName: 'Direct Government Portal',
      officialUrl: 'https://india.gov.in',
      introExplanation: {
        'en': 'Standard application for civic services.',
        'hi': 'नागरिक सेवाओं के लिए मानक आवेदन।'
      },
      fields: [
        SmartFormField(
          id: 'full_name',
          dataKey: 'full_name',
          fieldType: 'text',
          label: {'en': 'Full Name', 'hi': 'पूरा नाम'},
          required: true,
        ),
        SmartFormField(
          id: 'aadhaar_number',
          dataKey: 'aadhaar_number',
          fieldType: 'text',
          label: {'en': 'Aadhaar Number', 'hi': 'आधार संख्या'},
          required: true,
        ),
        SmartFormField(
          id: 'address',
          dataKey: 'address',
          fieldType: 'text',
          label: {'en': 'Address', 'hi': 'पता'},
          required: true,
        ),
      ],
    );
  }
}
