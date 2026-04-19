import '../models/service_model.dart';

class NLPHandler {
  // Intent detection
  Map<String, dynamic> analyzeQuery(String query) {
    query = query.toLowerCase();
    
    // Detect service
    String? serviceId;
    if (query.contains('pension') || query.contains('old age')) {
      serviceId = 'pension';
    } else if (query.contains('ration') || query.contains('food')) {
      serviceId = 'ration';
    } else if (query.contains('aadhaar') || query.contains('fingerprint')) {
      serviceId = 'aadhaar';
    } else if (query.contains('farmer') || query.contains('subsidy') || query.contains('agriculture')) {
      serviceId = 'farmer';
    } else if (query.contains('health') || query.contains('insurance') || query.contains('ayushman')) {
      serviceId = 'health';
    }
    
    // Detect detail intent
    String intent = 'service_info';
    if (query.contains('document') || query.contains('need') || query.contains('require')) {
      intent = 'documents';
    } else if (query.contains('eligible') || query.contains('qualify') || query.contains('can i')) {
      intent = 'eligibility';
    } else if (query.contains('step') || query.contains('process') || query.contains('how to')) {
      intent = 'steps';
    } else if (serviceId == null) {
      intent = 'unknown';
    }
    
    return {'intent': intent, 'service': serviceId};
  }
  
  // Generate response based on intent and context
  String generateResponse(Map<String, dynamic> intent, 
                         GovernmentService? service) {
    
    if (service == null && intent['intent'] != 'unknown') {
      return "I can help with pension, ration, aadhaar, farming, or health services. Which one would you like to know about?";
    }

    switch (intent['intent']) {
      case 'service_info':
        return "The ${service?.title} provides ${service?.description}. "
               "Would you like to know about eligibility or required documents?";
               
      case 'documents':
        return "For ${service?.title}, you need:\n"
               "${service?.documents.map((doc) => "• $doc").join('\n')}\n"
               "Do you have all these documents?";
               
      case 'eligibility':
        return "To be eligible for ${service?.title}:\n"
               "${service?.eligibilityRules.map((e) => "✓ ${e.question}").join('\n')}";
               
      case 'steps':
        return "Here's the process for ${service?.title}:\n"
               "${service?.steps.map((s) => "${s.order}. ${s.title}").join('\n')}";
               
      default:
        return "I can help you with government services like pension, "
               "ration cards, subsidies, and scholarships. What do you need help with?";
    }
  }
}
