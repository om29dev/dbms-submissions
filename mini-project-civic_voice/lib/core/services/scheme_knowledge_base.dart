import '../../models/scheme_model.dart';

class SchemeKnowledgeBase {
  static final List<GovernmentScheme> schemes = [
    GovernmentScheme(
      id: 'pension',
      category: 'senior_citizens',
      names: {'en': 'Old Age Pension', 'hi': 'वृद्धावस्था पेंशन'},
      description: 'Monthly financial assistance for senior citizens.',
      benefits:
          'Eligible citizens receive ₹500-₹1,000/month directly in their bank account. Provides financial security, medical support, and dignity in old age.',
      helplineNumber: '1800-180-1551',
      officialWebsite: 'https://nsap.nic.in',
      applicationMode: 'Both',
      alternativeSchemeIds: ['ayushman'],
      eligibilityRules: [
        EligibilityRule(
            question: {'en': 'What is your age?', 'hi': 'आपकी आयु क्या है?'},
            parameter: 'age',
            operator: '>=',
            value: 60,
            explanation: {
              'en':
                  'Must be 60 years or older. If you are close to 60, prepare your documents now.',
              'hi':
                  '60 वर्ष या उससे अधिक आयु होनी चाहिए। यदि आप 60 के करीब हैं, तो अभी अपने दस्तावेज तैयार करें।'
            }),
        EligibilityRule(
            question: {
              'en': 'What is your annual family income?',
              'hi': 'आपकी वार्षिक पारिवारिक आय क्या है?'
            },
            parameter: 'income',
            operator: '<=',
            value: 200000,
            explanation: {
              'en':
                  'Income must be less than ₹2,00,000. Families with stable government income are excluded.',
              'hi':
                  'आय ₹2,00,000 से कम होनी चाहिए। स्थिर सरकारी आय वाले परिवार बाहर रखे गए हैं।'
            }),
      ],
      requiredDocuments: [
        SchemeDocument(name: {
          'en': 'Aadhaar Card',
          'hi': 'आधार कार्ड'
        }, reason: {
          'en': 'Used for age proof and biometric verification.',
          'hi': 'आयु प्रमाण और बायोमेट्रिक सत्यापन के लिए उपयोग किया जाता है।'
        }, howToGet: {
          'en': 'Visit nearest Aadhaar Seva Kendra with address proof.',
          'hi': 'पते के प्रमाण के साथ निकटतम आधार सेवा केंद्र पर जाएं।'
        }, verificationChecklist: [
          'Name matches bank account',
          'Age is 60+',
          'Mobile linked to Aadhaar'
        ]),
        SchemeDocument(name: {
          'en': 'Income Certificate',
          'hi': 'आय प्रमाण पत्र'
        }, reason: {
          'en': 'Verifies you are under the poverty threshold.',
          'hi': 'सत्यापित करता है कि आप गरीबी सीमा के नीचे हैं।'
        }, howToGet: {
          'en': 'Apply at Tahsildar office or online via E-Seva portal.',
          'hi':
              'तहसीलदार कार्यालय में या ई-सेवा पोर्टल के माध्यम से ऑनलाइन आवेदन करें।'
        }, verificationChecklist: [
          'Issued in last 6 months',
          'Signed by Tahsildar/SDO'
        ]),
      ],
      steps: [
        SchemeStep(number: 1, title: {
          'en': 'Document Preparation',
          'hi': 'दस्तावेज तैयारी'
        }, instruction: {
          'en':
              'Gather original Aadhaar, Income Certificate, and Bank Passbook.',
          'hi':
              'आधार, आय प्रमाण पत्र और बैंक पासबुक के मूल दस्तावेज़ एकत्र करें।'
        }, estimatedTime: {
          'en': '2-3 days',
          'hi': '2-3 दिन'
        }, prerequisites: [
          'Aadhaar',
          'Income Certificate'
        ]),
        SchemeStep(
            number: 2,
            title: {'en': 'Online Registration', 'hi': 'ऑनलाइन पंजीकरण'},
            instruction: {
              'en':
                  'Apply on the NSAP portal or visited nearest E-Seva centre.',
              'hi': 'NSAP पोर्टल पर आवेदन करें या निकटतम ई-सेवा केंद्र पर जाएं।'
            },
            estimatedTime: {'en': '45 minutes', 'hi': '45 मिनट'},
            location: {
              'en': 'Nearest E-Seva/CSC Centre',
              'hi': 'निकटतम ई-सेवा/सीएससी केंद्र'
            },
            officeHours: {
              'en': '10 AM - 5 PM',
              'hi': 'सुबह 10 बजे - शाम 5 बजे'
            },
            prerequisites: ['Step 1', 'Valid Mobile Number'],
            formUrl: 'https://nsap.nic.in/'),
        SchemeStep(number: 3, title: {
          'en': 'Verification',
          'hi': 'सत्यापन'
        }, instruction: {
          'en': 'Block Development Officer (BDO) will verify your documents.',
          'hi': 'खंड विकास अधिकारी (BDO) आपके दस्तावेजों का सत्यापन करेंगे।'
        }, estimatedTime: {
          'en': '15-20 days',
          'hi': '15-20 दिन'
        }, prerequisites: [
          'Step 2'
        ]),
      ],
    ),
    GovernmentScheme(
      id: 'ration',
      category: 'food_security',
      names: {'en': 'Ration Card (NFSA)', 'hi': 'राशन कार्ड'},
      description: 'Subsidized food grains for families under NFSA.',
      benefits:
          '35kg (AAY) or 5kg/person (PHH) of grains. Access to Kerosene and Sugar at subsidized rates.',
      helplineNumber: '1967',
      officialWebsite: 'https://nfsa.gov.in',
      applicationMode: 'Offline',
      alternativeSchemeIds: ['pm-kisan'],
      eligibilityRules: [
        EligibilityRule(
            question: {
              'en': 'Are you a resident of this state?',
              'hi': 'क्या आप इस राज्य के निवासी हैं?'
            },
            parameter: 'residence',
            operator: 'bool',
            value: true,
            explanation: {
              'en':
                  'Card is state-specific. Use "One Nation One Ration Card" if migrating.',
              'hi':
                  'कार्ड राज्य-विशिष्ट है। प्रवास के दौरान "वन नेशन वन राशन कार्ड" का उपयोग करें।'
            }),
      ],
      requiredDocuments: [
        SchemeDocument(name: {
          'en': 'Residence Proof',
          'hi': 'निवास प्रमाण'
        }, reason: {
          'en': 'Needed to prove you live in the operational area.',
          'hi':
              'यह साबित करने के लिए आवश्यक है कि आप परिचालन क्षेत्र में रहते हैं।'
        }, howToGet: {
          'en': 'Voter ID, Electricity bill, or Rental agreement.',
          'hi': 'वोटर आईडी, बिजली बिल, या रेंटल एग्रीमेंट।'
        }, verificationChecklist: [
          'Address matches current residence',
          'Name matches head of family'
        ]),
        SchemeDocument(name: {
          'en': 'Aadhaar (All family)',
          'hi': 'आधार (पूरा परिवार)'
        }, reason: {
          'en': 'Biometric linking for all beneficiaries is mandatory.',
          'hi': 'सभी लाभार्थियों के लिए बायोमेट्रिक लिंकिंग अनिवार्य है।'
        }, howToGet: {
          'en': 'Visit Aadhaar Kendra for missing members.',
          'hi': 'छूटे हुए सदस्यों के लिए आधार केंद्र पर जाएं।'
        }, verificationChecklist: [
          'All members listed',
          'Biometrics updated'
        ]),
      ],
      steps: [
        SchemeStep(
            number: 1,
            title: {'en': 'FCS Application', 'hi': 'FCS आवेदन'},
            instruction: {
              'en': 'Fill Form 1 at the Food and Civil Supplies office.',
              'hi': 'खाद्य और नागरिक आपूर्ति कार्यालय में फॉर्म 1 भरें।'
            },
            estimatedTime: {'en': '1 day', 'hi': '1 दिन'},
            location: {
              'en': 'District Food & Civil Supplies Office',
              'hi': 'जिला खाद्य और नागरिक आपूर्ति कार्यालय'
            },
            officeHours: {
              'en': '10:30 AM - 4 PM',
              'hi': 'सुबह 10:30 बजे - दोपहर 4 बजे'
            },
            formUrl: 'https://nfsa.gov.in/forms'),
        SchemeStep(number: 2, title: {
          'en': 'Field Verification',
          'hi': 'क्षेत्र सत्यापन'
        }, instruction: {
          'en': 'Inspector will visit your home to verify family composition.',
          'hi':
              'निरीक्षक परिवार की संरचना को सत्यापित करने के लिए आपके घर का दौरा करेंगे।'
        }, estimatedTime: {
          'en': '10-15 days',
          'hi': '10-15 दिन'
        }, prerequisites: [
          'Step 1'
        ]),
      ],
    ),
    GovernmentScheme(
      id: 'pm-kisan',
      category: 'farmers',
      names: {'en': 'PM-KISAN', 'hi': 'पीएम-किसान'},
      description: 'Income support of ₹6,000/year to landholding farmers.',
      benefits:
          'Direct benefit transfer of ₹2,000 every 4 months. Total ₹6,000 per year per farm family.',
      helplineNumber: '155261',
      officialWebsite: 'https://pmkisan.gov.in',
      applicationMode: 'Online',
      alternativeSchemeIds: ['ration'],
      eligibilityRules: [
        EligibilityRule(
            question: {
              'en': 'Do you own cultivable land?',
              'hi': 'क्या आपके पास कृषि योग्य भूमि है?'
            },
            parameter: 'land',
            operator: 'bool',
            value: true,
            explanation: {
              'en':
                  'You must be the legal owner of the land. Institutional landholders are excluded.',
              'hi':
                  'आपको भूमि का कानूनी मालिक होना चाहिए। संस्थागत भूमि धारकों को बाहर रखा गया है।'
            }),
      ],
      requiredDocuments: [
        SchemeDocument(name: {
          'en': 'Land Records (Pattadar Passbook)',
          'hi': 'भूमि रिकॉर्ड (पट्टादार पासबुक)'
        }, reason: {
          'en': 'Crucial for verifying your landholding size and ownership.',
          'hi':
              'आपके भूमि स्वामित्व और आकार को सत्यापित करने के लिए महत्वपूर्ण है।'
        }, howToGet: {
          'en':
              'Obtain from Meeseva (Telangana/AP), Bhulekh (UP), or local Revenue office.',
          'hi': 'मीसेवा, भूलेख या स्थानीय राजस्व कार्यालय से प्राप्त करें।'
        }, verificationChecklist: [
          'Owner name matches Aadhaar',
          'Survey number clearly visible'
        ]),
      ],
      steps: [
        SchemeStep(number: 1, title: {
          'en': 'Land Verification',
          'hi': 'भूमि सत्यापन'
        }, instruction: {
          'en': 'Get your land records digitized and verified by the Patwari.',
          'hi':
              'अपने भूमि रिकॉर्ड को डिजिटल करवाएं और पटवारी द्वारा सत्यापित करवाएं।'
        }, estimatedTime: {
          'en': '7 days',
          'hi': '7 दिन'
        }, location: {
          'en': 'Local Revenue Office / Patwari',
          'hi': 'स्थानीय राजस्व कार्यालय / पटवारी'
        }),
        SchemeStep(
            number: 2,
            title: {'en': 'Portal Registration', 'hi': 'पोर्टल पंजीकरण'},
            instruction: {
              'en':
                  'Self-register on PM-Kisan portal using Aadhaar and mobile.',
              'hi':
                  'आधार और मोबाइल का उपयोग करके पीएम-किसान पोर्टल पर स्व-पंजीकरण करें।'
            },
            estimatedTime: {'en': '30 mins', 'hi': '30 मिनट'},
            prerequisites: ['Step 1', 'Seed bank account with Aadhaar'],
            formUrl: 'https://pmkisan.gov.in/registration'),
      ],
    ),
    GovernmentScheme(
      id: 'land',
      category: 'food_security', // Using existing category for now
      names: {
        'en': 'Pradhan Mantri Awas Yojana',
        'hi': 'प्रधानमंत्री आवास योजना'
      },
      description: 'Housing for All by 2024.',
      benefits:
          'Financial assistance up to ₹1.2 Lakh (Rural) or ₹2.67 Lakh (Urban) for house construction.',
      helplineNumber: '011-23060484',
      officialWebsite: 'https://pmaymis.gov.in',
      applicationMode: 'Online',
      alternativeSchemeIds: [],
      eligibilityRules: [
        EligibilityRule(
            question: {
              'en': 'Do you own a pucca house?',
              'hi': 'क्या आपके पास पक्का घर है?'
            },
            parameter: 'land',
            operator: 'bool',
            value: false,
            explanation: {
              'en': 'Beneficiary must not own a pucca house anywhere in India.',
              'hi': 'लाभार्थी के पास भारत में कहीं भी पक्का घर नहीं होना चाहिए।'
            }),
      ],
      requiredDocuments: [
        SchemeDocument(
            name: {'en': 'Aadhaar Card', 'hi': 'आधार कार्ड'},
            reason: {'en': 'Identity proof.', 'hi': 'पहचान प्रमाण।'},
            howToGet: {'en': 'UIDAI', 'hi': 'यूआईडीएआई'},
            verificationChecklist: ['Valid ID']),
        SchemeDocument(name: {
          'en': 'Income Proof',
          'hi': 'आय प्रमाण'
        }, reason: {
          'en': 'To verify EWS/LIG status.',
          'hi': 'EWS/LIG स्थिति सत्यापित करने के लिए।'
        }, howToGet: {
          'en': 'Employer or Revenue Dept',
          'hi': 'नियोक्ता या राजस्व विभाग'
        }, verificationChecklist: [
          'Below income limit'
        ]),
      ],
      steps: [
        SchemeStep(
            number: 1,
            title: {'en': 'Online Application', 'hi': 'ऑनलाइन आवेदन'},
            instruction: {
              'en': 'Apply at CSC or PMAY website.',
              'hi': 'सीएससी या PMAY वेबसाइट पर आवेदन करें।'
            },
            estimatedTime: {'en': '30 mins', 'hi': '30 मिनट'},
            formUrl: 'https://pmaymis.gov.in'),
      ],
    ),
  ];

  static GovernmentScheme? getSchemeById(String id) {
    try {
      return schemes.firstWhere((GovernmentScheme s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<GovernmentScheme> getSchemesByCategory(String category) {
    return schemes.where((s) => s.category == category).toList();
  }

  static Map<String, List<GovernmentScheme>> getSchemesByCategories() {
    final Map<String, List<GovernmentScheme>> map = {};
    for (var scheme in schemes) {
      if (!map.containsKey(scheme.category)) {
        map[scheme.category] = [];
      }
      map[scheme.category]!.add(scheme);
    }
    return map;
  }

  static Map<String, String> getCategoryNames() {
    return {
      'senior_citizens': 'Senior Citizens',
      'students': 'Students',
      'farmers': 'Farmers',
      'health': 'Health',
      'food_security': 'Food Security',
    };
  }
}
