import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/complaint_model.dart';

class ComplaintProvider with ChangeNotifier {
  final List<ComplaintModel> _complaints = [];
  List<ComplaintModel> get complaints => _complaints;
  
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  ComplaintModel? _draftComplaint;
  ComplaintModel? get draftComplaint => _draftComplaint;

  // Mock mapping of regions to authorities
  final Map<String, String> _authorityMap = {
    'New Delhi': 'contact@ndmc.gov.in',
    'Mumbai': 'commissioner@mcgm.gov.in',
    'Bangalore': 'comm@bbmp.gov.in',
    'Lucknow': 'mc-lucknow@nic.in',
    'Generic': 'helpdesk@digitalindia.gov.in',
  };

  Future<void> processVoiceComplaint(String voiceText, String location) async {
    _isProcessing = true;
    notifyListeners();

    Position? position;
    try {
      // Fetch real GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.deniedForever && permission != LocationPermission.denied) {
          position = await Geolocator.getCurrentPosition();
        }
      }
    } catch (e) {
      // Fallback to manual/simulated location
    }

    await Future.delayed(const Duration(seconds: 2)); // Mock NLP parsing delay

    String category = 'General';
    if (voiceText.toLowerCase().contains('road')) category = 'Infrastructure';
    if (voiceText.toLowerCase().contains('water')) category = 'Water Supply';
    if (voiceText.toLowerCase().contains('power') || voiceText.toLowerCase().contains('electricity')) category = 'Electricity';

    // Simulate authority discovery based on detected city (mock logic)
    String detectedCity = location.contains('Delhi') ? 'New Delhi' : (location.contains('Mumbai') ? 'Mumbai' : 'Generic');
    String email = _authorityMap[detectedCity] ?? _authorityMap['Generic']!;

    _draftComplaint = ComplaintModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'official-citizen-auth',
      category: category,
      description: voiceText,
      location: location.isNotEmpty ? location : 'Geolocated Bharat Portal',
      latitude: position?.latitude,
      longitude: position?.longitude,
      authorityEmail: email,
      submittedAt: DateTime.now(),
      status: 'Verified by GPS',
    );

    _isProcessing = false;
    notifyListeners();
  }

  void attachImage(String base64Image) {
    if (_draftComplaint != null) {
      _draftComplaint = ComplaintModel(
        id: _draftComplaint!.id,
        userId: _draftComplaint!.userId,
        category: _draftComplaint!.category,
        description: _draftComplaint!.description,
        location: _draftComplaint!.location,
        status: _draftComplaint!.status,
        submittedAt: _draftComplaint!.submittedAt,
        base64Image: base64Image,
      );
      notifyListeners();
    }
  }

  Future<void> submitComplaint() async {
    if (_draftComplaint == null) return;
    
    _isProcessing = true;
    notifyListeners();

    // Mock network push / DB insert
    await Future.delayed(const Duration(seconds: 1));
    _complaints.add(_draftComplaint!);
    _draftComplaint = null;

    _isProcessing = false;
    notifyListeners();
  }

  void discardDraft() {
    _draftComplaint = null;
    notifyListeners();
  }
}
