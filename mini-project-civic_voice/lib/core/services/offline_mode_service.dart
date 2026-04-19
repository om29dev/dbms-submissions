import 'package:connectivity_plus/connectivity_plus.dart';
import 'scheme_knowledge_base.dart';

class OfflineModeService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final dynamic result = await _connectivity.checkConnectivity();
    if (result is List) {
      return !result.contains(ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }

  /// Processes text queries locally when offline using Regex matching
  String processQuery(String query) {
    final lowerQuery = query.toLowerCase();

    // 1. Helpline Queries
    if (lowerQuery.contains('helpline') || lowerQuery.contains('number') || lowerQuery.contains('contact')) {
      return _findHelpline(lowerQuery);
    }

    // 2. Step/Status Queries
    if (lowerQuery.contains('step') || lowerQuery.contains('how to') || lowerQuery.contains('process')) {
      return _findSteps(lowerQuery);
    }

    // 3. Document Queries
    if (lowerQuery.contains('document') || lowerQuery.contains('proof') || lowerQuery.contains('papers')) {
      return _findDocuments(lowerQuery);
    }

    // 4. Scheme General Info
    return _findSchemeInfo(lowerQuery);
  }

  String _findHelpline(String query) {
    for (var scheme in SchemeKnowledgeBase.schemes) {
      if (query.contains(scheme.id) || query.contains(scheme.names['en']!.toLowerCase())) {
        return "The helpline for ${scheme.names['en']} is ${scheme.helplineNumber}. This works offline.";
      }
    }
    return "I couldn't find a specific helpline. General Emergency: 112.";
  }

  String _findSteps(String query) {
    for (var scheme in SchemeKnowledgeBase.schemes) {
      if (query.contains(scheme.id) || query.contains(scheme.names['en']!.toLowerCase())) {
        final steps = scheme.steps.map((s) => "Step ${s.number}: ${s.title['en']}").join('. ');
        return "Here is the process for ${scheme.names['en']}: $steps";
      }
    }
    return "Please specify which scheme you need steps for (e.g., 'Pension process').";
  }

  String _findDocuments(String query) {
    for (var scheme in SchemeKnowledgeBase.schemes) {
      if (query.contains(scheme.id) || query.contains(scheme.names['en']!.toLowerCase())) {
        final docs = scheme.requiredDocuments.map((d) => d.name['en']).join(', ');
        return "Documents required for ${scheme.names['en']}: $docs.";
      }
    }
    return "Which scheme's documents are you looking for?";
  }

  String _findSchemeInfo(String query) {
    for (var scheme in SchemeKnowledgeBase.schemes) {
      if (query.contains(scheme.id) || query.contains(scheme.names['en']!.toLowerCase())) {
        return "${scheme.names['en']}: ${scheme.description} Benefits: ${scheme.benefits}";
      }
    }
    return "I am in Offline Mode. I can only answer basic queries about known schemes (Pension, Ration, PM-Kisan). Connect to internet for full AI support.";
  }
}
