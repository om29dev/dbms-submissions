import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/service_model.dart';
import '../data/mock/services_data.dart';
import '../data/csv_schemes_loader.dart';

/// Manages government service data, selection, progress, and recent views.
class ServicesProvider extends ChangeNotifier {
  static const _recentKey = 'cvi_recent_services';
  static const _progressKey = 'cvi_step_progress';
  static const _queryCountKey = 'cvi_query_count';

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  ServiceModel? _selectedService;
  List<String> _recentlyViewed = [];
  final Map<String, List<bool>> _stepProgress =
      {}; // serviceId -> [stepDone...]
  int _totalQueryCount = 0;
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // ─── Getters ─────────────────────────────────────────────────────────────

  List<ServiceModel> get allServices => List.unmodifiable(_allServices);
  List<ServiceModel> get filteredServices =>
      List.unmodifiable(_filteredServices);
  ServiceModel? get selectedService => _selectedService;
  List<String> get recentlyViewed => List.unmodifiable(_recentlyViewed);
  int get totalQueryCount => _totalQueryCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ServiceModel> get recentServices => _recentlyViewed
      .map((id) => _allServices.where((s) => s.id == id).firstOrNull)
      .whereType<ServiceModel>()
      .toList();

  ServicesProvider() {
    loadServices();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate async fetch (swap for AWS Amplify call later)
      await Future.delayed(const Duration(milliseconds: 300));

      // Load static curated mocks
      final mocks = MockServicesData.all;

      // Load dynamic from CSV
      final csvData = await CsvSchemesLoader.load();

      // Merge, giving priority to mocks if there are ID collisions
      final existingIds = mocks.map((m) => m.id).toSet();
      final filteredCsv = csvData.where((s) => !existingIds.contains(s.id));

      _allServices = [...mocks, ...filteredCsv];

      _applyFilters();

      await _restorePersistedData();
    } catch (e) {
      _error = 'Failed to load services: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restorePersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore recently viewed
      final saved = prefs.getStringList(_recentKey) ?? [];
      // Keep only IDs that still exist in the dataset
      _recentlyViewed = saved
          .where((id) => _allServices.any((s) => s.id == id))
          .toList();

      // Restore query count
      _totalQueryCount = prefs.getInt(_queryCountKey) ?? 0;

      // Restore step progress per service
      for (final service in _allServices) {
        final raw = prefs.getString('$_progressKey/${service.id}');
        if (raw != null) {
          _stepProgress[service.id] = raw
              .split(',')
              .map((v) => v == '1')
              .toList();
        } else {
          _stepProgress[service.id] = List.filled(service.steps.length, false);
        }
      }
    } catch (_) {}
  }

  // ─── Selection ────────────────────────────────────────────────────────────

  void selectService(String id) {
    _selectedService = _allServices.where((s) => s.id == id).firstOrNull;
    if (_selectedService != null) {
      addToRecent(id);
      _incrementQueryCount();
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedService = null;
    notifyListeners();
  }

  // ─── Filtering & Search ───────────────────────────────────────────────────

  void filterByCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    var results = _allServices;

    // Filter by Category
    if (_selectedCategory != 'All') {
      try {
        final categoryEnum = ServiceCategoryEx.fromString(_selectedCategory);
        results = results.where((s) => s.category == categoryEnum).toList();
      } catch (_) {}
    }

    // Filter by Search Query
    final q = _searchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      results = results.where((s) {
        final nEn = s.name['en']?.toLowerCase() ?? '';
        final nHi = s.name['hi']?.toLowerCase() ?? '';
        final dEn = s.description['en']?.toLowerCase() ?? '';
        return nEn.contains(q) || nHi.contains(q) || dEn.contains(q);
      }).toList();
    }

    _filteredServices = results;
    notifyListeners();
  }

  // ─── Recent Views ────────────────────────────────────────────────────────

  Future<void> addToRecent(String serviceId) async {
    _recentlyViewed.remove(serviceId);
    _recentlyViewed.insert(0, serviceId);
    if (_recentlyViewed.length > 5) {
      _recentlyViewed = _recentlyViewed.sublist(0, 5);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentKey, _recentlyViewed);
    } catch (_) {}
  }

  // ─── Step Progress ───────────────────────────────────────────────────────

  /// Returns the completed steps for [serviceId] as a list of booleans.
  List<bool> getProgress(String serviceId) {
    final service = _allServices.where((s) => s.id == serviceId).firstOrNull;
    if (service == null) return [];
    return _stepProgress[serviceId] ?? List.filled(service.steps.length, false);
  }

  /// Returns the number of completed steps for [serviceId].
  int completedStepsCount(String serviceId) =>
      getProgress(serviceId).where((v) => v).length;

  /// Returns true if all steps for [serviceId] are marked complete.
  bool isApplicationComplete(String serviceId) {
    final progress = getProgress(serviceId);
    return progress.isNotEmpty && progress.every((v) => v);
  }

  Future<void> markStepComplete(String serviceId, int stepIndex) async {
    final progress = List<bool>.from(getProgress(serviceId));
    if (stepIndex < 0 || stepIndex >= progress.length) return;
    progress[stepIndex] = true;
    _stepProgress[serviceId] = progress;
    notifyListeners();
    await _persistProgress(serviceId, progress);
  }

  Future<void> toggleStep(String serviceId, int stepIndex) async {
    final progress = List<bool>.from(getProgress(serviceId));
    if (stepIndex < 0 || stepIndex >= progress.length) return;
    progress[stepIndex] = !progress[stepIndex];
    _stepProgress[serviceId] = progress;
    notifyListeners();
    await _persistProgress(serviceId, progress);
  }

  Future<void> resetProgress(String serviceId) async {
    final service = _allServices.where((s) => s.id == serviceId).firstOrNull;
    if (service == null) return;
    _stepProgress[serviceId] = List.filled(service.steps.length, false);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_progressKey/$serviceId');
    } catch (_) {}
  }

  Future<void> _persistProgress(String serviceId, List<bool> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_progressKey/$serviceId',
        progress.map((v) => v ? '1' : '0').join(','),
      );
    } catch (_) {}
  }

  List<ServiceModel> searchLocalized(String query, String langCode) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _allServices;
    return _allServices.where((s) {
      final name = s.localizedName(langCode).toLowerCase();
      final desc = s.localizedDescription(langCode).toLowerCase();
      final enName = (s.name['en'] ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q) || enName.contains(q);
    }).toList();
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  Map<String, dynamic> getStats() {
    final activeApps = _stepProgress.entries
        .where((e) => e.value.any((v) => v) && !e.value.every((v) => v))
        .length;
    final completedApps = _stepProgress.entries
        .where((e) => e.value.isNotEmpty && e.value.every((v) => v))
        .length;

    return {
      'totalServices': _allServices.length,
      'activeApplications': activeApps,
      'completedApplications': completedApps,
      'totalQueries': _totalQueryCount,
      'recentCount': _recentlyViewed.length,
      'availableServices': _allServices.where((s) => s.isAvailable).length,
    };
  }

  // ─── Query Count ─────────────────────────────────────────────────────────

  Future<void> _incrementQueryCount() async {
    _totalQueryCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_queryCountKey, _totalQueryCount);
    } catch (_) {}
  }

  Future<void> incrementQueryCount() => _incrementQueryCount();
}
