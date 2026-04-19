import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_voice',
      title: 'First Word',
      description: 'You completed your first voice query!',
      icon: Icons.mic,
    ),
    Achievement(
      id: 'doc_ready',
      title: 'Doc Master',
      description: 'Successfully uploaded all required documents.',
      icon: Icons.description,
    ),
    Achievement(
      id: 'eligible_plus',
      title: 'Top Citizen',
      description: 'Attained a Civic Confidence Score above 90.',
      icon: Icons.star,
    ),
    Achievement(
      id: 'polyglot',
      title: 'Multilingual Support',
      description: 'Switched languages to explore services better.',
      icon: Icons.translate,
    ),
  ];

  List<Achievement> get achievements => _achievements;

  void unlockAchievement(String id) {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index].isUnlocked = true;
      notifyListeners();
    }
  }

  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;
}
