import 'package:flutter/foundation.dart';

/// A single chat message in a CVI conversation.
@immutable
class MessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  /// Optional tag linking this message to a specific service ID.
  final String? serviceTag;

  /// Whether this message contains structured service data.
  final bool isServiceCard;

  /// Optional confidence score for AI-generated responses (0.0 – 1.0).
  final double? confidence;

  const MessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.serviceTag,
    this.isServiceCard = false,
    this.confidence,
  });

  /// Creates a user message with a generated ID and current timestamp.
  factory MessageModel.fromUser({
    required String text,
    String? serviceTag,
  }) =>
      MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        serviceTag: serviceTag,
      );

  /// Creates an AI/bot message with a generated ID and current timestamp.
  factory MessageModel.fromBot({
    required String text,
    String? serviceTag,
    bool isServiceCard = false,
    double? confidence,
  }) =>
      MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_bot',
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        serviceTag: serviceTag,
        isServiceCard: isServiceCard,
        confidence: confidence,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'serviceTag': serviceTag,
        'isServiceCard': isServiceCard,
        'confidence': confidence,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        serviceTag: json['serviceTag'] as String?,
        isServiceCard: json['isServiceCard'] as bool? ?? false,
        confidence: json['confidence'] as double?,
      );

  MessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? serviceTag,
    bool? isServiceCard,
    double? confidence,
  }) =>
      MessageModel(
        id: id ?? this.id,
        text: text ?? this.text,
        isUser: isUser ?? this.isUser,
        timestamp: timestamp ?? this.timestamp,
        serviceTag: serviceTag ?? this.serviceTag,
        isServiceCard: isServiceCard ?? this.isServiceCard,
        confidence: confidence ?? this.confidence,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MessageModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MessageModel(id: $id, isUser: $isUser, text: ${text.substring(0, text.length.clamp(0, 40))}...)';
}

/// A complete conversation session between the user and CVI assistant.
@immutable
class ConversationSession {
  final String id;
  final List<MessageModel> messages;

  /// BCP 47 language code: en, hi, mr, ta.
  final String language;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  /// Optional title derived from the first user message.
  final String? title;

  const ConversationSession({
    required this.id,
    required this.messages,
    required this.language,
    required this.createdAt,
    this.lastActiveAt,
    this.title,
  });

  /// Creates a brand-new empty session.
  factory ConversationSession.create({String language = 'en'}) {
    final now = DateTime.now();
    return ConversationSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      messages: const [],
      language: language,
      createdAt: now,
      lastActiveAt: now,
    );
  }

  int get messageCount => messages.length;
  bool get isEmpty => messages.isEmpty;
  MessageModel? get lastMessage =>
      isEmpty ? null : messages.last;

  /// Returns a new session with [message] appended.
  ConversationSession withMessage(MessageModel message) => copyWith(
        messages: [...messages, message],
        lastActiveAt: message.timestamp,
        title: title ??
            (message.isUser
                ? message.text.substring(0, message.text.length.clamp(0, 40))
                : null),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((m) => m.toJson()).toList(),
        'language': language,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'title': title,
      };

  factory ConversationSession.fromJson(Map<String, dynamic> json) =>
      ConversationSession(
        id: json['id'] as String,
        messages: (json['messages'] as List)
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList(),
        language: json['language'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastActiveAt: json['lastActiveAt'] != null
            ? DateTime.parse(json['lastActiveAt'] as String)
            : null,
        title: json['title'] as String?,
      );

  ConversationSession copyWith({
    String? id,
    List<MessageModel>? messages,
    String? language,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? title,
  }) =>
      ConversationSession(
        id: id ?? this.id,
        messages: messages ?? this.messages,
        language: language ?? this.language,
        createdAt: createdAt ?? this.createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        title: title ?? this.title,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationSession && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ─── Legacy Support ───────────────────────────────────────────────────────

/// Legacy message class used by older screens (e.g. voice_interface_screen).
/// Acts as a wrapper over MessageModel, adding 'action' capabilities.
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? action;

  const Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.action,
  });

  /// Convert to modern MessageModel for state storage.
  MessageModel toModel() => isUser
      ? MessageModel.fromUser(text: text)
      : MessageModel.fromBot(text: text);
}

