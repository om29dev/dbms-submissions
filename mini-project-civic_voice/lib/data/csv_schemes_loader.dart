import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/service_model.dart';

/// Parses updated_data.csv from assets and converts rows into [ServiceModel]s.
class CsvSchemesLoader {
  CsvSchemesLoader._();

  static const _assetPath = 'assets/data/schemes.csv';

  static const _categoryMap = <String, ServiceCategory>{
    'agriculture': ServiceCategory.agriculture,
    'rural': ServiceCategory.agriculture,
    'environment': ServiceCategory.agriculture,
    'banking': ServiceCategory.finance,
    'financial': ServiceCategory.finance,
    'insurance': ServiceCategory.finance,
    'business': ServiceCategory.business,
    'entrepren': ServiceCategory.business,
    'education': ServiceCategory.education,
    'learning': ServiceCategory.education,
    'scholarship': ServiceCategory.education,
    'health': ServiceCategory.health,
    'wellness': ServiceCategory.health,
    'housing': ServiceCategory.welfare,
    'shelter': ServiceCategory.welfare,
    'social': ServiceCategory.welfare,
    'women': ServiceCategory.welfare,
    'child': ServiceCategory.welfare,
    'utility': ServiceCategory.welfare,
    'sanitation': ServiceCategory.welfare,
    'transport': ServiceCategory.transport,
    'infrastructure': ServiceCategory.transport,
    'skills': ServiceCategory.employment,
    'employment': ServiceCategory.employment,
    'science': ServiceCategory.business,
    'it': ServiceCategory.business,
    'communication': ServiceCategory.business,
    'legal': ServiceCategory.identity,
    'justice': ServiceCategory.identity,
    'travel': ServiceCategory.business,
    'tourism': ServiceCategory.business,
    'property': ServiceCategory.property,
    'land': ServiceCategory.property,
  };

  static const _emojiMap = <ServiceCategory, String>{
    ServiceCategory.agriculture: '🌾',
    ServiceCategory.finance: '💰',
    ServiceCategory.business: '🏢',
    ServiceCategory.education: '📚',
    ServiceCategory.health: '🏥',
    ServiceCategory.welfare: '🤝',
    ServiceCategory.transport: '🚗',
    ServiceCategory.employment: '💼',
    ServiceCategory.identity: '🪪',
    ServiceCategory.property: '🏠',
  };

  /// Load and parse CSV, returning a list of [ServiceModel]s.
  /// Parsing is done in a background isolate to avoid blocking the UI thread.
  static Future<List<ServiceModel>> load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      // Offload heavy parsing to a background isolate — prevents ANR freezes
      return await compute(_parseCsv, raw);
    } catch (e) {
      return [];
    }
  }

  static List<ServiceModel> _parseCsv(String raw) {
    final lines = raw.split('\n');
    if (lines.isEmpty) return [];

    // Parse header
    final header = _splitCsvRow(lines[0]);
    final nameIdx = _idx(header, 'scheme_name');
    final slugIdx = _idx(header, 'slug');
    final detailIdx = _idx(header, 'details');
    final benIdx = _idx(header, 'benefits');
    final eligIdx = _idx(header, 'eligibility');
    final appIdx = _idx(header, 'application');
    final docIdx = _idx(header, 'documents');
    final catIdx = _idx(header, 'schemeCategory');

    final results = <ServiceModel>[];
    final seenIds = <String>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final cols = _splitCsvRow(line);
      if (cols.length < 4) continue;

      final name = _col(cols, nameIdx).trim();
      if (name.isEmpty || name.length < 4) continue;

      final id =
          _col(cols, slugIdx).trim().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
      if (id.isEmpty || seenIds.contains(id)) continue;
      seenIds.add(id);

      final details = _col(cols, detailIdx);
      final benefits = _col(cols, benIdx);
      final eligib = _col(cols, eligIdx);
      final steps = _col(cols, appIdx);
      final docs = _col(cols, docIdx);
      final catRaw = _col(cols, catIdx).toLowerCase();

      if (details.length < 40 || eligib.length < 15) continue;

      final cat = _inferCategory(catRaw);

      final desc = _trim(
          '${details.substring(0, details.length.clamp(0, 350))}'
          '${benefits.isNotEmpty ? ' Benefits: ${benefits.substring(0, benefits.length.clamp(0, 180))}' : ''}',
          500);

      if (_isPopular(name)) {
        results.add(ServiceModel(
          id: id.substring(0, id.length.clamp(0, 60)),
          iconEmoji: _emojiMap[cat] ?? '📋',
          category: cat,
          isPopular: true,
          name: {'en': name.substring(0, name.length.clamp(0, 120))},
          description: {'en': desc},
          eligibilityCriteria: _splitSentences(eligib,
              4), // assuming there's an issue with _splitSentences so I will keep using the original name _splitSentences
          requiredDocuments: _parseDocs(docs),
          steps: _parseSteps(steps),
          estimatedTimeline: '15–30 working days',
          fees: 'Free / As applicable',
          officialLink: 'https://www.india.gov.in',
          helplineNumber: '1800-11-1555',
        ));
      }
    }

    return results;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static int _idx(List<String> h, String key) {
    final k = key.toLowerCase().trim();
    for (var i = 0; i < h.length; i++) {
      if (h[i].toLowerCase().trim() == k) return i;
    }
    return -1;
  }

  static String _col(List<String> cols, int idx) =>
      idx >= 0 && idx < cols.length ? cols[idx].trim() : '';

  static String _trim(String s, int max) =>
      s.length > max ? '${s.substring(0, max - 3)}...' : s;

  /// Minimal RFC-4180 CSV row splitter (handles quoted fields with commas/newlines).
  static List<String> _splitCsvRow(String row) {
    final result = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < row.length; i++) {
      final c = row[i];
      if (c == '"') {
        if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
          buf.write('"');
          i++; // escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == ',' && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    result.add(buf.toString());
    return result;
  }

  static ServiceCategory _inferCategory(String raw) {
    for (final entry in _categoryMap.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }
    return ServiceCategory.welfare;
  }

  static bool _isPopular(String name) {
    const kw = [
      'pm kisan',
      'ayushman',
      'mudra',
      'scholarship',
      'atal pension',
      'bpl',
      'mnrega',
      'jan dhan',
      'ujjwala',
      'swachh',
      'pmay',
      'digital india'
    ];
    final n = name.toLowerCase();
    return kw.any(n.contains);
  }

  static List<String> _splitSentences(String s, int max) {
    final parts = s
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((e) => e.trim())
        .where((e) => e.length > 8)
        .take(max)
        .toList();
    return parts.isEmpty ? [s.substring(0, s.length.clamp(0, 200))] : parts;
  }

  static List<DocumentItem> _parseDocs(String s) {
    if (s.isEmpty) {
      return [
        const DocumentItem(name: 'Aadhaar Card', description: ''),
        const DocumentItem(name: 'Proof of Identity', description: '')
      ];
    }
    final parts = s
        .split(RegExp(r'\.\s+(?=[A-Z])|(?<=\w)\n(?=[A-Z])'))
        .map((e) => e.trim().replaceAll(RegExp(r'[\r\n]'), ' '))
        .where((e) => e.length > 4)
        .take(6)
        .toList();
    return parts.isEmpty
        ? [const DocumentItem(name: 'Aadhaar Card', description: '')]
        : parts
            .map((d) => DocumentItem(
                  name: d
                      .substring(0, d.length.clamp(0, 100))
                      .replaceAll('"', ''),
                  description: '',
                ))
            .toList();
  }

  static List<StepItem> _parseSteps(String s) {
    if (s.isEmpty) {
      return [
        const StepItem(
            number: 1,
            title: 'Apply Online',
            description: 'Visit the official government portal to apply.')
      ];
    }

    // Look for "Step N:" pattern
    final matches = RegExp(
            r'Step\s*\d+[:.]\s*([^S]{20,250}?)(?=Step\s*\d+[:.:]|$)',
            caseSensitive: false)
        .allMatches(s)
        .take(5)
        .toList();

    if (matches.isNotEmpty) {
      return matches
          .asMap()
          .entries
          .map((e) => StepItem(
                number: e.key + 1,
                title: 'Step ${e.key + 1}',
                description: e.value.group(1)?.trim().substring(
                        0, e.value.group(1)!.trim().length.clamp(0, 200)) ??
                    '',
              ))
          .toList();
    }

    // Fallback: split on sentence boundaries
    final parts = s
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((e) => e.length > 20)
        .take(4)
        .toList();
    return parts
        .asMap()
        .entries
        .map((e) => StepItem(
              number: e.key + 1,
              title: 'Step ${e.key + 1}',
              description: e.value.substring(0, e.value.length.clamp(0, 200)),
            ))
        .toList();
  }
}
