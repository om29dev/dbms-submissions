import 'dart:math';
import '../../models/queue_token_model.dart';

class QueueService {
  final List<QueueToken> _activeTokens = [];

  // Generate a mock token for a service
  QueueToken generateToken(String serviceName, String officeName) {
    final random = Random();
    final currentServing = random.nextInt(50) + 1;
    final tokenNumber = currentServing + random.nextInt(20) + 5; // 5-25 people ahead
    final minutesWait = (tokenNumber - currentServing) * 5; // 5 mins per person

    final token = QueueToken(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: serviceName,
      officeName: officeName,
      tokenNumber: tokenNumber,
      currentServing: currentServing,
      estimatedTime: DateTime.now().add(Duration(minutes: minutesWait)),
    );

    _activeTokens.add(token);
    return token;
  }

  // Get active token (simulated single token for demo)
  QueueToken? getActiveToken() {
    if (_activeTokens.isEmpty) return null;
    return _activeTokens.last;
  }

  // Cancel token
  void cancelToken() {
    if (_activeTokens.isNotEmpty) {
      _activeTokens.removeLast();
    }
  }
}
