import '../../models/service_model.dart';

/// Complete mock dataset for all 8 government services in CVI.
/// All names and descriptions are provided in English, Hindi, Marathi, and Tamil.
class MockServicesData {
  MockServicesData._();

  static List<ServiceModel> get all => [
        aadhaarCard,
        panCard,
        passport,
        drivingLicense,
        landRecords,
        birthCertificate,
        rationCard,
        seniorCitizenPension,
        incomeTax,
        voterId,
        gstRegistration,
        epfoAccount,
        pmKisan,
        ayushmanBharat,
        nationalScholarship,
        msmeRegistration,
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 1: Aadhaar Card
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel aadhaarCard = ServiceModel(
    id: 'aadhaar_card',
    iconEmoji: '🪪',
    category: ServiceCategory.identity,
    isAvailable: true,
    name: {
      'en': 'Aadhaar Card',
      'hi': 'आधार कार्ड',
      'mr': 'आधार कार्ड',
      'ta': 'ஆதார் அட்டை',
    },
    description: {
      'en':
          'Aadhaar is a 12-digit unique identity number issued by UIDAI to every Indian resident. It serves as proof of identity and address and is required for most government services.',
      'hi':
          'आधार एक 12 अंकों का अनोखा पहचान नंबर है जो UIDAI द्वारा प्रत्येक भारतीय निवासी को जारी किया जाता है। यह पहचान और पते के प्रमाण के रूप में कार्य करता है।',
      'mr':
          'आधार हा UIDAI द्वारे प्रत्येक भारतीय रहिवाशाला जारी केलेला 12 अंकी अनन्य ओळख क्रमांक आहे. हे ओळख आणि पत्त्याचा पुरावा म्हणून काम करते.',
      'ta':
          'ஆதார் என்பது UIDAI ஆல் ஒவ்வொரு இந்திய வாசிக்கும் வழங்கப்படும் 12 இலக்க தனித்துவமான அடையாள எண். இது அடையாளம் மற்றும் முகவரிக்கான சான்றாக செயல்படுகிறது.',
    },
    eligibilityCriteria: [
      'Indian resident of any age',
      'Individuals who have lived in India for at least 182 days in the 12 months preceding the date of application',
      'No minimum age requirement — infants can also be enrolled',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Proof of Identity (any one)',
        description:
            'Passport, Voter ID, PAN Card, Driving License, Government-issued Photo ID',
      ),
      DocumentItem(
        name: 'Proof of Address (any one)',
        description:
            'Passport, Bank Statement, Utility Bill (Electricity/Water/Gas), Voter ID, Ration Card',
      ),
      DocumentItem(
        name: 'Proof of Date of Birth (any one)',
        description:
            'Birth Certificate, SSLC/10th Certificate, Passport, PAN Card',
        isOptional: true,
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Locate Enrollment Center',
        description:
            'Find the nearest Aadhaar enrollment center on the UIDAI website or app.',
        actionUrl: 'https://appointments.uidai.gov.in',
      ),
      StepItem(
        number: 2,
        title: 'Fill Enrollment Form',
        description:
            'Fill the Aadhaar enrollment form at the center with your personal details.',
      ),
      StepItem(
        number: 3,
        title: 'Biometric Capture',
        description:
            'Provide all 10 fingerprints, iris scan, and facial photograph at the center.',
      ),
      StepItem(
        number: 4,
        title: 'Receive Acknowledgment Slip',
        description:
            'Collect the enrollment acknowledgment slip with your Enrollment ID (EID).',
      ),
      StepItem(
        number: 5,
        title: 'Track & Download e-Aadhaar',
        description:
            'Track your Aadhaar status on UIDAI portal using EID. Download e-Aadhaar once generated.',
        actionUrl: 'https://myaadhaar.uidai.gov.in',
      ),
    ],
    estimatedTimeline: '5–10 working days',
    fees: 'Free',
    officialLink: 'https://myaadhaar.uidai.gov.in/CheckAadhaarStatus',
    helplineNumber: '1947',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 2: PAN Card
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel panCard = ServiceModel(
    id: 'pan_card',
    iconEmoji: '💳',
    category: ServiceCategory.identity,
    isAvailable: true,
    name: {
      'en': 'PAN Card',
      'hi': 'पैन कार्ड',
      'mr': 'पॅन कार्ड',
      'ta': 'பான் அட்டை',
    },
    description: {
      'en':
          'Permanent Account Number (PAN) is a 10-character alphanumeric identifier issued by the Income Tax Department. It is mandatory for financial transactions, filing income tax, and opening bank accounts.',
      'hi':
          'स्थायी खाता संख्या (PAN) आयकर विभाग द्वारा जारी किया गया 10 अक्षरों का अल्फ़ान्यूमेरिक पहचानकर्ता है। यह वित्तीय लेनदेन, आयकर दाखिल करने और बैंक खाते खोलने के लिए अनिवार्य है।',
      'mr':
          'कायमस्वरूपी खाते क्रमांक (PAN) हा आयकर विभागाने जारी केलेला 10 वर्णांचा अक्षरांकीय ओळखकर्ता आहे. आर्थिक व्यवहार, आयकर भरणे आणि बँक खाते उघडण्यासाठी हे अनिवार्य आहे.',
      'ta':
          'நிரந்தர கணக்கு எண் (PAN) என்பது வருமான வரித்துறையால் வழங்கப்படும் 10 எழுத்து அல்பான்யூமெரிக் அடையாளங்காட்டி. நிதி பரிவர்த்தனைகள், வருமான வரி தாக்கல் மற்றும் வங்கி கணக்கு திறப்பதற்கு இது கட்டாயமாகும்.',
    },
    eligibilityCriteria: [
      'Indian citizens, companies, and foreign nationals who are liable to pay tax in India',
      'Any person who intends to enter into financial transactions where PAN is mandatory',
      'Minors can also hold PAN cards (applied by guardian)',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Aadhaar Card',
        description: 'Used as proof of identity and address',
      ),
      DocumentItem(
        name: 'Proof of Identity (any one)',
        description:
            'Aadhaar, Voter ID, Driving License, Passport, Ration Card',
      ),
      DocumentItem(
        name: 'Proof of Address (any one)',
        description:
            'Aadhaar, Voter ID, Utility Bill, Bank Statement, Passport',
      ),
      DocumentItem(
        name: 'Proof of Date of Birth (any one)',
        description:
            'Birth Certificate, 10th Marksheet, Passport, Driving License',
      ),
      DocumentItem(
        name: 'Passport-size Photographs',
        description: '2 recent color passport-size photographs',
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Visit Income Tax e-Filing Portal',
        description:
            'Go to incometax.gov.in and click on "Instant e-PAN" for a free e-PAN using Aadhaar.',
        actionUrl:
            'https://onlineservices.proteantech.in/paam/endUserRegisterContact.html',
      ),
      StepItem(
        number: 2,
        title: 'Fill Form 49A',
        description:
            'Fill the PAN application (Form 49A) with personal details, income details, and upload documents.',
      ),
      StepItem(
        number: 3,
        title: 'Upload Documents & Photo',
        description:
            'Upload scanned copies of your identity proof, address proof, DOB proof, and photograph.',
      ),
      StepItem(
        number: 4,
        title: 'Pay Application Fee',
        description:
            'Pay ₹107 for a physical PAN card or ₹72 for an e-PAN via net banking, debit/credit card or UPI.',
      ),
      StepItem(
        number: 5,
        title: 'Receive PAN',
        description:
            'Receive your PAN via post (physical) or email (e-PAN). Track status using acknowledgment number.',
        actionUrl: 'https://tin.tin.nsdl.com/pantan/StatusTrack.html',
      ),
    ],
    estimatedTimeline: '15–20 working days (physical), instant (e-PAN)',
    fees: '₹107 (physical card) | ₹72 (e-PAN)',
    officialLink: 'https://tin.tin.nsdl.com/pantan/StatusTrack.html',
    helplineNumber: '1800-180-1961',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 3: Passport
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel passport = ServiceModel(
    id: 'passport',
    iconEmoji: '📘',
    category: ServiceCategory.identity,
    isAvailable: true,
    name: {
      'en': 'Passport',
      'hi': 'पासपोर्ट',
      'mr': 'पासपोर्ट',
      'ta': 'கடவுச்சீட்டு',
    },
    description: {
      'en':
          'An Indian Passport is an official travel document issued by the Ministry of External Affairs. It is mandatory for international travel and serves as a globally recognized proof of identity and citizenship.',
      'hi':
          'भारतीय पासपोर्ट विदेश मंत्रालय द्वारा जारी एक आधिकारिक यात्रा दस्तावेज है। यह अंतरराष्ट्रीय यात्रा के लिए अनिवार्य है और पहचान एवं नागरिकता के विश्व स्तर पर मान्यता प्राप्त प्रमाण के रूप में काम करता है।',
      'mr':
          'भारतीय पासपोर्ट हा परराष्ट्र मंत्रालयाने जारी केलेला अधिकृत प्रवास दस्तावेज आहे. आंतरराष्ट्रीय प्रवासासाठी हे अनिवार्य आहे आणि ओळख व नागरिकत्वाचा जागतिक पातळीवर मान्यताप्राप्त पुरावा म्हणून काम करते.',
      'ta':
          'இந்திய கடவுச்சீட்டு என்பது வெளியுறவு அமைச்சகத்தால் வழங்கப்படும் அதிகாரப்பூர்வ பயண ஆவணம். சர்வதேச பயணத்திற்கு இது கட்டாயமாகும் மற்றும் உலகளவில் அங்கீகரிக்கப்பட்ட அடையாளம் மற்றும் குடியுரிமை சான்றாக செயல்படுகிறது.',
    },
    eligibilityCriteria: [
      'Must be an Indian citizen',
      'No pending criminal charges or court orders restricting travel',
      'Minors can apply with both parents\' consent',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Aadhaar Card',
        description: 'UIDAI Aadhaar for identity and address verification',
      ),
      DocumentItem(
        name: 'Birth Certificate or 10th Certificate',
        description: 'For proof of date of birth and place of birth',
      ),
      DocumentItem(
        name: 'Address Proof (any one)',
        description:
            'Aadhaar, Voter ID, Utility Bill, Bank statement, Driving License',
      ),
      DocumentItem(
        name: 'Passport-size Photographs',
        description: '2 recent color photographs (white background, 35x45mm)',
      ),
      DocumentItem(
        name: 'Old Passport (if renewal)',
        description: 'Required for renewal applications',
        isOptional: true,
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Register on Passport Seva Portal',
        description:
            'Create an account on passportindia.gov.in and log in to begin your application.',
        actionUrl: 'https://passportindia.gov.in',
      ),
      StepItem(
        number: 2,
        title: 'Fill Application Form',
        description:
            'Complete the online application form with personal, family, and address details.',
      ),
      StepItem(
        number: 3,
        title: 'Pay Application Fee',
        description:
            'Pay ₹1500 (normal, 36 pages) or ₹2000 (tatkal) online via net banking/UPI/card.',
      ),
      StepItem(
        number: 4,
        title: 'Book Appointment at PSK',
        description:
            'Schedule an appointment at your nearest Passport Seva Kendra (PSK) or Post Office Passport Seva Kendra (POPSK).',
      ),
      StepItem(
        number: 5,
        title: 'Visit PSK with Documents',
        description:
            'Carry all original documents and printed application form. Biometrics and photo will be taken.',
      ),
      StepItem(
        number: 6,
        title: 'Police Verification',
        description:
            'Local police will conduct address verification at your residence.',
      ),
      StepItem(
        number: 7,
        title: 'Passport Delivery',
        description:
            'Passport is delivered via Speed Post to your registered address after police clearance.',
      ),
    ],
    estimatedTimeline: '30–45 days (normal) | 7–14 days (tatkal)',
    fees: '₹1500 (normal, 36 pages) | ₹2000 (tatkal)',
    officialLink:
        'https://passportindia.gov.in/AppOnlineProject/statusTracking/trackApplicationStatus',
    helplineNumber: '1800-258-1800',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 4: Driving License
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel drivingLicense = ServiceModel(
    id: 'driving_license',
    iconEmoji: '🚗',
    category: ServiceCategory.identity,
    isAvailable: true,
    name: {
      'en': 'Driving License',
      'hi': 'ड्राइविंग लाइसेंस',
      'mr': 'वाहन परवाना',
      'ta': 'வாகன உரிமம்',
    },
    description: {
      'en':
          'A Driving License (DL) is a mandatory document required to legally operate a motor vehicle in India. It is issued by the Regional Transport Office (RTO) after passing required tests.',
      'hi':
          'ड्राइविंग लाइसेंस भारत में कानूनी रूप से मोटर वाहन चलाने के लिए आवश्यक अनिवार्य दस्तावेज है। यह क्षेत्रीय परिवहन कार्यालय (RTO) द्वारा आवश्यक परीक्षण पास करने के बाद जारी किया जाता है।',
      'mr':
          'वाहन परवाना हा भारतात कायदेशीररित्या मोटार वाहन चालवण्यासाठी आवश्यक अनिवार्य दस्तावेज आहे. आवश्यक चाचण्या उत्तीर्ण केल्यानंतर प्रादेशिक परिवहन कार्यालयाकडून (RTO) हे जारी केले जाते.',
      'ta':
          'வாகன உரிமம் (DL) என்பது இந்தியாவில் சட்டப்பூர்வமாக மோட்டார் வாகனம் ஓட்டுவதற்கு தேவையான கட்டாய ஆவணமாகும். தேவையான சோதனைகளில் தேர்ச்சி பெற்ற பிறகு பிராந்திய போக்குவரத்து அலுவலகத்தால் (RTO) வழங்கப்படுகிறது.',
    },
    eligibilityCriteria: [
      'Age 16+ for gearless/upto 50cc vehicles (with parental consent)',
      'Age 18+ for all other motor vehicles',
      'Age 20+ for transport/commercial vehicles',
      'Must pass medical fitness test (Form 1)',
      'Must pass learner\'s license written test',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Aadhaar Card',
        description: 'For identity and address verification',
      ),
      DocumentItem(
        name: 'Age Proof (any one)',
        description:
            'Birth Certificate, School Leaving Certificate, Aadhaar, PAN Card',
      ),
      DocumentItem(
        name: 'Address Proof (any one)',
        description: 'Aadhaar, Voter ID, Utility Bill, Passport',
      ),
      DocumentItem(
        name: 'Passport-size Photographs',
        description: '3 recent color passport photographs',
      ),
      DocumentItem(
        name: 'Form 1 — Medical Certificate',
        description:
            'Medical fitness certificate from a registered medical practitioner',
      ),
      DocumentItem(
        name: 'Learner\'s License',
        description: 'Required before applying for permanent DL',
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Apply for Learner\'s License (LL)',
        description:
            'Register on parivahan.gov.in, fill the LL application, pay fees, and appear for online/offline test at RTO.',
        actionUrl: 'https://sarathi.parivahan.gov.in',
      ),
      StepItem(
        number: 2,
        title: 'Practice for 30 Days',
        description:
            'Practice driving for a minimum of 30 days after obtaining Learner\'s License before applying for permanent DL.',
      ),
      StepItem(
        number: 3,
        title: 'Apply for Driving License',
        description:
            'Apply online on the Sarathi portal after 30 days, book an appointment at your RTO for driving test.',
      ),
      StepItem(
        number: 4,
        title: 'Appear for Driving Test',
        description:
            'Visit the RTO on your appointment date with originals. Pass the driving test conducted by an RTO officer.',
      ),
      StepItem(
        number: 5,
        title: 'Collect Driving License',
        description:
            'DL is dispatched via Speed Post to your registered address within 7 working days of passing the test.',
      ),
    ],
    estimatedTimeline: '30–60 days (including LL holding period)',
    fees: '₹200–₹500 depending on vehicle class',
    officialLink:
        'https://sarathi.parivahan.gov.in/sarathiservice/statusOfApplication.do',
    helplineNumber: '0120-4925505',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 5: Land Records
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel landRecords = ServiceModel(
    id: 'land_records',
    iconEmoji: '🗺️',
    category: ServiceCategory.property,
    isAvailable: true,
    name: {
      'en': 'Land Records',
      'hi': 'भूमि अभिलेख',
      'mr': 'जमीन नोंदी',
      'ta': 'நில பதிவுகள்',
    },
    description: {
      'en':
          'Land Records (Khata/Khasra/RoR) are official government records documenting land ownership, area, and use. Digital land records can be viewed and downloaded from state portals.',
      'hi':
          'भूमि अभिलेख (खाता/खसरा/RoR) आधिकारिक सरकारी रिकॉर्ड हैं जो भूमि स्वामित्व, क्षेत्र और उपयोग का दस्तावेजीकरण करते हैं। डिजिटल भूमि अभिलेख राज्य पोर्टल से देखे और डाउनलोड किए जा सकते हैं।',
      'mr':
          'जमीन नोंदी (खाता/खसरा/RoR) या अधिकृत सरकारी नोंदी आहेत ज्या जमीन मालकी, क्षेत्रफळ आणि वापर दस्तऐवजीकरण करतात. डिजिटल जमीन नोंदी राज्य पोर्टलवरून पाहता आणि डाउनलोड करता येतात.',
      'ta':
          'நில பதிவுகள் (கட்டா/கஷ்ரா/RoR) என்பவை நில உரிமை, பரப்பளவு மற்றும் பயன்பாட்டை ஆவணப்படுத்தும் அதிகாரப்பூர்வ அரசு பதிவுகள். மாண்டம் போர்டல்களில் இருந்து டிஜிட்டல் நில பதிவுகளை பார்க்கலாம் மற்றும் பதிவிறக்கலாம்.',
    },
    eligibilityCriteria: [
      'Property owner or legal heir',
      'Any citizen can view public land records',
      'Mutation (name transfer) requires ownership proof',
      'Court order or succession certificate needed for disputed land',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Sale Deed / Title Deed',
        description:
            'Registered sale deed establishing ownership of the property',
      ),
      DocumentItem(
        name: 'Previous Land Records',
        description: 'Old Khata/Khasra/Patta documents from previous owner',
        isOptional: true,
      ),
      DocumentItem(
        name: 'Aadhaar Card',
        description: 'For identity verification during mutation',
      ),
      DocumentItem(
        name: 'Property Tax Receipts',
        description: 'Latest property tax payment receipts',
        isOptional: true,
      ),
      DocumentItem(
        name: 'Survey Number / Plot Number',
        description:
            'Required to search and view land records on state portals',
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Visit State Land Records Portal',
        description:
            'Go to your state\'s Bhulekh/Bhu-Naksha portal (e.g., bhulekh.up.gov.in, mahabhunaksha.gov.in).',
        actionUrl: 'https://bhulekh.gov.in',
      ),
      StepItem(
        number: 2,
        title: 'Enter Survey or Plot Number',
        description:
            'Enter the district, tehsil, village, and survey/Khasra/plot number to fetch land records.',
      ),
      StepItem(
        number: 3,
        title: 'View & Download Records',
        description:
            'View the Record of Rights (RoR / Khatauni) and download/print with a nominal fee.',
      ),
      StepItem(
        number: 4,
        title: 'Apply for Mutation (if needed)',
        description:
            'If you\'ve recently purchased land, apply for mutation (name change) at the tehsil/taluka office or online.',
      ),
      StepItem(
        number: 5,
        title: 'Field Verification & Update',
        description:
            'Revenue officer verifies documents and updates land records. Collect updated Khata/Khasra.',
      ),
    ],
    estimatedTimeline: 'Instant (view/download) | 15–30 days (mutation)',
    fees: '₹15–₹50 per page (varies by state)',
    officialLink: 'https://bhulekh.gov.in',
    helplineNumber: 'State Revenue Department helpline',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 6: Birth Certificate
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel birthCertificate = ServiceModel(
    id: 'birth_certificate',
    iconEmoji: '👶',
    category: ServiceCategory.identity,
    isAvailable: true,
    name: {
      'en': 'Birth Certificate',
      'hi': 'जन्म प्रमाण पत्र',
      'mr': 'जन्म दाखला',
      'ta': 'பிறப்பு சான்றிதழ்',
    },
    description: {
      'en':
          'A Birth Certificate is an official document recording a person\'s birth, date, place, and parentage. It is a foundational identity document required for school admission, passports, and other government services.',
      'hi':
          'जन्म प्रमाण पत्र एक आधिकारिक दस्तावेज है जो व्यक्ति के जन्म, तिथि, स्थान और माता-पिता का रिकॉर्ड करता है। यह स्कूल प्रवेश, पासपोर्ट और अन्य सरकारी सेवाओं के लिए आवश्यक मूलभूत पहचान दस्तावेज है।',
      'mr':
          'जन्म दाखला हा एक अधिकृत दस्तावेज आहे जो व्यक्तीचा जन्म, तारीख, ठिकाण आणि पालकत्व नोंदवतो. शाळेत प्रवेश, पासपोर्ट आणि इतर सरकारी सेवांसाठी हे मूलभूत ओळख दस्तावेज आवश्यक आहे.',
      'ta':
          'பிறப்பு சான்றிதழ் என்பது ஒருவரின் பிறப்பு, தேதி, இடம் மற்றும் பெற்றோர் விவரங்களை பதிவு செய்யும் அதிகாரப்பூர்வ ஆவணமாகும். பள்ளி சேர்க்கை, கடவுச்சீட்டு மற்றும் பிற அரசு சேவைகளுக்கு இது அடிப்படை அடையாள ஆவணமாகும்.',
    },
    eligibilityCriteria: [
      'All Indian citizens — any age (registration can be done at any time)',
      'Births must be registered within 21 days to avoid late fees',
      'Delayed registration (after 1 year) requires a magistrate order',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Hospital Discharge Summary',
        description:
            'Discharge summary or birth slip from the hospital where birth occurred',
      ),
      DocumentItem(
        name: 'Parents\' Aadhaar Cards',
        description: 'Both father\'s and mother\'s Aadhaar for identification',
      ),
      DocumentItem(
        name: 'Marriage Certificate',
        description: 'Parents\' marriage certificate for legitimacy',
        isOptional: true,
      ),
      DocumentItem(
        name: 'Affidavit on Stamp Paper',
        description:
            'Required for delayed registration (beyond 1 year from birth)',
        isOptional: true,
      ),
      DocumentItem(
        name: 'Address Proof',
        description:
            'Proof of address for parents (utility bill, Aadhaar, Voter ID)',
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Hospital Registration (Newborns)',
        description:
            'The hospital/nursing home registers the birth with the local municipal authority automatically within 21 days.',
      ),
      StepItem(
        number: 2,
        title: 'Apply at Municipal Office or Online',
        description:
            'Visit your municipal corporation/gram panchayat office or apply on crsorgi.gov.in for a birth certificate.',
        actionUrl: 'https://crsorgi.gov.in',
      ),
      StepItem(
        number: 3,
        title: 'Submit Required Documents',
        description:
            'Submit hospital slip, parents\' Aadhaar, and other required documents at the registrar\'s office.',
      ),
      StepItem(
        number: 4,
        title: 'Pay Certificate Fee',
        description:
            'Registration is free within 21 days. A fee of ₹50–₹100 applies for delayed registration.',
      ),
      StepItem(
        number: 5,
        title: 'Collect Birth Certificate',
        description:
            'Collect the digitally signed Birth Certificate from the office or download from the state civil registration portal.',
      ),
    ],
    estimatedTimeline:
        '7–21 days (on-time) | 30–60 days (delayed registration)',
    fees: 'Free (within 21 days) | ₹50–₹100 (delayed)',
    officialLink: 'https://crsorgi.gov.in',
    helplineNumber: 'Local municipal/gram panchayat office',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 7: Ration Card
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel rationCard = ServiceModel(
    id: 'ration_card',
    iconEmoji: '🌾',
    category: ServiceCategory.welfare,
    isAvailable: true,
    name: {
      'en': 'Ration Card',
      'hi': 'राशन कार्ड',
      'mr': 'रेशन कार्ड',
      'ta': 'ரேஷன் அட்டை',
    },
    description: {
      'en':
          'A Ration Card is an official document issued by state governments to eligible families to receive subsidized food grains through the Public Distribution System (PDS). It also serves as proof of identity and address.',
      'hi':
          'राशन कार्ड राज्य सरकारों द्वारा पात्र परिवारों को सार्वजनिक वितरण प्रणाली (PDS) के माध्यम से सब्सिडी वाले खाद्यान्न प्राप्त करने के लिए जारी किया गया आधिकारिक दस्तावेज है।',
      'mr':
          'रेशन कार्ड हे राज्य सरकारांनी सार्वजनिक वितरण प्रणाली (PDS) द्वारे सबसिडी असलेले अन्नधान्य मिळवण्यासाठी पात्र कुटुंबांना जारी केलेले अधिकृत दस्तावेज आहे.',
      'ta':
          'ரேஷன் அட்டை என்பது பொது விநியோக முறை (PDS) மூலம் மானிய உணவு தானியங்களை பெறுவதற்கு தகுதியான குடும்பங்களுக்கு மாநில அரசுகளால் வழங்கப்படும் அதிகாரப்பூர்வ ஆவணமாகும்.',
    },
    eligibilityCriteria: [
      'Indian family below income threshold (Priority Household/Antyodaya category)',
      'Annual family income below ₹1 lakh (urban) / ₹60,000 (rural) — varies by state',
      'Should not already be a beneficiary under another ration card in any state',
      'Family must have a fixed residence address',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Family Photograph',
        description:
            'Group photograph of all family members applying for the ration card',
      ),
      DocumentItem(
        name: 'Aadhaar Card of All Members',
        description: 'Aadhaar cards of every family member to be included',
      ),
      DocumentItem(
        name: 'Income Certificate',
        description:
            'Certificate from Tehsildar/Gram Panchayat proving family income below threshold',
      ),
      DocumentItem(
        name: 'Address Proof',
        description:
            'Electricity bill, water bill, or rent agreement for proof of residence',
      ),
      DocumentItem(
        name: 'Bank Account Details',
        description:
            'Bank passbook/account for direct subsidy transfer under DBT scheme',
      ),
      DocumentItem(
        name: 'Gas Connection Details',
        description: 'LPG connection number if applicable',
        isOptional: true,
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Apply via State Food Department Portal',
        description:
            'Visit your state\'s food & civil supplies portal (e.g., nfsa.gov.in or state-specific portal) to apply online.',
        actionUrl: 'https://nfsa.gov.in',
      ),
      StepItem(
        number: 2,
        title: 'Fill Family Details',
        description:
            'Enter head of household details and add all family members with their Aadhaar numbers.',
      ),
      StepItem(
        number: 3,
        title: 'Upload Required Documents',
        description:
            'Upload family photo, Aadhaar copies of all members, income certificate, and address proof.',
      ),
      StepItem(
        number: 4,
        title: 'Field Verification',
        description:
            'A field officer visits your home to verify address, family members, and income status.',
      ),
      StepItem(
        number: 5,
        title: 'Ration Card Issued',
        description:
            'Upon verification, the ration card is generated and delivered to your address or made available at the fair price shop.',
      ),
    ],
    estimatedTimeline: '15–30 days',
    fees: 'Free',
    officialLink: 'https://nfsa.gov.in/portal/ration_card_status',
    helplineNumber: '1967 / 14445',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 8: Senior Citizen Pension
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel seniorCitizenPension = ServiceModel(
    id: 'senior_citizen_pension',
    iconEmoji: '👴',
    category: ServiceCategory.welfare,
    isAvailable: true,
    name: {
      'en': 'Senior Citizen Pension',
      'hi': 'वृद्धावस्था पेंशन',
      'mr': 'वृद्धापकाळ निवृत्तीवेतन',
      'ta': 'முதியோர் ஓய்வூதியம்',
    },
    description: {
      'en':
          'The National Social Assistance Programme (NSAP) — Indira Gandhi National Old Age Pension Scheme (IGNOAPS) provides monthly pension to elderly citizens aged 60+ from Below Poverty Line (BPL) families.',
      'hi':
          'राष्ट्रीय सामाजिक सहायता कार्यक्रम (NSAP) — इंदिरा गांधी राष्ट्रीय वृद्धावस्था पेंशन योजना (IGNOAPS) गरीबी रेखा से नीचे (BPL) परिवारों के 60 वर्ष से अधिक आयु के बुजुर्ग नागरिकों को मासिक पेंशन प्रदान करती है।',
      'mr':
          'राष्ट्रीय सामाजिक सहाय्य कार्यक्रम (NSAP) — इंदिरा गांधी राष्ट्रीय वृद्धापकाळ निवृत्तीवेतन योजना (IGNOAPS) दारिद्र्यरेषेखालील (BPL) कुटुंबातील 60 वर्षांवरील वृद्ध नागरिकांना मासिक निवृत्तीवेतन देते.',
      'ta':
          'தேசிய சமூக உதவித் திட்டம் (NSAP) — இந்திரா காந்தி தேசிய முதியோர் ஓய்வூதியத் திட்டம் (IGNOAPS) வறுமைக் கோட்டிற்கு கீழே (BPL) உள்ள குடும்பங்களில் 60 வயதுக்கு மேற்பட்ட முதியோர்களுக்கு மாதாந்திர ஓய்வூதியம் வழங்குகிறது.',
    },
    eligibilityCriteria: [
      'Age 60 years or above (80+ receives higher pension under NOAPS)',
      'Indian citizen',
      'Must be from Below Poverty Line (BPL) or low-income household',
      'Should not be receiving pension from any other central/state government scheme',
      'Must have a valid bank account (for DBT)',
    ],
    requiredDocuments: [
      DocumentItem(
        name: 'Age Proof (any one)',
        description:
            'Birth Certificate, 10th Marksheet, Aadhaar, Voter ID, School Leaving Certificate',
      ),
      DocumentItem(
        name: 'Aadhaar Card',
        description: 'Mandatory for identity verification and DBT linkage',
      ),
      DocumentItem(
        name: 'Bank Account Passbook',
        description:
            'Bank passbook showing account number and IFSC for direct benefit transfer',
      ),
      DocumentItem(
        name: 'Income Certificate',
        description:
            'BPL certificate or income certificate from Tehsildar/Gram Panchayat',
      ),
      DocumentItem(
        name: 'Residence Proof',
        description:
            'Aadhaar, Voter ID, or utility bill showing current address',
      ),
      DocumentItem(
        name: 'Photograph',
        description: '2 recent passport-size color photographs',
      ),
    ],
    steps: [
      StepItem(
        number: 1,
        title: 'Visit District Social Welfare Office',
        description:
            'Visit your nearest District Social Welfare Office or apply via the state portal or Common Service Centre (CSC).',
        actionUrl: 'https://nsap.nic.in',
      ),
      StepItem(
        number: 2,
        title: 'Fill Pension Application Form',
        description:
            'Obtain and fill the application form (Form A under IGNOAPS) with personal, family, and bank details.',
      ),
      StepItem(
        number: 3,
        title: 'Attach Required Documents',
        description:
            'Attach age proof, Aadhaar, income/BPL certificate, bank passbook, address proof, and photographs.',
      ),
      StepItem(
        number: 4,
        title: 'Verification by Officer',
        description:
            'A social welfare officer verifies income, age, and BPL status through field visit and document review.',
      ),
      StepItem(
        number: 5,
        title: 'Pension Sanctioned',
        description:
            'Pension is sanctioned by the district officer upon successful verification.',
      ),
      StepItem(
        number: 6,
        title: 'Monthly Credit to Bank Account',
        description:
            'Monthly pension (₹200–₹500 central share + state top-up) is directly credited to your Aadhaar-linked bank account.',
      ),
    ],
    estimatedTimeline: '30–90 days',
    fees: 'Free',
    officialLink: 'https://nsap.nic.in/pensionStatus.do',
    helplineNumber: '1800-111-555',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 9: Income Tax / ITR Filing
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel incomeTax = ServiceModel(
    id: 'income_tax',
    iconEmoji: '📈',
    category: ServiceCategory.finance,
    isAvailable: true,
    name: {
      'en': 'Income Tax Return (ITR)',
      'hi': 'आयकर रिटर्न (ITR)',
      'mr': 'आयकर रिटर्न (ITR)',
      'ta': 'வருமான வரி கணக்கு (ITR)',
    },
    description: {
      'en':
          'Income Tax Return is a form filed globally by taxpayers with the Income Tax Department declaring their income, deductions, and tax payments. It is mandatory for individuals earning above the basic exemption limit.',
      'hi':
          'आयकर रिटर्न आयकर विभाग के पास करदाताओं द्वारा दाखिल किया जाने वाला एक फॉर्म है जो उनकी आय, कटौतियों और कर भुगतानों की घोषणा करता है।',
      'mr':
          'आयकर रिटर्न हा करदात्यांनी आयकर विभागाकडे भरलेला फॉर्म आहे जो त्यांचे उत्पन्न, वजावट आणि कर भरणे घोषित करतो.',
      'ta':
          'வருமான வரி அறிக்கை என்பது வரி செலுத்துவோர் தங்கள் வருமானம், பிடித்தங்கள் மற்றும் வரி செலுத்தல்களை அறிவிக்கும் படிவமாகும்.',
    },
    eligibilityCriteria: [
      'Individuals with gross total income exceeding ₹2.5 Lakhs (varies by age/regime)',
      'Companies or firms, regardless of profit or loss',
      'Individuals wanting to claim an income tax refund',
    ],
    requiredDocuments: [
      DocumentItem(name: 'PAN Card', description: 'Mandatory for filing ITR'),
      DocumentItem(name: 'Aadhaar Card', description: 'Must be linked to PAN'),
      DocumentItem(
          name: 'Form 16',
          description: 'Issued by employer for salaried individuals'),
      DocumentItem(
          name: 'Bank Statements',
          description: 'For interest income and transaction proof'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'Register on e-Filing Portal',
          description:
              'Create an account on the Income Tax e-Filing portal using PAN.',
          actionUrl: 'https://www.incometax.gov.in'),
      StepItem(
          number: 2,
          title: 'Link Aadhaar',
          description:
              'Ensure your Aadhaar is linked to your PAN before filing.'),
      StepItem(
          number: 3,
          title: 'Fill Applicable ITR Form',
          description:
              'Select and fill the appropriate form (ITR-1, 2, 3, 4, etc.) based on income sources.'),
      StepItem(
          number: 4,
          title: 'Verify Details',
          description:
              'e-Verify your return using Aadhaar OTP, Net Banking, or send a physical copy to CPC.'),
    ],
    estimatedTimeline: 'Instant (Filing) | 1-3 months (Processing & Refund)',
    fees: 'Free (Late filing penalties apply)',
    officialLink: 'https://tin.tin.nsdl.com/oltas/refundstatuslogin.html',
    helplineNumber: '1800 103 0025',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 10: Voter ID / EPIC Card
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel voterId = ServiceModel(
    id: 'voter_id',
    iconEmoji: '🗳️',
    category: ServiceCategory.identity,
    isAvailable: true,
    name: {
      'en': 'Voter ID Card',
      'hi': 'मतदाता पहचान पत्र',
      'mr': 'मतदान कार्ड',
      'ta': 'வாக்காளர் அடையாள அட்டை',
    },
    description: {
      'en':
          'The Voter ID, also known as EPIC (Electors Photo Identity Card), is issued by the Election Commission of India. It serves primarily as an identity proof while casting votes.',
      'hi':
          'मतदाता पहचान पत्र, जिसे EPIC के नाम से भी जाना जाता है, भारत के चुनाव आयोग द्वारा जारी किया जाता है। यह मुख्य रूप से मतदान के दौरान पहचान प्रमाण के रूप में कार्य करता है।',
      'mr':
          'मतदान कार्ड, ज्याला EPIC म्हणूनही ओळखले जाते, भारताच्या निवडणूक आयोगाने जारी केले आहे. हे प्रामुख्याने मतदान करताना ओळख पुरावा म्हणून काम करते.',
      'ta':
          'வாக்காளர் அடையாள அட்டை இந்திய தேர்தல் ஆணையத்தால் வழங்கப்படுகிறது. இது வாக்களிக்கும் போது முதன்மையாக அடையாளச் சான்றாக செயல்படுகிறது.',
    },
    eligibilityCriteria: [
      'Indian citizen',
      'Age 18 years or above as of the qualifying date',
      'Ordinary resident of the polling area',
    ],
    requiredDocuments: [
      DocumentItem(
          name: 'Age Proof',
          description: 'Birth certificate, Aadhaar, PAN, or 10th certificate'),
      DocumentItem(
          name: 'Address Proof',
          description: 'Aadhaar, Utility bill, Bank passbook'),
      DocumentItem(
          name: 'Passport Photograph', description: 'Recent color photograph'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'Visit NVSP Portal',
          description:
              'Register on the National Voters Services Portal or Voter Helpline App.',
          actionUrl: 'https://voters.eci.gov.in'),
      StepItem(
          number: 2,
          title: 'Fill Form 6',
          description:
              'Fill Form 6 for registration of new voter/shifting from AC.'),
      StepItem(
          number: 3,
          title: 'Upload Documents',
          description: 'Upload age proof, address proof, and photograph.'),
      StepItem(
          number: 4,
          title: 'Track Application',
          description:
              'BLO will verify details. Track status using the reference ID.'),
    ],
    estimatedTimeline: '30-45 Days',
    fees: 'Free',
    officialLink: 'https://voters.eci.gov.in',
    helplineNumber: '1950',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 11: GST Registration
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel gstRegistration = ServiceModel(
    id: 'gst_registration',
    iconEmoji: '🏢',
    category: ServiceCategory.business,
    isAvailable: true,
    name: {
      'en': 'GST Registration',
      'hi': 'GST पंजीकरण',
      'mr': 'GST नोंदणी',
      'ta': 'GST பதிவு',
    },
    description: {
      'en':
          'Goods and Services Tax (GST) registration is mandatory for businesses whose turnover exceeds threshold limits, and for certain other specific categories like e-commerce operators.',
      'hi':
          'वस्तु एवं सेवा कर (GST) पंजीकरण उन व्यवसायों के लिए अनिवार्य है जिनका टर्नओवर सीमा से अधिक है और ई-कॉमर्स जैसे कुछ अन्य विशिष्ट श्रेणियों के लिए।',
      'mr':
          'वस्तू आणि सेवा कर (GST) नोंदणी अशा व्यवसायांसाठी अनिवार्य आहे ज्यांची उलाढाल थ्रेशोल्ड मर्यादेपेक्षा जास्त आहे.',
      'ta':
          'சரக்கு மற்றும் சேவைகள் வரி (GST) பதிவு என்பது வரம்புகளைத் தாண்டும் வணிகங்களுக்குக் கட்டாயமாகும்.',
    },
    eligibilityCriteria: [
      'Businesses with turnover exceeding ₹40 Lakh (Goods) / ₹20 Lakh (Services) (Varies for NE states)',
      'Inter-state suppliers and E-commerce aggregators',
      'Individuals holding service tax, VAT, or central excise registrations previously',
    ],
    requiredDocuments: [
      DocumentItem(
          name: 'PAN Card',
          description: 'PAN configuration of the business or applicant'),
      DocumentItem(
          name: 'Identity & Address Proof',
          description: 'Of Promoters/Directors with Photographs'),
      DocumentItem(
          name: 'Business Address Proof',
          description: 'Rent agreement or electricity bill'),
      DocumentItem(
          name: 'Bank Account Proof',
          description: 'Cancelled check or bank statement extract'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'Go to GST Portal',
          description:
              'Navigate to the official GST portal and click "New Registration".',
          actionUrl: 'https://www.gst.gov.in'),
      StepItem(
          number: 2,
          title: 'Fill Part-A',
          description:
              'Provide PAN, mobile number, and email. Verify with OTP to get TRN.'),
      StepItem(
          number: 3,
          title: 'Fill Part-B',
          description:
              'Login using TRN and fill business details, promoter info, authorized signatories, and places of business.'),
      StepItem(
          number: 4,
          title: 'Aadhaar Authentication',
          description:
              'Complete Aadhaar authentication for promoters to expedite approval.'),
      StepItem(
          number: 5,
          title: 'Receive GSTIN',
          description:
              'Upon successful verification, get the Registration Certificate containing GSTIN.'),
    ],
    estimatedTimeline: '3-7 Working Days',
    fees: 'Free (Government fees; professional charges may vary)',
    officialLink: 'https://services.gst.gov.in/services/checkregistration',
    helplineNumber: '1800 103 4786',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 12: EPFO / PF Account
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel epfoAccount = ServiceModel(
    id: 'epfo_account',
    iconEmoji: '💼',
    category: ServiceCategory.employment,
    isAvailable: true,
    name: {
      'en': 'EPF Member Portal (UAN)',
      'hi': 'EPF सदस्य पोर्टल (UAN)',
      'mr': 'EPF सदस्य पोर्टल (UAN)',
      'ta': 'EPF உறுப்பினர் தளம் (UAN)',
    },
    description: {
      'en':
          'Employees\' Provident Fund (EPF) is a retirement benefit scheme for salaried employees. The UAN (Universal Account Number) links all PF accounts of a member.',
      'hi':
          'कर्मचारी भविष्य निधि (EPF) वेतनभोगी कर्मचारियों के लिए सेवानिवृत्ति लाभ योजना है।',
      'mr':
          'कर्मचारी भविष्य निर्वाह निधी (EPF) ही पगारदार कर्मचाऱ्यांसाठी निवृत्ती लाभ योजना आहे.',
      'ta':
          'ஊழியர் வருங்கால வைப்பு நிதி (EPF) என்பது சம்பளம் பெறும் ஊழியர்களுக்கான ஓய்வூதிய பலன் திட்டமாகும்.',
    },
    eligibilityCriteria: [
      'Salaried employee under covered establishments',
      'Active Universal Account Number (UAN) linked with Aadhaar',
    ],
    requiredDocuments: [
      DocumentItem(name: 'UAN Number', description: 'Provided by the employer'),
      DocumentItem(
          name: 'Aadhaar Card', description: 'Must be seeded with UAN'),
      DocumentItem(
          name: 'PAN Card',
          description: 'For tax exemption on withdrawals > ₹50,000'),
      DocumentItem(
          name: 'Bank Account Detail',
          description: 'Account number and IFSC seeded to UAN'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'Activate UAN',
          description:
              'Visit UAN Member Portal to generate password and activate the UAN.',
          actionUrl:
              'https://unifiedportal-mem.epfindia.gov.in/memberinterface/'),
      StepItem(
          number: 2,
          title: 'Update KYC',
          description:
              'Ensure Aadhaar, PAN, and Bank details are approved by employer under Manage > KYC.'),
      StepItem(
          number: 3,
          title: 'Online Services',
          description:
              'Click Online Services to apply for Claim (Form-31, 19, 10C & 10D).'),
      StepItem(
          number: 4,
          title: 'Track Claim',
          description:
              'Track withdrawal status using the "Track Claim Status" tab.'),
    ],
    estimatedTimeline: '7-20 Days for Claim Settlement',
    fees: 'Free',
    officialLink: 'https://unifiedportal-mem.epfindia.gov.in/memberinterface/',
    helplineNumber: '14470',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 13: PM Kisan Samman Nidhi
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel pmKisan = ServiceModel(
    id: 'pm_kisan',
    iconEmoji: '🚜',
    category: ServiceCategory.agriculture,
    isAvailable: true,
    name: {
      'en': 'PM Kisan Samman Nidhi',
      'hi': 'प्रधानमंत्री किसान सम्मान निधि',
      'mr': 'पीएम किसान सन्मान निधी',
      'ta': 'பிஎம் கிசான் சம்மன் நிதி',
    },
    description: {
      'en':
          'PM Kisan is a central sector scheme providing income support of ₹6,000 per year in three equal installments to all landholding farmer families.',
      'hi':
          'पीएम किसान एक केंद्रीय क्षेत्र की योजना है जो सभी भूमिधारक किसान परिवारों को तीन समान किस्तों में ₹6,000 प्रति वर्ष की आय सहायता प्रदान करती है।',
      'mr':
          'पीएम किसान ही एक केंद्रीय क्षेत्रातील योजना आहे जी सर्व जमीनधारक शेतकरी कुटुंबांना तीन समान हप्त्यांमध्ये दरवर्षी ₹6,000 चे उत्पन्न समर्थन देते.',
      'ta':
          'பிஎம் கிசான் என்பது அனைத்து நிலமுள்ள விவசாய குடும்பங்களுக்கும் ஆண்டுக்கு ₹6,000 வருமான ஆதரவை வழங்கும் திட்டமாகும்.',
    },
    eligibilityCriteria: [
      'Landholding farmer families with cultivable land in their names',
      'Exclusion criteria applies for institutional landholders, tax payers, professionals, etc.',
    ],
    requiredDocuments: [
      DocumentItem(
          name: 'Aadhaar Card',
          description: 'Must be linked with active bank account'),
      DocumentItem(
          name: 'Land Holding Papers',
          description: 'Proof of land ownership (Khata/Khasra)'),
      DocumentItem(
          name: 'Bank Account',
          description: 'For direct benefit transfer (DBT)'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'New Farmer Registration',
          description:
              'Visit PM Kisan portal and select "New Farmer Registration".',
          actionUrl: 'https://pmkisan.gov.in'),
      StepItem(
          number: 2,
          title: 'Submit Details',
          description:
              'Enter Aadhaar, selection state, and complete captcha. Provide personal and land details.'),
      StepItem(
          number: 3,
          title: 'e-KYC Completion',
          description:
              'Complete mandatory e-KYC via OTP or CSC center for installment processing.'),
      StepItem(
          number: 4,
          title: 'Beneficiary Status',
          description:
              'Track your application and payment status using Aadhaar number.'),
    ],
    estimatedTimeline: 'Varies per installment schedule',
    fees: 'Free',
    officialLink: 'https://pmkisan.gov.in/BeneficiaryStatus_New.aspx',
    helplineNumber: '155261 / 1800115526',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 14: Ayushman Bharat / PMJAY
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel ayushmanBharat = ServiceModel(
    id: 'ayushman_bharat',
    iconEmoji: '🏥',
    category: ServiceCategory.health,
    isAvailable: true,
    name: {
      'en': 'Ayushman Bharat (PM-JAY)',
      'hi': 'आयुष्मान भारत (PM-JAY)',
      'mr': 'आयुष्मान भारत (PM-JAY)',
      'ta': 'ஆயுஷ்மான் பாரத் (PM-JAY)',
    },
    description: {
      'en':
          'Pradhan Mantri Jan Arogya Yojana is the world\'s largest health insurance scheme fully financed by the government. It provides a cover of ₹5 lakhs per family per year for secondary and tertiary care hospitalization.',
      'hi':
          'प्रधानमंत्री जन आरोग्य योजना पूरी तरह से सरकार द्वारा वित्तपोषित दुनिया की सबसे बड़ी स्वास्थ्य बीमा योजना है।',
      'mr':
          'प्रधानमंत्री जन आरोग्य योजना ही पूर्णपणे सरकारद्वारे वित्तपुरवठा केलेली जगातील सर्वात मोठी आरोग्य विमा योजना आहे.',
      'ta':
          'பிரதான் மந்திரி ஜன் ஆரோக்கிய யோஜனா என்பது அரசாங்கத்தால் முழுமையாக நிதியளிக்கப்படும் உலகின் மிகப்பெரிய சுகாதார காப்பீட்டு திட்டமாகும்.',
    },
    eligibilityCriteria: [
      'Deprived families identified via Socio-Economic Caste Census (SECC) 2011',
      'Families mapped under specific occupational categories (urban)',
      'No cap on family size, age, or gender',
    ],
    requiredDocuments: [
      DocumentItem(
          name: 'Aadhaar Card',
          description: 'For identity verification and e-KYC'),
      DocumentItem(
          name: 'Ration Card / PMJAY Letter',
          description: 'As proof of eligibility mapping'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'Check Eligibility',
          description:
              'Visit the "Am I Eligible" portal and input your mobile number or Ration Card.',
          actionUrl: 'https://beneficiary.nha.gov.in/'),
      StepItem(
          number: 2,
          title: 'Visit Empaneled Hospital/CSC',
          description:
              'Visit an authorized CSC or empaneled hospital with Aadhaar to verify identity.'),
      StepItem(
          number: 3,
          title: 'e-KYC and Approval',
          description:
              'Complete Aadhaar e-KYC. Authorities will approve the generation of the card.'),
      StepItem(
          number: 4,
          title: 'Get Ayushman Card',
          description:
              'Download your Ayushman card after approval for cashless hospital treatments.'),
    ],
    estimatedTimeline: 'Instant approval after e-KYC',
    fees: 'Free',
    officialLink: 'https://beneficiary.nha.gov.in/',
    helplineNumber: '14555',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 15: National Scholarship Portal
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel nationalScholarship = ServiceModel(
    id: 'national_scholarship',
    iconEmoji: '🎓',
    category: ServiceCategory.education,
    isAvailable: true,
    name: {
      'en': 'National Scholarship Portal',
      'hi': 'राष्ट्रीय छात्रवृत्ति पोर्टल (NSP)',
      'mr': 'राष्ट्रीय शिष्यवृत्ती पोर्टल (NSP)',
      'ta': 'தேசிய உதவித்தொகை போர்டல்',
    },
    description: {
      'en':
          'The National Scholarship Portal (NSP) is a one-stop portal providing various scholarships to eligible students from weaker sections, minorities, SC/ST, etc.',
      'hi':
          'NSP एक वन-स्टॉप पोर्टल है जो पात्र छात्रों को विभिन्न छात्रवृत्तियां प्रदान करता है।',
      'mr':
          'NSP हे एक वन-स्टॉप पोर्टल आहे जे पात्र विद्यार्थ्यांना विविध शिष्यवृत्ती प्रदान करते.',
      'ta':
          'தகுதியான மாணவர்களுக்கு பல்வேறு உதவித்தொகைகளை வழங்கும் ஒரு நிறுத்த தளம் NSP ஆகும்.',
    },
    eligibilityCriteria: [
      'Students pursuing studies in recognized schools/institutions',
      'Category-specific criteria (Minority, SC/ST, EWS, Disabled)',
      'Income limit varies per scheme (e.g. ₹2.5 Lakhs to ₹8 Lakhs)',
    ],
    requiredDocuments: [
      DocumentItem(name: 'Aadhaar Card', description: 'For e-KYC and DBT'),
      DocumentItem(
          name: 'Bank Account Passbook',
          description: 'Student\'s account seeded with Aadhaar'),
      DocumentItem(
          name: 'Income & Caste Certificate',
          description: 'Required for specific quota schemes'),
      DocumentItem(
          name: 'Previous Marks Sheet',
          description: 'Academic records of last passed exam'),
      DocumentItem(
          name: 'Fee Receipt / Bonafide',
          description: 'Issued by current institution'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'OTR Registration',
          description:
              'Complete One Time Registration (OTR) on the portal using Aadhaar authentication.',
          actionUrl: 'https://scholarships.gov.in'),
      StepItem(
          number: 2,
          title: 'Fill Application',
          description:
              'Login and fill personal, academic, and scheme details.'),
      StepItem(
          number: 3,
          title: 'Upload Documents',
          description:
              'Upload digitized copies of marks sheets, income certificate, and bank details.'),
      StepItem(
          number: 4,
          title: 'Institute Verification',
          description:
              'Submit the application so the respective institute nodal officer can verify it online.'),
    ],
    estimatedTimeline: 'Annually as per Academic Calendar',
    fees: 'Free',
    officialLink: 'https://scholarships.gov.in/fresh/trackStatus',
    helplineNumber: '0120 - 6619540',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE 16: MSME / Udyam Registration
  // ─────────────────────────────────────────────────────────────────────────
  static const ServiceModel msmeRegistration = ServiceModel(
    id: 'msme_registration',
    iconEmoji: '🏭',
    category: ServiceCategory.business,
    isAvailable: true,
    name: {
      'en': 'Udyam (MSME) Registration',
      'hi': 'उद्यम (MSME) पंजीकरण',
      'mr': 'उद्यम (MSME) नोंदणी',
      'ta': 'உத்யம் (MSME) பதிவு',
    },
    description: {
      'en':
          'Udyam Registration is a government portal for the registration of Micro, Small & Medium Enterprises (MSMEs). It provides various benefits including subsidies, easier loans, and intellectual property support.',
      'hi':
          'उद्यम पंजीकरण सूक्ष्म, लघु और मध्यम उद्यमों (MSMEs) के पंजीकरण के लिए एक सरकारी पोर्टल है।',
      'mr':
          'उद्यम नोंदणी हे सूक्ष्म, लघु आणि मध्यम उपक्रम (MSMEs) नोंदणीसाठी एक सरकारी पोर्टल आहे.',
      'ta':
          'உத்யம் பதிவு என்பது சிறு, குறு மற்றும் நடுத்தர நிறுவனங்களின் (MSMEs) பதிவுக்கான அரசு தளமாகும்.',
    },
    eligibilityCriteria: [
      'Any individual intending to establish a Micro, Small, or Medium Enterprise',
      'Classification depends on investment in plant/machinery and annual turnover',
    ],
    requiredDocuments: [
      DocumentItem(
          name: 'Aadhaar Card',
          description: 'Aadhaar of proprietor/director/managing partner'),
      DocumentItem(
          name: 'PAN & GSTIN',
          description: 'Mandatory PAN and GSTIN (if applicable)'),
      DocumentItem(
          name: 'Bank Account Details',
          description: 'Current account number and IFSC code'),
    ],
    steps: [
      StepItem(
          number: 1,
          title: 'Visit Udyam Portal',
          description:
              'Go to the official Udyam Registration portal. Select "For New Entrepreneurs".',
          actionUrl: 'https://udyamregistration.gov.in'),
      StepItem(
          number: 2,
          title: 'Aadhaar Verification',
          description: 'Enter Aadhaar number and Name, then validate via OTP.'),
      StepItem(
          number: 3,
          title: 'PAN Verification',
          description:
              'Select type of organization and provide PAN number. Details will be auto-fetched.'),
      StepItem(
          number: 4,
          title: 'Application Details',
          description:
              'Fill business addresses, bank details, NIC codes for activities, investment, and turnover (auto-filled if ITR filed).'),
      StepItem(
          number: 5,
          title: 'Final Submit',
          description:
              'Submit using OTP and receive the Udyam Registration Certificate online.'),
    ],
    estimatedTimeline: 'Instant to 3 Working Days',
    fees: 'Free',
    officialLink: 'https://udyamregistration.gov.in/Udyam_Verify.aspx',
    helplineNumber: '011-23063800',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Convenience accessors
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all services in the given [category].
  static List<ServiceModel> byCategory(ServiceCategory category) =>
      all.where((s) => s.category == category).toList();

  /// Returns a service by [id], or null if not found.
  static ServiceModel? byId(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns services matching a search [query] (case-insensitive, English names).
  static List<ServiceModel> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all.where((s) {
      final n = s.name['en']?.toLowerCase() ?? '';
      final d = s.description['en']?.toLowerCase() ?? '';
      return n.contains(q) || d.contains(q);
    }).toList();
  }
}
