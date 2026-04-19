import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AnalyticsProvider extends ChangeNotifier {
  int _queriesCount = 0;
  Set<String> _servicesViewed = {};
  DateTime _lastActivity = DateTime.now();

  int get queriesCount => _queriesCount;
  int get servicesExploredCount => _servicesViewed.length;
  DateTime get lastActivity => _lastActivity;

  AnalyticsProvider() {
    _loadData();
  }

  Future<String> _getUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.userId;
    } catch (_) {
      return 'guest';
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();

    final lastDateStr = prefs.getString('cvi_analytics_last_date_$userId');
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    if (lastDateStr == todayStr) {
      _queriesCount = prefs.getInt('cvi_analytics_queries_$userId') ?? 0;
    } else {
      _queriesCount = 0;
      await prefs.setString('cvi_analytics_last_date_$userId', todayStr);
    }

    final servicesList =
        prefs.getStringList('cvi_analytics_services_$userId') ?? [];
    _servicesViewed = servicesList.toSet();

    final lastActStr = prefs.getString('cvi_analytics_last_activity_$userId');
    if (lastActStr != null) {
      _lastActivity = DateTime.parse(lastActStr);
    }

    notifyListeners();
  }

  Future<void> incrementVoiceQuery() async {
    _queriesCount++;
    _lastActivity = DateTime.now();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    await prefs.setInt('cvi_analytics_queries_$userId', _queriesCount);
    await _updateLastActivity(prefs, userId);
  }

  Future<void> recordServiceView(String serviceId) async {
    if (_servicesViewed.add(serviceId)) {
      _lastActivity = DateTime.now();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      await prefs.setStringList(
          'cvi_analytics_services_$userId', _servicesViewed.toList());
      await _updateLastActivity(prefs, userId);
    }
  }

  Future<void> _updateLastActivity(
      SharedPreferences prefs, String userId) async {
    await prefs.setString(
        'cvi_analytics_last_activity_$userId', _lastActivity.toIso8601String());
  }
}
