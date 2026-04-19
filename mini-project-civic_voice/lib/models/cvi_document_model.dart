// ═══════════════════════════════════════════════════════════════════════════════
// CVI DOCUMENT MODEL — AI Auto Form Filler System
// ═══════════════════════════════════════════════════════════════════════════════

/// Types of Indian government documents supported by CVI.
enum DocumentType {
  aadhaar,
  pan,
  passport,
  voterID,
  drivingLicense,
  birthCertificate,
  incomeCertificate,
  casteCertificate,
  rationCard,
  bankPassbook,
  photo,
  signature,
  landRecord,
  marksheet,
  other,
}

extension DocumentTypeEx on DocumentType {
  String get label => switch (this) {
        DocumentType.aadhaar => 'Aadhaar Card',
        DocumentType.pan => 'PAN Card',
        DocumentType.passport => 'Passport',
        DocumentType.voterID => 'Voter ID',
        DocumentType.drivingLicense => 'Driving License',
        DocumentType.birthCertificate => 'Birth Certificate',
        DocumentType.incomeCertificate => 'Income Certificate',
        DocumentType.casteCertificate => 'Caste Certificate',
        DocumentType.rationCard => 'Ration Card',
        DocumentType.bankPassbook => 'Bank Passbook',
        DocumentType.photo => 'Passport Photo',
        DocumentType.signature => 'Signature',
        DocumentType.landRecord => 'Land Record',
        DocumentType.marksheet => 'Marksheet',
        DocumentType.other => 'Other',
      };

  String get labelHindi => switch (this) {
        DocumentType.aadhaar => 'आधार कार्ड',
        DocumentType.pan => 'पैन कार्ड',
        DocumentType.passport => 'पासपोर्ट',
        DocumentType.voterID => 'मतदाता पहचान पत्र',
        DocumentType.drivingLicense => 'ड्राइविंग लाइसेंस',
        DocumentType.birthCertificate => 'जन्म प्रमाणपत्र',
        DocumentType.incomeCertificate => 'आय प्रमाणपत्र',
        DocumentType.casteCertificate => 'जाति प्रमाणपत्र',
        DocumentType.rationCard => 'राशन कार्ड',
        DocumentType.bankPassbook => 'बैंक पासबुक',
        DocumentType.photo => 'पासपोर्ट फोटो',
        DocumentType.signature => 'हस्ताक्षर',
        DocumentType.landRecord => 'भूमि अभिलेख',
        DocumentType.marksheet => 'अंक पत्र',
        DocumentType.other => 'अन्य',
      };

  String get emoji => switch (this) {
        DocumentType.aadhaar => '🪪',
        DocumentType.pan => '💳',
        DocumentType.passport => '📘',
        DocumentType.voterID => '🗳️',
        DocumentType.drivingLicense => '🚗',
        DocumentType.birthCertificate => '📜',
        DocumentType.incomeCertificate => '💰',
        DocumentType.casteCertificate => '📋',
        DocumentType.rationCard => '🍚',
        DocumentType.bankPassbook => '🏦',
        DocumentType.photo => '📷',
        DocumentType.signature => '✍️',
        DocumentType.landRecord => '🏡',
        DocumentType.marksheet => '📝',
        DocumentType.other => '📄',
      };
}

/// A single uploaded document with AI-extracted data.
class CVIDocument {
  final String id;
  final DocumentType type;
  final String fileName;
  final String localPath;
  final DateTime uploadedAt;
  final bool isVerified;
  final Map<String, dynamic> extractedData;
  final double confidenceScore;
  final String? thumbnailPath;

  const CVIDocument({
    required this.id,
    required this.type,
    required this.fileName,
    required this.localPath,
    required this.uploadedAt,
    this.isVerified = false,
    this.extractedData = const {},
    this.confidenceScore = 0.0,
    this.thumbnailPath,
  });

  CVIDocument copyWith({
    String? id,
    DocumentType? type,
    String? fileName,
    String? localPath,
    DateTime? uploadedAt,
    bool? isVerified,
    Map<String, dynamic>? extractedData,
    double? confidenceScore,
    String? thumbnailPath,
  }) =>
      CVIDocument(
        id: id ?? this.id,
        type: type ?? this.type,
        fileName: fileName ?? this.fileName,
        localPath: localPath ?? this.localPath,
        uploadedAt: uploadedAt ?? this.uploadedAt,
        isVerified: isVerified ?? this.isVerified,
        extractedData: extractedData ?? this.extractedData,
        confidenceScore: confidenceScore ?? this.confidenceScore,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'fileName': fileName,
        'localPath': localPath,
        'uploadedAt': uploadedAt.toIso8601String(),
        'isVerified': isVerified,
        'extractedData': extractedData,
        'confidenceScore': confidenceScore,
        'thumbnailPath': thumbnailPath,
      };

  factory CVIDocument.fromJson(Map<String, dynamic> json) => CVIDocument(
        id: json['id'] as String,
        type: DocumentType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => DocumentType.other,
        ),
        fileName: json['fileName'] as String,
        localPath: json['localPath'] as String,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        isVerified: json['isVerified'] as bool? ?? false,
        extractedData:
            Map<String, dynamic>.from(json['extractedData'] as Map? ?? {}),
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
        thumbnailPath: json['thumbnailPath'] as String?,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// UNIFIED EXTRACTED DATA — All fields from all documents merged
// ═══════════════════════════════════════════════════════════════════════════════

class ExtractedUserData {
  // Personal
  String? fullName;
  String? fatherName;
  String? motherName;
  String? spouseName;
  DateTime? dateOfBirth;
  String? gender;
  String? bloodGroup;

  // Identity Numbers
  String? aadhaarNumber; // Masked: XXXX XXXX 1234
  String? panNumber;
  String? passportNumber;
  String? voterIdNumber;
  String? drivingLicenseNumber;

  // Address
  String? addressLine1;
  String? addressLine2;
  String? village;
  String? tehsil;
  String? district;
  String? state;
  String? pincode;

  // Contact
  String? mobileNumber;
  String? emailAddress;

  // Bank Details (from passbook)
  String? bankName;
  String? accountNumber; // Masked
  String? ifscCode;
  String? branchName;

  // Other
  String? caste;
  String? religion;
  String? nationality;
  String? occupation;
  String? annualIncome;
  String? rationCardNumber;
  String? passportExpiryDate;

  ExtractedUserData();

  /// How many non-null fields are populated.
  int get filledFieldCount {
    final json = toJson();
    return json.values.where((v) => v != null).length;
  }

  /// Total number of trackable fields.
  int get totalFieldCount => toJson().length;

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'father_name': fatherName,
        'mother_name': motherName,
        'spouse_name': spouseName,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'blood_group': bloodGroup,
        'aadhaar_number': aadhaarNumber,
        'pan_number': panNumber,
        'passport_number': passportNumber,
        'voter_id_number': voterIdNumber,
        'driving_license_number': drivingLicenseNumber,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'village': village,
        'tehsil': tehsil,
        'district': district,
        'state': state,
        'pincode': pincode,
        'mobile_number': mobileNumber,
        'email_address': emailAddress,
        'bank_name': bankName,
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
        'branch_name': branchName,
        'caste': caste,
        'religion': religion,
        'nationality': nationality,
        'occupation': occupation,
        'annual_income': annualIncome,
        'ration_card_number': rationCardNumber,
        'passport_expiry_date': passportExpiryDate,
      };

  factory ExtractedUserData.fromJson(Map<String, dynamic> j) {
    final data = ExtractedUserData();
    data.fullName = (j['full_name'] ?? j['fullName']) as String?;
    data.fatherName = (j['father_name'] ?? j['fatherName']) as String?;
    data.motherName = (j['mother_name'] ?? j['motherName']) as String?;
    data.spouseName = (j['spouse_name'] ?? j['spouseName']) as String?;
    data.dateOfBirth = (j['date_of_birth'] ?? j['dateOfBirth']) != null
        ? DateTime.tryParse((j['date_of_birth'] ?? j['dateOfBirth']) as String)
        : null;
    data.gender = j['gender'] as String?;
    data.bloodGroup = (j['blood_group'] ?? j['bloodGroup']) as String?;
    data.aadhaarNumber = (j['aadhaar_number'] ?? j['aadhaarNumber']) as String?;
    data.panNumber = (j['pan_number'] ?? j['panNumber']) as String?;
    data.passportNumber =
        (j['passport_number'] ?? j['passportNumber']) as String?;
    data.voterIdNumber =
        (j['voter_id_number'] ?? j['voterIdNumber']) as String?;
    data.drivingLicenseNumber =
        (j['driving_license_number'] ?? j['drivingLicenseNumber']) as String?;
    data.addressLine1 = (j['address_line1'] ?? j['addressLine1']) as String?;
    data.addressLine2 = (j['address_line2'] ?? j['addressLine2']) as String?;
    data.village = j['village'] as String?;
    data.tehsil = j['tehsil'] as String?;
    data.district = j['district'] as String?;
    data.state = j['state'] as String?;
    data.pincode = j['pincode'] as String?;
    data.mobileNumber = (j['mobile_number'] ?? j['mobileNumber']) as String?;
    data.emailAddress = (j['email_address'] ?? j['emailAddress']) as String?;
    data.bankName = (j['bank_name'] ?? j['bankName']) as String?;
    data.accountNumber = (j['account_number'] ?? j['accountNumber']) as String?;
    data.ifscCode = (j['ifsc_code'] ?? j['ifscCode']) as String?;
    data.branchName = (j['branch_name'] ?? j['branchName']) as String?;
    data.caste = j['caste'] as String?;
    data.religion = j['religion'] as String?;
    data.nationality = j['nationality'] as String?;
    data.occupation = j['occupation'] as String?;
    data.annualIncome = (j['annual_income'] ?? j['annualIncome']) as String?;
    data.rationCardNumber =
        (j['ration_card_number'] ?? j['rationCardNumber']) as String?;
    data.passportExpiryDate =
        (j['passport_expiry_date'] ?? j['passportExpiryDate']) as String?;
    return data;
  }
}
