import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../models/citizen_profile_model.dart';

class CitizenProfileService {
  // ─── GraphQL Query ────────────────────────────────────────────────────────

  static const String _getModelQuery = r'''
    query GetCitizenProfile($id: ID!) {
      getCitizenProfile(id: $id) {
        id
        full_name
        mobile
        email
        state
        district
        pincode
        date_of_birth
        gender
        marital_status
        occupation
        annual_income_range
        caste_category
        age
        income
        is_kyc_verified
        linked_documents
        applied_schemes
        aadhaar_last_four
        pan_masked
        ration_card_number
        is_disabled
        disability_type
      }
    }
  ''';

  // ─── GraphQL Mutations ────────────────────────────────────────────────────

  static const String _updateModelMutation = r'''
    mutation UpdateCitizenProfile($input: UpdateCitizenProfileInput!) {
      updateCitizenProfile(input: $input) {
        id
      }
    }
  ''';

  static const String _createModelMutation = r'''
    mutation CreateCitizenProfile($input: CreateCitizenProfileInput!) {
      createCitizenProfile(input: $input) {
        id
      }
    }
  ''';

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<CitizenProfileModel?> fetchProfile(String userId) async {
    try {
      final request = GraphQLRequest<String>(
        document: _getModelQuery,
        variables: {'id': userId},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        debugPrint('[CitizenProfileService] fetch errors: ${response.errors}');
      }
      if (response.data != null) {
        final data = json.decode(response.data!);
        final profileData = data['getCitizenProfile'];
        if (profileData != null) {
          return CitizenProfileModel.fromJson(
              Map<String, dynamic>.from(profileData));
        }
      }
      return null;
    } catch (e) {
      debugPrint('[CitizenProfileService] fetchProfile error: $e');
      return null;
    }
  }

  Future<bool> saveProfile(CitizenProfileModel profile) async {
    try {
      final input = _toGraphqlInput(profile);

      // Try update first; if not found, create.
      final updateRequest = GraphQLRequest<String>(
        document: _updateModelMutation,
        variables: {'input': input},
      );

      final response =
          await Amplify.API.mutate(request: updateRequest).response;

      if (response.errors.isNotEmpty) {
        debugPrint(
            '[CitizenProfileService] update errors, attempting create: ${response.errors}');
        // Fallback: create the record
        final createRequest = GraphQLRequest<String>(
          document: _createModelMutation,
          variables: {'input': input},
        );
        final createResponse =
            await Amplify.API.mutate(request: createRequest).response;
        if (createResponse.errors.isNotEmpty) {
          debugPrint(
              '[CitizenProfileService] create errors: ${createResponse.errors}');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('[CitizenProfileService] saveProfile error: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Converts CitizenProfileModel to a GraphQL-friendly map.
  /// Uses snake_case keys matching the DynamoDB schema.
  Map<String, dynamic> _toGraphqlInput(CitizenProfileModel p) {
    final map = <String, dynamic>{
      'id': p.id,
      'full_name': p.fullName,
      'mobile': p.mobile,
      'email': p.email,
      'state': p.state,
      'age': p.age,
      'income': p.income,
      'is_kyc_verified': p.isKycVerified,
      'linked_documents': p.linkedDocuments,
      'applied_schemes': p.appliedSchemes,
      'is_disabled': p.isDisabled,
    };
    // Only include optional fields if non-null to avoid overwriting with null
    if (p.district != null) map['district'] = p.district;
    if (p.pincode != null) map['pincode'] = p.pincode;
    if (p.dateOfBirth != null) {
      map['date_of_birth'] = p.dateOfBirth!.toIso8601String();
    }
    if (p.gender != null) map['gender'] = p.gender;
    if (p.maritalStatus != null) map['marital_status'] = p.maritalStatus;
    if (p.occupation != null) map['occupation'] = p.occupation;
    if (p.annualIncomeRange != null) {
      map['annual_income_range'] = p.annualIncomeRange;
    }
    if (p.casteCategory != null) map['caste_category'] = p.casteCategory;
    if (p.aadhaarLastFour != null) {
      map['aadhaar_last_four'] = p.aadhaarLastFour;
    }
    if (p.panMasked != null) map['pan_masked'] = p.panMasked;
    if (p.rationCardNumber != null) {
      map['ration_card_number'] = p.rationCardNumber;
    }
    if (p.disabilityType != null) map['disability_type'] = p.disabilityType;
    return map;
  }
}
