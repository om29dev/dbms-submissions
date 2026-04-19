import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../../models/scheme_model.dart';

class CsvSchemeService {
  static List<GovernmentScheme> _allSchemes = [];

  static Future<void> init() async {
    if (_allSchemes.isNotEmpty) return;

    try {
      debugPrint('CsvSchemeService: Starting background load...');
      // Use rootBundle.load to get raw bytes (fast, non-blocking)
      // Decoding 13MB of String on main thread often causes ANR
      final byteData = await rootBundle.load('assets/data/updated_data.csv');

      // Move both decoding (utf8) and parsing (csv) to isolate
      _allSchemes =
          await compute(_parseCsvFromBytes, byteData.buffer.asUint8List());

      debugPrint(
          'CsvSchemeService: Loaded ${_allSchemes.length} schemes from background isolate');
    } catch (e) {
      debugPrint('CsvSchemeService: Init failed: $e');
    }
  }

  // Decodes raw bytes and parses CSV in one isolate pass
  static List<GovernmentScheme> _parseCsvFromBytes(Uint8List bytes) {
    final rawString = utf8.decode(bytes);
    return _parseCsvInBackground(rawString);
  }

  // Top-level or static helper for isolate
  static List<GovernmentScheme> _parseCsvInBackground(String rawData) {
    List<List<dynamic>> rows = CsvDecoder().convert(rawData);
    if (rows.length <= 1) return [];

    List<GovernmentScheme> result = [];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;

      final name = row[0].toString();
      final slug = row[1].toString();
      final details = row[2].toString();
      final benefits = row[3].toString();
      final eligibility = row[4].toString();
      final category = row.length > 8 ? row[8].toString() : 'Other';

      result.add(GovernmentScheme(
        id: slug,
        category: _mapCategoryStatic(category),
        names: {'en': name},
        description: details,
        benefits: benefits,
        helplineNumber: '1967',
        officialWebsite: 'https://india.gov.in',
        applicationMode: 'Online',
        eligibilityRules: _parseEligibilityStatic(eligibility),
        requiredDocuments: [],
        steps: [],
      ));
    }
    return result;
  }

  // Static versions of helpers for isolate safety
  static String _mapCategoryStatic(String raw) {
    raw = raw.toLowerCase();
    if (raw.contains('social welfare')) return 'social_welfare';
    if (raw.contains('education')) return 'education';
    if (raw.contains('agriculture')) return 'agriculture';
    if (raw.contains('health')) return 'health';
    if (raw.contains('business')) return 'business';
    if (raw.contains('women')) return 'women';
    return 'other';
  }

  static List<EligibilityRule> _parseEligibilityStatic(String text) {
    List<EligibilityRule> rules = [];
    final lowerText = text.toLowerCase();

    // 1. AGE RANGE
    final ageRangeMatch =
        RegExp(r'age (?:group of|between|from)?\s?(\d+)\s?[-to]+\s?(\d+)')
            .firstMatch(lowerText);
    if (ageRangeMatch != null) {
      rules.add(EligibilityRule(
        question: {'en': 'Minimum Age'},
        parameter: 'age',
        operator: '>=',
        value: int.parse(ageRangeMatch.group(1)!),
        explanation: {'en': 'Age must be at least ${ageRangeMatch.group(1)}'},
      ));
      rules.add(EligibilityRule(
        question: {'en': 'Maximum Age'},
        parameter: 'age',
        operator: '<=',
        value: int.parse(ageRangeMatch.group(2)!),
        explanation: {'en': 'Age must not exceed ${ageRangeMatch.group(2)}'},
      ));
    } else {
      final ageMinMatch =
          RegExp(r'(?:age should be|minimum age of|age of|at least)\s?(\d+)')
              .firstMatch(lowerText);
      if (ageMinMatch != null) {
        rules.add(EligibilityRule(
          question: {'en': 'Minimum Age'},
          parameter: 'age',
          operator: '>=',
          value: int.parse(ageMinMatch.group(1)!),
          explanation: {
            'en': 'Minimum age required is ${ageMinMatch.group(1)}'
          },
        ));
      }
    }

    // 2. INCOME
    final incomeMatch = RegExp(
            r'(?:income|salary|assistance)\s?(?:should not exceed|must be less than|below|up to|maximum of|limit of)?\s?(?:₹|rs\.?|inr)?\s?([\d,]+)')
        .firstMatch(lowerText);
    if (incomeMatch != null) {
      final cleanVal = incomeMatch.group(1)!.replaceAll(',', '');
      final incomeVal = double.tryParse(cleanVal);
      if (incomeVal != null && incomeVal > 1000) {
        rules.add(EligibilityRule(
          question: {'en': 'Maximum Income'},
          parameter: 'income',
          operator: '<=',
          value: incomeVal,
          explanation: {
            'en': 'Annual income must be below ₹${incomeVal.toStringAsFixed(0)}'
          },
        ));
      }
    }

    return rules;
  }

  static List<GovernmentScheme> findMatches(int age, double income) {
    // If no schemes loaded yet, return empty (should be handled by init call in UI)
    if (_allSchemes.isEmpty) return [];

    return _allSchemes.where((scheme) {
      // If we couldn't parse any specific rules, we might want to show it or hide it.
      // User said "100% accurate", so if we don't know the rules, it's safer to hide or show as "Potential"?
      // Let's hide for "100% accuracy" as it means strict matching.
      if (scheme.eligibilityRules.isEmpty) return false;

      for (var rule in scheme.eligibilityRules) {
        if (rule.parameter == 'age') {
          final val = rule.value as int;
          if (rule.operator == '>=' && age < val) return false;
          if (rule.operator == '<=' && age > val) return false;
        } else if (rule.parameter == 'income') {
          final val = rule.value as num;
          if (rule.operator == '<=' && income > val) return false;
        }
      }
      return true;
    }).toList();
  }
}
