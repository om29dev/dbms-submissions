import 'package:flutter/foundation.dart';

/// Comprehensive citizen profile model — the single source of truth
/// for all user demographic and identity data, persisted to DynamoDB.
@immutable
class CitizenProfileModel {
  final String id;
  final String fullName;
  final String mobile;
  final String email;
  final String state;

  // ── NEW: Location ──────────────────────────────────────────────────────────
  final String? district;
  final String? pincode;

  // ── NEW: Demographics ──────────────────────────────────────────────────────
  final DateTime? dateOfBirth;
  final String? gender; // Male / Female / Other / Prefer not to say
  final String? maritalStatus; // Single / Married / Widowed / Divorced

  // ── NEW: Financial & Social ────────────────────────────────────────────────
  final String?
      occupation; // Salaried / Self-Employed / Farmer / Student / Unemployed / Other
  final String? annualIncomeRange; // <1L / 1L-3L / 3L-5L / 5L-10L / >10L
  final String? casteCategory; // General / OBC / SC / ST / NT-DNT

  // ── LEGACY: kept for backwards-compat ────────────────────────────────────
  final double income;
  final int age;
  final bool isKycVerified;
  final List<String> linkedDocuments;
  final List<String> appliedSchemes;

  // ── NEW: Document IDs (masked) ─────────────────────────────────────────────
  final String? aadhaarLastFour; // Only last 4 digits — e.g. "5678"
  final String? panMasked; // e.g. "ABCDE****F"
  final String? rationCardNumber; // masked last 4

  // ── NEW: Disability ─────────────────────────────────────────────────────────
  final bool isDisabled;
  final String? disabilityType;

  const CitizenProfileModel({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.state,
    this.district,
    this.pincode,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.occupation,
    this.annualIncomeRange,
    this.casteCategory,
    this.age = 0,
    this.income = 0.0,
    this.isKycVerified = false,
    this.linkedDocuments = const [],
    this.appliedSchemes = const [],
    this.aadhaarLastFour,
    this.panMasked,
    this.rationCardNumber,
    this.isDisabled = false,
    this.disabilityType,
  });

  // ── Derived getters ─────────────────────────────────────────────────────────

  /// Age derived from dateOfBirth; falls back to stored `age` field.
  int get computedAge {
    if (dateOfBirth != null) {
      final now = DateTime.now();
      int a = now.year - dateOfBirth!.year;
      if (now.month < dateOfBirth!.month ||
          (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
        a--;
      }
      return a;
    }
    return age;
  }

  /// Profile completion 0–100 based on 10 key fields.
  int get profileCompletionPercent {
    int filled = 0;
    const total = 10;
    // Basic (always available for real users, skip guest fields)
    if (fullName.isNotEmpty) filled++;
    if (mobile.isNotEmpty || email.isNotEmpty) filled++;
    // Demographics
    if (dateOfBirth != null) filled++;
    if (gender != null && gender!.isNotEmpty) filled++;
    if (maritalStatus != null && maritalStatus!.isNotEmpty) filled++;
    // Location
    if (state.isNotEmpty && state != 'Not Set') filled++;
    if (district != null && district!.isNotEmpty) filled++;
    // Financial
    if (occupation != null && occupation!.isNotEmpty) filled++;
    if (annualIncomeRange != null && annualIncomeRange!.isNotEmpty) filled++;
    // Identity
    if (aadhaarLastFour != null && aadhaarLastFour!.isNotEmpty) filled++;
    return ((filled / total) * 100).round();
  }

  bool get isProfileIncomplete => profileCompletionPercent < 70;

  // ── Serialization ───────────────────────────────────────────────────────────

  factory CitizenProfileModel.fromJson(Map<String, dynamic> json) {
    return CitizenProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String? ?? '',
      state: json['state'] as String? ?? '',
      district: json['district'] as String?,
      pincode: json['pincode'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      maritalStatus: json['marital_status'] as String?,
      occupation: json['occupation'] as String?,
      annualIncomeRange: json['annual_income_range'] as String?,
      casteCategory: json['caste_category'] as String?,
      age: json['age'] as int? ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      isKycVerified: json['is_kyc_verified'] as bool? ?? false,
      linkedDocuments:
          List<String>.from(json['linked_documents'] as List? ?? []),
      appliedSchemes: List<String>.from(json['applied_schemes'] as List? ?? []),
      aadhaarLastFour: json['aadhaar_last_four'] as String?,
      panMasked: json['pan_masked'] as String?,
      rationCardNumber: json['ration_card_number'] as String?,
      isDisabled: json['is_disabled'] as bool? ?? false,
      disabilityType: json['disability_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'mobile': mobile,
      'email': email,
      'state': state,
      'district': district,
      'pincode': pincode,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'marital_status': maritalStatus,
      'occupation': occupation,
      'annual_income_range': annualIncomeRange,
      'caste_category': casteCategory,
      'age': age,
      'income': income,
      'is_kyc_verified': isKycVerified,
      'linked_documents': linkedDocuments,
      'applied_schemes': appliedSchemes,
      'aadhaar_last_four': aadhaarLastFour,
      'pan_masked': panMasked,
      'ration_card_number': rationCardNumber,
      'is_disabled': isDisabled,
      'disability_type': disabilityType,
    };
  }

  CitizenProfileModel copyWith({
    String? id,
    String? fullName,
    String? mobile,
    String? email,
    String? state,
    String? district,
    String? pincode,
    DateTime? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? occupation,
    String? annualIncomeRange,
    String? casteCategory,
    int? age,
    double? income,
    bool? isKycVerified,
    List<String>? linkedDocuments,
    List<String>? appliedSchemes,
    String? aadhaarLastFour,
    String? panMasked,
    String? rationCardNumber,
    bool? isDisabled,
    String? disabilityType,
  }) {
    return CitizenProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      state: state ?? this.state,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      occupation: occupation ?? this.occupation,
      annualIncomeRange: annualIncomeRange ?? this.annualIncomeRange,
      casteCategory: casteCategory ?? this.casteCategory,
      age: age ?? this.age,
      income: income ?? this.income,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      linkedDocuments: linkedDocuments ?? this.linkedDocuments,
      appliedSchemes: appliedSchemes ?? this.appliedSchemes,
      aadhaarLastFour: aadhaarLastFour ?? this.aadhaarLastFour,
      panMasked: panMasked ?? this.panMasked,
      rationCardNumber: rationCardNumber ?? this.rationCardNumber,
      isDisabled: isDisabled ?? this.isDisabled,
      disabilityType: disabilityType ?? this.disabilityType,
    );
  }
}
