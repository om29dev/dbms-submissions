import 'package:flutter/material.dart';

enum VerificationStatus { pending, verified, rejected }

class VerificationRequest {
  final String id;
  final String requesterName;
  final String requesterAvatar;
  final String purpose; // e.g., "Address Proof for Ration Card"
  final DateTime requestDate;
  final VerificationStatus status;
  final int endorsementsRequired;
  final int currentEndorsements;

  VerificationRequest({
    required this.id,
    required this.requesterName,
    required this.requesterAvatar,
    required this.purpose,
    required this.requestDate,
    this.status = VerificationStatus.pending,
    this.endorsementsRequired = 3,
    this.currentEndorsements = 0,
  });
}

class CommunityProvider with ChangeNotifier {
  // Mock Requests
  final List<VerificationRequest> _requests = [
    VerificationRequest(
      id: 'v1',
      requesterName: 'Ramesh Kumar',
      requesterAvatar: 'R',
      purpose: 'Residency Verification for Pension',
      requestDate: DateTime.now().subtract(const Duration(hours: 2)),
      currentEndorsements: 1,
    ),
    VerificationRequest(
      id: 'v2',
      requesterName: 'Sita Devi',
      requesterAvatar: 'S',
      purpose: 'Identity Witness for Bank Account',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      currentEndorsements: 2,
    ),
  ];

  List<VerificationRequest> get requests => _requests;

  void endorseRequest(String id) {
    int index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final req = _requests[index];
      // Increment endorsements
      int newCount = req.currentEndorsements + 1;
      VerificationStatus newStatus = req.status;
      
      if (newCount >= req.endorsementsRequired) {
        newStatus = VerificationStatus.verified;
      }

      _requests[index] = VerificationRequest(
        id: req.id,
        requesterName: req.requesterName,
        requesterAvatar: req.requesterAvatar,
        purpose: req.purpose,
        requestDate: req.requestDate,
        status: newStatus,
        endorsementsRequired: req.endorsementsRequired,
        currentEndorsements: newCount,
      );
      notifyListeners();
    }
  }
}
