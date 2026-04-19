import 'package:flutter/foundation.dart';
// Future AWS Integration Point: Comprehend / Bedrock for intent parsing and matching eligible schemes via natural language responses.

class EligibilityCheckerProvider with ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  final List<String> _chatHistory = [];
  List<String> get chatHistory => _chatHistory;

  final List<String> _matchedSchemes = [];
  List<String> get matchedSchemes => _matchedSchemes;

  // Dummy mock process to determine eligibility
  Future<void> processUserInput(String input) async {
    _isProcessing = true;
    _chatHistory.add('User: $input');
    notifyListeners();

    // Simulate AI network delay / AWS integration point
    await Future.delayed(const Duration(seconds: 2));

    _chatHistory.add(
        'System: Analyzing... Based on your responses, I found potential matches.');

    // Simple placeholder logic for demo
    if (input.toLowerCase().contains('farmer') ||
        input.toLowerCase().contains('agriculture')) {
      _matchedSchemes.clear();
      _matchedSchemes.addAll([
        'PM Kisan Samman Nidhi',
        'Kisan Credit Card',
        'Soil Health Card Scheme'
      ]);
    } else {
      _matchedSchemes.clear();
      _matchedSchemes.addAll(
          ['Ayushman Bharat', 'Pradhan Mantri Awas Yojana', 'Jan Dhan Yojana']);
    }

    _isProcessing = false;
    notifyListeners();
  }

  void clearChat() {
    _chatHistory.clear();
    _matchedSchemes.clear();
    notifyListeners();
  }
}
