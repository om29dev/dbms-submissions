import 'package:flutter/foundation.dart';
import '../models/scheme_discovery_model.dart';
// Future AWS Integration Point: Amazon OpenSearch Service for blazing-fast full-text and vector search of schemes.

class SchemeDiscoveryProvider with ChangeNotifier {
  List<SchemeDiscoveryModel> _allSchemes = [];
  List<SchemeDiscoveryModel> _filteredSchemes = [];
  
  List<SchemeDiscoveryModel> get filteredSchemes => _filteredSchemes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentCategoryFilter = 'All';
  String get currentCategoryFilter => _currentCategoryFilter;

  final List<String> categories = ['All', 'Agriculture', 'Education', 'Healthcare', 'Housing', 'Business'];

  SchemeDiscoveryProvider() {
    _loadMockSchemes();
  }

  Future<void> _loadMockSchemes() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // Network simulation
    _allSchemes = [
      SchemeDiscoveryModel(
        id: '1', title: 'PM Kisan Samman Nidhi', category: 'Agriculture', 
        description: 'Financial support of ₹6000 per year to farmers.', 
        eligibilityCriteria: ['Must own agricultural land'], applicationProcess: 'Apply online via PM Kisan portal.'
      ),
      SchemeDiscoveryModel(
        id: '2', title: 'Sukanya Samriddhi Yojana', category: 'Education', 
        description: 'Savings scheme for the girl child.', 
        eligibilityCriteria: ['Girl child below 10 years'], applicationProcess: 'Open account in Post Office or Banks.'
      ),
      SchemeDiscoveryModel(
        id: '3', title: 'Ayushman Bharat', category: 'Healthcare', 
        description: 'Health cover of ₹5 lakhs per family per year.', 
        eligibilityCriteria: ['SECC 2011 listed families'], applicationProcess: 'Verify eligibility and get e-card at hospital.'
      ),
      SchemeDiscoveryModel(
        id: '4', title: 'PMAY-G', category: 'Housing', 
        description: 'Financial assistance to build pucca houses in rural areas.', 
        eligibilityCriteria: ['Houseless or living in kacha houses'], applicationProcess: 'Apply via GP or local administration.'
      ),
      SchemeDiscoveryModel(
        id: '5', title: 'MUDRA Yojana', category: 'Business', 
        description: 'Loans up to ₹10 Lakhs for non-corporate micro-enterprises.', 
        eligibilityCriteria: ['Indian Citizen with business plan'], applicationProcess: 'Apply via Banks/NBFCs.'
      ),
    ];
    _filteredSchemes = _allSchemes;
    _isLoading = false;
    notifyListeners();
  }

  void searchSchemes(String query) {
    if (query.isEmpty) {
      filterByCategory(_currentCategoryFilter);
      return;
    }
    
    _filteredSchemes = _allSchemes.where((s) {
      final matchesQuery = s.title.toLowerCase().contains(query.toLowerCase()) || 
                           s.description.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = _currentCategoryFilter == 'All' || s.category == _currentCategoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();
    
    notifyListeners();
  }

  void filterByCategory(String category) {
    _currentCategoryFilter = category;
    if (category == 'All') {
      _filteredSchemes = _allSchemes;
    } else {
      _filteredSchemes = _allSchemes.where((s) => s.category == category).toList();
    }
    notifyListeners();
  }
}
