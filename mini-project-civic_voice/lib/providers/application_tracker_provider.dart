import 'package:flutter/foundation.dart';
import '../models/app_tracker_model.dart';
// Future AWS Integration Point: Connect to AWS AppSync or API Gateway -> Lambda -> RDS to fetch real-time application statuses.

class ApplicationTrackerProvider with ChangeNotifier {
  List<AppTrackerModel> _applications = [];
  List<AppTrackerModel> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ApplicationTrackerProvider() {
    _fetchMockTrackerData();
  }

  Future<void> _fetchMockTrackerData() async {
    _isLoading = true;
    notifyListeners();

    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));

    _applications = [
      AppTrackerModel(
        id: 'APP98213', 
        schemeName: 'Income Certificate', 
        status: 'In Progress', 
        department: 'Revenue Dept', 
        submittedDate: DateTime.now().subtract(const Duration(days: 3)),
        estimatedCompletion: DateTime.now().add(const Duration(days: 5)),
      ),
      AppTrackerModel(
        id: 'APP44102', 
        schemeName: 'PM Kisan Registration', 
        status: 'Pending', 
        department: 'Agriculture', 
        submittedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppTrackerModel(
        id: 'APP11923', 
        schemeName: 'Renew Ration Card', 
        status: 'Completed', 
        department: 'Food & Civil Supplies', 
        submittedDate: DateTime.now().subtract(const Duration(days: 45)),
        estimatedCompletion: DateTime.now().subtract(const Duration(days: 40)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void refreshData() {
    _fetchMockTrackerData();
  }
}
