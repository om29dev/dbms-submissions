// ═══════════════════════════════════════════════════════════════════════════════
// FORM FILLER SERVICE — Government form definitions + auto-fill engine
// ═══════════════════════════════════════════════════════════════════════════════

import '../../models/cvi_document_model.dart';
import 'document_vault_service.dart';

/// Definition of a single form field.
class FormFieldDef {
  final String id;
  final String label;
  final String labelHindi;
  final String dataKey; // maps to user_extracted_data column name
  final String fieldType; // text, date, dropdown, checkbox
  final bool isRequired;
  final List<String>? options; // for dropdowns
  final String? validationPattern;

  const FormFieldDef({
    required this.id,
    required this.label,
    required this.labelHindi,
    required this.dataKey,
    this.fieldType = 'text',
    this.isRequired = true,
    this.options,
    this.validationPattern,
  });
}

/// Definition of a government form for a specific service.
class GovernmentFormDef {
  final String serviceId;
  final String formName;
  final String formNameHindi;
  final String officialUrl;
  final List<FormFieldDef> fields;
  final List<DocumentType> requiredDocuments;
  final List<DocumentType> optionalDocuments;
  final String submitInstructions;

  const GovernmentFormDef({
    required this.serviceId,
    required this.formName,
    required this.formNameHindi,
    required this.officialUrl,
    required this.fields,
    this.requiredDocuments = const [],
    this.optionalDocuments = const [],
    required this.submitInstructions,
  });
}

class FormFillerService {
  // ─── Form definitions for government services ──────────────────────────────

  static final Map<String, GovernmentFormDef> _forms = {
    // ── Passport ────────────────────────────────────────────────────────────
    'passport': const GovernmentFormDef(
      serviceId: 'passport',
      formName: 'Passport Application (SP-1)',
      formNameHindi: 'पासपोर्ट आवेदन फॉर्म',
      officialUrl: 'https://passportindia.gov.in',
      requiredDocuments: [DocumentType.aadhaar, DocumentType.pan],
      optionalDocuments: [DocumentType.photo],
      submitInstructions:
          'Submit online at passportindia.gov.in then visit nearest Passport Seva Kendra with original documents.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Mother\'s Name',
            labelHindi: 'माता का नाम',
            dataKey: 'mother_name',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'Spouse Name',
            labelHindi: 'जीवनसाथी का नाम',
            dataKey: 'spouse_name',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'Address Line 1',
            labelHindi: 'पता पंक्ति 1',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            validationPattern: r'^\d{6}$',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'Mobile Number',
            labelHindi: 'मोबाइल नंबर',
            dataKey: 'mobile_number',
            validationPattern: r'^\d{10}$',
            isRequired: false),
        FormFieldDef(
            id: 'f12',
            label: 'Email',
            labelHindi: 'ईमेल',
            dataKey: 'email_address',
            isRequired: false),
        FormFieldDef(
            id: 'f13',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
      ],
    ),

    // ── PAN Card ─────────────────────────────────────────────────────────────
    'pan_card': const GovernmentFormDef(
      serviceId: 'pan_card',
      formName: 'PAN Card Application (Form 49A)',
      formNameHindi: 'पैन कार्ड आवेदन',
      officialUrl:
          'https://onlineservices.proteantech.in/paam/endUserRegisterContact.html',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.photo],
      submitInstructions:
          'Apply online at NSDL or UTIITSL portal. Documents will be verified electronically.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Email',
            labelHindi: 'ईमेल',
            dataKey: 'email_address',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
      ],
    ),

    // ── Voter ID ─────────────────────────────────────────────────────────────
    'voter_id': const GovernmentFormDef(
      serviceId: 'voter_id',
      formName: 'Voter Registration (Form 6)',
      formNameHindi: 'मतदाता पंजीकरण',
      officialUrl: 'https://voterportal.eci.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.photo],
      submitInstructions:
          'Apply online at voterportal.eci.gov.in. BLO will visit for verification.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father/Husband Name',
            labelHindi: 'पिता/पति का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'Email',
            labelHindi: 'ईमेल',
            dataKey: 'email_address',
            isRequired: false),
      ],
    ),

    // ── Aadhaar Card ─────────────────────────────────────────────────────────
    'aadhaar_card': const GovernmentFormDef(
      serviceId: 'aadhaar_card',
      formName: 'Aadhaar Enrollment / Update',
      formNameHindi: 'आधार नामांकन / अपडेट',
      officialUrl: 'https://ssup.uidai.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      submitInstructions:
          'Update online at ssup.uidai.gov.in or visit nearest Aadhaar Centre.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f3',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Address Line 1',
            labelHindi: 'पता पंक्ति 1',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── Driving License ──────────────────────────────────────────────────────
    'driving_license': const GovernmentFormDef(
      serviceId: 'driving_license',
      formName: 'Driving License Application',
      formNameHindi: 'ड्राइविंग लाइसेंस आवेदन',
      officialUrl: 'https://parivahan.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.photo],
      submitInstructions:
          'Apply at parivahan.gov.in → Sarathi portal. Book a slot for your local RTO.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Blood Group',
            labelHindi: 'रक्त समूह',
            dataKey: 'blood_group',
            fieldType: 'dropdown',
            options: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
      ],
    ),

    // ── Ration Card ──────────────────────────────────────────────────────────
    'ration_card': const GovernmentFormDef(
      serviceId: 'ration_card',
      formName: 'Ration Card Application',
      formNameHindi: 'राशन कार्ड आवेदन',
      officialUrl: 'https://nfsa.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.incomeCertificate],
      submitInstructions:
          'Apply at your state food and civil supplies portal or visit the nearest office.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Head of Family',
            labelHindi: 'परिवार का मुखिया',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'Village',
            labelHindi: 'गाँव',
            dataKey: 'village',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f11',
            label: 'Annual Income',
            labelHindi: 'वार्षिक आय',
            dataKey: 'annual_income',
            isRequired: false),
        FormFieldDef(
            id: 'f12',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f13',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f14',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
      ],
    ),

    // ── PM Kisan ─────────────────────────────────────────────────────────────
    'pm_kisan': const GovernmentFormDef(
      serviceId: 'pm_kisan',
      formName: 'PM-KISAN Registration',
      formNameHindi: 'पीएम-किसान पंजीकरण',
      officialUrl: 'https://pmkisan.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.bankPassbook],
      submitInstructions:
          'Register at pmkisan.gov.in or visit Common Service Centre (CSC).',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Farmer Name',
            labelHindi: 'किसान का नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Father Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Category',
            labelHindi: 'श्रेणी',
            dataKey: 'caste',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'Village',
            labelHindi: 'गाँव',
            dataKey: 'village',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f10',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
        FormFieldDef(
            id: 'f12',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── Ayushman Bharat ──────────────────────────────────────────────────────
    'ayushman_bharat': const GovernmentFormDef(
      serviceId: 'ayushman_bharat',
      formName: 'Ayushman Bharat PMJAY',
      formNameHindi: 'आयुष्मान भारत PMJAY',
      officialUrl: 'https://pmjay.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.rationCard],
      submitInstructions:
          'Check eligibility at pmjay.gov.in or visit nearest Ayushman Mitra.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Head of Family',
            labelHindi: 'परिवार मुखिया',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f7',
            label: 'Ration Card',
            labelHindi: 'राशन कार्ड',
            dataKey: 'ration_card_number',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── Senior Citizen Pension ───────────────────────────────────────────────
    'senior_citizen_pension': const GovernmentFormDef(
      serviceId: 'senior_citizen_pension',
      formName: 'Old Age Pension (IGNOAPS)',
      formNameHindi: 'वृद्धावस्था पेंशन',
      officialUrl: 'https://nsap.nic.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [
        DocumentType.bankPassbook,
        DocumentType.incomeCertificate
      ],
      submitInstructions:
          'Apply at District Social Welfare Office or Common Service Centre.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f10',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
        FormFieldDef(
            id: 'f12',
            label: 'Annual Income',
            labelHindi: 'वार्षिक आय',
            dataKey: 'annual_income',
            isRequired: false),
        FormFieldDef(
            id: 'f13',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── Income Tax (ITR) ─────────────────────────────────────────────────────
    'income_tax': const GovernmentFormDef(
      serviceId: 'income_tax',
      formName: 'Income Tax Return (ITR-1)',
      formNameHindi: 'आयकर रिटर्न',
      officialUrl: 'https://www.incometax.gov.in',
      requiredDocuments: [DocumentType.pan, DocumentType.aadhaar],
      optionalDocuments: [DocumentType.bankPassbook],
      submitInstructions:
          'File online at incometax.gov.in. Verify via Aadhaar OTP.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'PAN Number',
            labelHindi: 'पैन नंबर',
            dataKey: 'pan_number'),
        FormFieldDef(
            id: 'f3',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Email',
            labelHindi: 'ईमेल',
            dataKey: 'email_address',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
      ],
    ),

    // ── Birth Certificate ────────────────────────────────────────────────────
    'birth_certificate': const GovernmentFormDef(
      serviceId: 'birth_certificate',
      formName: 'Birth Certificate Application',
      formNameHindi: 'जन्म प्रमाण पत्र आवेदन',
      officialUrl: 'https://crsorgi.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      submitInstructions:
          'Apply at municipal corporation or online at crsorgi.gov.in.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Child\'s Name',
            labelHindi: 'बच्चे का नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Mother\'s Name',
            labelHindi: 'माता का नाम',
            dataKey: 'mother_name',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── National Scholarship ─────────────────────────────────────────────────
    'national_scholarship': const GovernmentFormDef(
      serviceId: 'national_scholarship',
      formName: 'National Scholarship Portal',
      formNameHindi: 'राष्ट्रीय छात्रवृत्ति पोर्टल',
      officialUrl: 'https://scholarships.gov.in',
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [
        DocumentType.incomeCertificate,
        DocumentType.bankPassbook
      ],
      submitInstructions:
          'Apply at scholarships.gov.in. Verify with institution.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Student Name',
            labelHindi: 'छात्र का नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Gender',
            labelHindi: 'लिंग',
            dataKey: 'gender',
            fieldType: 'dropdown',
            options: ['Male', 'Female', 'Other'],
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'Category',
            labelHindi: 'श्रेणी',
            dataKey: 'caste',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Annual Income',
            labelHindi: 'वार्षिक आय',
            dataKey: 'annual_income',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f10',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
        FormFieldDef(
            id: 'f12',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── GST Registration ─────────────────────────────────────────────────────
    'gst_registration': const GovernmentFormDef(
      serviceId: 'gst_registration',
      formName: 'GST Registration (REG-01)',
      formNameHindi: 'जीएसटी पंजीकरण',
      officialUrl: 'https://www.gst.gov.in',
      requiredDocuments: [DocumentType.pan, DocumentType.aadhaar],
      optionalDocuments: [DocumentType.bankPassbook],
      submitInstructions: 'Apply at gst.gov.in. PAN-based verification.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Legal Name',
            labelHindi: 'कानूनी नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'PAN Number',
            labelHindi: 'पैन नंबर',
            dataKey: 'pan_number'),
        FormFieldDef(
            id: 'f3',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Email',
            labelHindi: 'ईमेल',
            dataKey: 'email_address',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
      ],
    ),

    // ── EPFO Account ─────────────────────────────────────────────────────────
    'epfo_account': const GovernmentFormDef(
      serviceId: 'epfo_account',
      formName: 'EPFO UAN Activation',
      formNameHindi: 'EPFO UAN सक्रियण',
      officialUrl: 'https://unifiedportal-mem.epfindia.gov.in',
      requiredDocuments: [DocumentType.aadhaar, DocumentType.pan],
      optionalDocuments: [DocumentType.bankPassbook],
      submitInstructions:
          'Activate UAN at member portal. Link Aadhaar and bank account.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Date of Birth',
            labelHindi: 'जन्म तिथि',
            dataKey: 'date_of_birth',
            fieldType: 'date',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f4',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f5',
            label: 'PAN Number',
            labelHindi: 'पैन नंबर',
            dataKey: 'pan_number'),
        FormFieldDef(
            id: 'f6',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),

    // ── MSME Registration ────────────────────────────────────────────────────
    'msme_registration': const GovernmentFormDef(
      serviceId: 'msme_registration',
      formName: 'Udyam Registration',
      formNameHindi: 'उद्यम पंजीकरण',
      officialUrl: 'https://udyamregistration.gov.in',
      requiredDocuments: [DocumentType.aadhaar, DocumentType.pan],
      optionalDocuments: [DocumentType.bankPassbook],
      submitInstructions:
          'Register at udyamregistration.gov.in with Aadhaar OTP.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Owner Name',
            labelHindi: 'मालिक का नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f3',
            label: 'PAN Number',
            labelHindi: 'पैन नंबर',
            dataKey: 'pan_number'),
        FormFieldDef(
            id: 'f4',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Email',
            labelHindi: 'ईमेल',
            dataKey: 'email_address',
            isRequired: false),
        FormFieldDef(
            id: 'f10',
            label: 'Bank Account',
            labelHindi: 'बैंक खाता',
            dataKey: 'account_number',
            isRequired: false),
        FormFieldDef(
            id: 'f11',
            label: 'IFSC Code',
            labelHindi: 'IFSC कोड',
            dataKey: 'ifsc_code',
            isRequired: false),
      ],
    ),

    // ── Land Records ─────────────────────────────────────────────────────────
    'land_records': const GovernmentFormDef(
      serviceId: 'land_records',
      formName: 'Land Records Application',
      formNameHindi: 'भूलेख आवेदन',
      officialUrl: 'https://landrecords.gov.in', // generic URL
      requiredDocuments: [DocumentType.aadhaar],
      optionalDocuments: [DocumentType.pan],
      submitInstructions:
          'Apply online or visit the local tehsildar office with Aadhaar.',
      fields: [
        FormFieldDef(
            id: 'f1',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            dataKey: 'full_name',
            isRequired: false),
        FormFieldDef(
            id: 'f2',
            label: 'Father\'s Name',
            labelHindi: 'पिता का नाम',
            dataKey: 'father_name',
            isRequired: false),
        FormFieldDef(
            id: 'f3',
            label: 'Aadhaar Number',
            labelHindi: 'आधार नंबर',
            dataKey: 'aadhaar_number'),
        FormFieldDef(
            id: 'f4',
            label: 'Address',
            labelHindi: 'पता',
            dataKey: 'address_line1',
            isRequired: false),
        FormFieldDef(
            id: 'f5',
            label: 'State',
            labelHindi: 'राज्य',
            dataKey: 'state',
            fieldType: 'dropdown',
            options: _indianStates,
            isRequired: false),
        FormFieldDef(
            id: 'f6',
            label: 'District',
            labelHindi: 'जिला',
            dataKey: 'district',
            isRequired: false),
        FormFieldDef(
            id: 'f7',
            label: 'Village',
            labelHindi: 'गाँव',
            dataKey: 'village',
            isRequired: false),
        FormFieldDef(
            id: 'f8',
            label: 'PIN Code',
            labelHindi: 'पिन कोड',
            dataKey: 'pincode',
            isRequired: false),
        FormFieldDef(
            id: 'f9',
            label: 'Mobile',
            labelHindi: 'मोबाइल',
            dataKey: 'mobile_number',
            isRequired: false),
      ],
    ),
  };

  // ─── Indian states list ────────────────────────────────────────────────────
  static const _indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Chandigarh',
    'Puducherry',
    'Ladakh',
    'Jammu & Kashmir',
    'Andaman & Nicobar',
    'Lakshadweep',
    'Dadra & Nagar Haveli and Daman & Diu',
  ];

  // ─── Auto-fill from local ExtractedUserData (legacy support) ───────────────

  static Map<String, String?> autoFillForm({
    required String serviceId,
    required ExtractedUserData userData,
  }) {
    final form = _forms[serviceId];
    if (form == null) return {};

    final Map<String, String?> filledValues = {};
    final dataJson = userData.toJson();

    for (final field in form.fields) {
      var value = dataJson[field.dataKey]?.toString();
      if (field.fieldType == 'date' && value != null) {
        try {
          final date = DateTime.parse(value);
          value = '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}';
        } catch (_) {}
      }
      filledValues[field.id] = value;
    }
    return filledValues;
  }

  // ─── Auto-fill from AWS Amplify extracted data ──────────────────────────────

  static Future<Map<String, dynamic>> autoFillFromAws({
    required String serviceId,
  }) async {
    final userData = await DocumentVaultService.getUserExtractedData();

    if (userData == null) {
      return {
        'success': false,
        'message': 'No documents uploaded yet',
        'filledValues': <String, String?>{},
        'emptyFields': <String>[],
      };
    }

    final form = _forms[serviceId];
    if (form == null) {
      return {
        'success': false,
        'message': 'No form definition for this service',
        'filledValues': <String, String?>{},
        'emptyFields': <String>[],
      };
    }

    final Map<String, String?> filledValues = {};
    final List<String> emptyFields = [];
    int filledCount = 0;

    for (final field in form.fields) {
      final value = userData[field.dataKey]?.toString();
      if (value != null && value.isNotEmpty && value != 'null') {
        filledValues[field.id] = value;
        filledCount++;
      } else {
        filledValues[field.id] = null;
        emptyFields.add(field.label);
      }
    }

    return {
      'success': true,
      'form': form,
      'filledValues': filledValues,
      'emptyFields': emptyFields,
      'filledCount': filledCount,
      'totalCount': form.fields.length,
      'fillPercentage': form.fields.isEmpty
          ? 0
          : (filledCount / form.fields.length * 100).round(),
    };
  }

  /// Get form definition for a service.
  static GovernmentFormDef? getForm(String serviceId) => _forms[serviceId];

  /// Check which required documents are missing for a service.
  static List<DocumentType> getMissingDocuments({
    required String serviceId,
    required List<CVIDocument> uploadedDocuments,
  }) {
    final form = _forms[serviceId];
    if (form == null) return [];

    final uploadedTypes = uploadedDocuments.map((d) => d.type).toSet();
    return form.requiredDocuments
        .where((required) => !uploadedTypes.contains(required))
        .toList();
  }

  /// Count how many fields can be filled with current user data.
  static ({int filled, int total}) getAutoFillStats({
    required String serviceId,
    required ExtractedUserData userData,
  }) {
    final filled = autoFillForm(serviceId: serviceId, userData: userData);
    final nonNull =
        filled.values.where((v) => v != null && v.isNotEmpty).length;
    return (filled: nonNull, total: filled.length);
  }

  /// Get all available form service IDs.
  static List<String> get availableFormIds => _forms.keys.toList();
}
