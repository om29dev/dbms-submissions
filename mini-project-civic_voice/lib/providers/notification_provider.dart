import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/notification_service.dart';

// ─── Notification Types ────────────────────────────────────────────────────

enum NotificationType { serviceUpdate, applicationStatus, newScheme, system, tip }

@immutable
class CVINotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? serviceId;

  const CVINotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.serviceId,
  });

  CVINotification copyWith({bool? isRead}) => CVINotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        serviceId: serviceId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'serviceId': serviceId,
      };

  factory CVINotification.fromJson(Map<String, dynamic> json) {
    return CVINotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      serviceId: json['serviceId'] as String?,
    );
  }
}

// ─── Provider ──────────────────────────────────────────────────────────────

class NotificationProvider extends ChangeNotifier {
  static const _prefKey = 'cvi_notifications';
  final List<CVINotification> _notifications = [];

  List<CVINotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  NotificationProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_prefKey);
      
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        _notifications.addAll(
            decodedList.map((j) => CVINotification.fromJson(j as Map<String, dynamic>)));
      } else {
        _seedInitialData();
        _saveToPrefs();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_prefKey, jsonString);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  void _seedInitialData() {
    final now = DateTime.now();
    _notifications.addAll([
      CVINotification(
        id: 'n1',
        title: 'Welcome to CVI',
        body: 'Tap the mic below to ask a question! Voice interactions are natively supported.',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      CVINotification(
        id: 'n2',
        title: 'New Scheme: PM-KISAN 2025',
        body: 'A new agricultural support scheme was just added to the platform.',
        type: NotificationType.newScheme,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CVINotification(
        id: 'n3',
        title: 'Tip: Use Voice for Faster Search',
        body: 'Try saying "Find Aadhaar Center" to quickly locate nearby government offices.',
        type: NotificationType.tip,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CVINotification(
        id: 'n4',
        title: 'Tip: Keep Documents Ready',
        body: 'Scanning your Aadhaar or PAN card beforehand makes application filling much faster.',
        type: NotificationType.tip,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? serviceId,
  }) {
    final newNotif = CVINotification(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      serviceId: serviceId,
    );
    _notifications.insert(0, newNotif);
    _saveToPrefs();
    
    // Also show a system/local notification
    NotificationService().showNotification(
      title: title,
      body: body,
      payload: serviceId,
    );
    
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || _notifications[idx].isRead == true) return;
    
    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    _saveToPrefs();
    notifyListeners();
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _saveToPrefs();
    notifyListeners();
  }
}
