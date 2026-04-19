import 'package:flutter/material.dart';
import '../models/citizen_profile_model.dart';
import '../core/services/citizen_profile_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class CitizenProfileProvider with ChangeNotifier {
  final _service = CitizenProfileService();
  CitizenProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  CitizenProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  int get completionPercent => _profile?.profileCompletionPercent ?? 0;
  bool get isProfileIncomplete => _profile?.isProfileIncomplete ?? true;

  // ─── Fetch ────────────────────────────────────────────────────────────────

  Future<void> fetchProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await Amplify.Auth.getCurrentUser();
      var fetched = await _service.fetchProfile(user.userId);

      if (fetched == null) {
        debugPrint(
            '[CitizenProfileProvider] Profile not found, bootstrapping from Cognito...');
        final authAttributes = await Amplify.Auth.fetchUserAttributes();

        String email = '';
        String name = 'Citizen';
        String mobile = '';

        for (final attr in authAttributes) {
          if (attr.userAttributeKey == AuthUserAttributeKey.email) {
            email = attr.value;
          }
          if (attr.userAttributeKey == AuthUserAttributeKey.name) {
            name = attr.value;
          }
          if (attr.userAttributeKey == AuthUserAttributeKey.phoneNumber) {
            mobile = attr.value;
          }
          if (name == 'Citizen' &&
              attr.userAttributeKey == AuthUserAttributeKey.givenName) {
            name = attr.value;
          }
        }

        fetched = CitizenProfileModel(
          id: user.userId,
          fullName: name,
          email: email,
          mobile: mobile,
          state: '',
          isKycVerified: false,
          linkedDocuments: const [],
          appliedSchemes: const [],
        );

        // Persist empty profile to DynamoDB so it can be updated later
        await _service.saveProfile(fetched);
        debugPrint(
            '[CitizenProfileProvider] Auto-initialized profile for ${user.userId}');
      }

      _profile = fetched;
    } catch (e) {
      debugPrint('[CitizenProfileProvider] fetchProfile error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  /// Updates the profile optimistically in-memory then persists to DynamoDB.
  Future<bool> updateProfile(CitizenProfileModel newProfile) async {
    final previous = _profile;
    _profile = newProfile;
    _isSaving = true;
    notifyListeners();

    try {
      final success = await _service.saveProfile(newProfile);
      if (!success) {
        // Roll back on failure
        _profile = previous;
        _error = 'Failed to save profile to server.';
      } else {
        _error = null;
      }
      return success;
    } catch (e) {
      _profile = previous;
      _error = e.toString();
      debugPrint('[CitizenProfileProvider] updateProfile error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Partial update — merges only specified fields and saves
  Future<bool> patchProfile({
    String? fullName,
    String? state,
    String? district,
    String? pincode,
    DateTime? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? occupation,
    String? annualIncomeRange,
    String? casteCategory,
    String? aadhaarLastFour,
    String? panMasked,
    String? rationCardNumber,
    bool? isDisabled,
    String? disabilityType,
  }) async {
    if (_profile == null) return false;
    final updated = _profile!.copyWith(
      fullName: fullName,
      state: state,
      district: district,
      pincode: pincode,
      dateOfBirth: dateOfBirth,
      gender: gender,
      maritalStatus: maritalStatus,
      occupation: occupation,
      annualIncomeRange: annualIncomeRange,
      casteCategory: casteCategory,
      aadhaarLastFour: aadhaarLastFour,
      panMasked: panMasked,
      rationCardNumber: rationCardNumber,
      isDisabled: isDisabled,
      disabilityType: disabilityType,
    );
    return updateProfile(updated);
  }

  Future<void> linkNewDocument(String docName) async {
    if (_profile == null) return;
    final docs = List<String>.from(_profile!.linkedDocuments)..add(docName);
    await updateProfile(_profile!.copyWith(linkedDocuments: docs));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
