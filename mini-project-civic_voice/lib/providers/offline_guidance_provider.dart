import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/offline_guide_model.dart';
// Future AWS Integration Point: Amplify DataStore / DynamoDB Offline Sync to sync guides when internet is available.

class OfflineGuidanceProvider with ChangeNotifier {
  List<OfflineGuideModel> _guides = [];
  List<OfflineGuideModel> get guides => _guides;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OfflineGuidanceProvider() {
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? cachedGuides = prefs.getString('offline_guides_cache');

    if (cachedGuides != null) {
      final List<dynamic> decoded = jsonDecode(cachedGuides);
      _guides = decoded.map((e) => OfflineGuideModel.fromJson(e)).toList();
    } else {
      // Load hardcoded fallback data if cache is empty
      _guides = [
        OfflineGuideModel(
          id: 'G1',
          title: 'How to apply for Ration Card',
          category: 'Food Security',
          steps: [
            'Visit local Panchayat/Ward office',
            'Submit Form 1 with family details',
            'Attach required documents',
            'Take acknowledgment slip'
          ],
          requiredDocuments: ['Aadhaar Card', 'Income Certificate', 'Passport Photos'],
          tip: 'Ensure all names match exactly with Aadhaar details.',
        ),
        OfflineGuideModel(
          id: 'G2',
          title: 'Opening a Jan Dhan Account',
          category: 'Finance',
          steps: [
            'Go to the nearest recognized Bank branch or Bank Mitra',
            'Fill account opening form',
            'Submit zero balance application',
            'Receive RuPay Debit Card within 7 days'
          ],
          requiredDocuments: ['Aadhaar Card or Voter ID'],
          tip: 'No minimum balance required for this account.',
        ),
        OfflineGuideModel(
          id: 'G3',
          title: 'Applying for PM Kisan Yojana',
          category: 'Agriculture',
          steps: [
            'Visit the PM Kisan portal or nearest CSC (Common Service Center)',
            'Provide landholding details and bank account number',
            'Verify Aadhaar authentication via OTP or fingerprint',
            'Submit the registration form'
          ],
          requiredDocuments: ['Aadhaar Card', 'Land Record (Khatauni)', 'Bank Passbook'],
          tip: 'Ensure your Aadhaar is linked to your bank account to receive the ₹6000/year benefit directly.',
        ),
        OfflineGuideModel(
          id: 'G4',
          title: 'Registering for Ayushman Bharat',
          category: 'Healthcare',
          steps: [
            'Check eligibility via PMJAY portal using mobile number or ration card',
            'Visit the nearest empaneled hospital or Ayushman Mitra',
            'Provide KYC documents for verification',
            'Collect your printed Ayushman Card (Golden Card)'
          ],
          requiredDocuments: ['Ration Card', 'Aadhaar Card', 'Active Mobile Number'],
          tip: 'This card provides free healthcare coverage up to ₹5 Lakhs per family per year.',
        ),
        OfflineGuideModel(
          id: 'G5',
          title: 'Filing an FIR Online',
          category: 'Legal/Police',
          steps: [
            'Visit your State Police official website or CCTNS portal',
            'Create a citizen account and log in',
            'Select "E-FIR" and fill in the incident details',
            'Submit the form and download the PDF copy of the FIR'
          ],
          requiredDocuments: ['Valid ID Proof', 'Details of the Incident'],
          tip: 'E-FIRs are currently accepted primarily for non-heinous crimes like theft of vehicles or lost property.',
        ),
        OfflineGuideModel(
          id: 'G6',
          title: 'PM Awas Yojana (Urban) Application',
          category: 'Housing',
          steps: [
            'Log into the PMAY(U) official website',
            'Select "Citizen Assessment" and choose appropriate component',
            'Enter Aadhaar details for verification',
            'Fill personal, income, and bank details, then save'
          ],
          requiredDocuments: ['Aadhaar Card', 'Income Certificate', 'Proof of Residence'],
          tip: 'Keep your bank details ready, as subsidies are transferred directly to the beneficiary account.',
        ),
      ];

      // Cache it for future offline use
      final encoded = jsonEncode(_guides.map((e) => e.toJson()).toList());
      await prefs.setString('offline_guides_cache', encoded);
    }

    _isLoading = false;
    notifyListeners();
  }
}
