import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/service_model.dart';
import '../core/services/reasoning_engine.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

class ConversationProvider extends ChangeNotifier {
  ConversationSession _session = ConversationSession.create(language: 'en');

  bool _isLoading = false;
  String _currentServiceId = '';
  String? _errorMessage;

  // Scheme & User Context for Specialized Guidance
  ServiceModel? _activeSchemeContext;
  Map<String, dynamic>? _userProfileContext;
  List<String>? _availableDocumentsContext;

  // ─── Getters ─────────────────────────────────────────────────────────────

  ConversationSession get session => _session;
  List<MessageModel> get modernMessages =>
      _session.messages; // rename to avoid conflict
  bool get isLoading => _isLoading;
  String get currentServiceId => _currentServiceId;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _session.messages.isNotEmpty;

  ServiceModel? get activeSchemeContext => _activeSchemeContext;
  bool get isSchemeMode => _activeSchemeContext != null;
  String get activeSchemeName =>
      _activeSchemeContext?.localizedName(_session.language) ?? '';

  // ─── Legacy Getters ─────────────────────────────────────────────────────

  /// Exposes modern MessageModels as legacy Messages for UI backwards compatibility.
  List<Message> get messages => _session.messages
      .map(
        (m) => Message(
          text: m.text,
          isUser: m.isUser,
          timestamp: m.timestamp,
        ),
      )
      .toList();

  // ─── Session ─────────────────────────────────────────────────────────────

  void setLanguage(String langCode) {
    _session = _session.copyWith(language: langCode);
    notifyListeners();
  }

  void clearConversation() {
    _session = ConversationSession.create(language: _session.language);
    _currentServiceId = '';
    _errorMessage = null;
    _activeSchemeContext = null;
    _userProfileContext = null;
    _availableDocumentsContext = null;
    notifyListeners();
  }

  /// Sets up a specialized context for scheme-specific AI guidance.
  void setSchemeGuidanceContext({
    required ServiceModel scheme,
    Map<String, dynamic>? userProfile,
    List<String>? documents,
  }) {
    _session = ConversationSession.create(language: _session.language);
    _activeSchemeContext = scheme;
    _userProfileContext = userProfile;
    _availableDocumentsContext = documents;
    _currentServiceId = scheme.id;
    _errorMessage = null;
    notifyListeners();
  }

  /// Legacy alias for clearConversation.
  void clearMessages() => clearConversation();

  /// Legacy method to delete a specific message by index in the unified session.
  void deleteMessage(int index) {
    if (index >= 0 && index < _session.messages.length) {
      final updatedList = List<MessageModel>.from(_session.messages)
        ..removeAt(index);
      _session = _session.copyWith(messages: updatedList);
      notifyListeners();
    }
  }

  // ─── Send Message ─────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _errorMessage = null;

    // Add user message
    final userMsg = MessageModel.fromUser(text: trimmed);
    _session = _session.withMessage(userMsg);
    _isLoading = true;
    notifyListeners();

    // Natural delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final engine = ReasoningEngine(languageCode: _session.language);

      // Convert history to format expected by ReasoningEngine
      final history = _session.messages
          .take(_session.messages.length - 1)
          .map(
            (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
          )
          .toList();

      String responseText;
      if (_activeSchemeContext != null) {
        // Use specialized scheme guidance (Llama 70B)
        responseText = await engine.generateSchemeGuidance(
          userInput: trimmed,
          schemeContext: _activeSchemeContext!.toJson(),
          userProfile: _userProfileContext ?? {},
          availableDocuments: _availableDocumentsContext ?? [],
          history: history,
        );
      } else {
        // General CVI Voice guidance
        responseText = await engine.generateAIResponse(trimmed, history);
      }
      final linkedServiceId = _extractServiceId(responseText);

      final botMsg = MessageModel.fromBot(
        text: responseText,
        serviceTag: linkedServiceId,
        isServiceCard: linkedServiceId != null,
        confidence: 0.95,
      );
      _session = _session.withMessage(botMsg);

      if (linkedServiceId != null) {
        _currentServiceId = linkedServiceId;
      }
    } catch (e) {
      _errorMessage = e.toString();
      final errMsg = MessageModel.fromBot(text: _errorText(_session.language));
      _session = _session.withMessage(errMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _extractServiceId(String text) {
    // Look for [ACTION:LINK:serviceId] or [ACTION:NAVIGATE:serviceId]
    final regExp = RegExp(r'\[ACTION:(?:LINK|NAVIGATE):([^\]]+)\]');
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  // ─── Fallback Strings ─────────────────────────────────────────────────────

  String _errorText(String lang) => switch (lang) {
        'hi' => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।',
        'mr' => 'काहीतरी चुकीचे झाले. कृपया पुन्हा प्रयत्न करा.',
        'ta' => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.',
        _ => 'Something went wrong. Please try again.',
      };

  void startNewChat() => clearConversation();
  Future<void> loadSession(String id) async {}
  Future<void> deleteSession(String id) async {}
  void updateVoiceProvider(dynamic vp) {}
  List<ConversationSession> get sessions => [_session];
  String get currentSessionId => _session.id;
}
