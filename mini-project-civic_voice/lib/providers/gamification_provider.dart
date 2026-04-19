import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

class GamificationProvider with ChangeNotifier {
  int _civicScore = 350; // Starting score
  int _level = 1;
  
  // Demo Badges
  final List<Badge> _badges = [
    Badge(
      id: 'early_adopter',
      name: 'Early Bird',
      description: 'Joined the Civic App early.',
      icon: Icons.wb_sunny,
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Badge(
      id: 'doc_master',
      name: 'Doc Master',
      description: 'Uploaded 5 verified documents.',
      icon: Icons.description,
      isUnlocked: false,
    ),
    Badge(
      id: 'helper',
      name: 'Community Helper',
      description: 'Answered a community query.',
      icon: Icons.volunteer_activism,
      isUnlocked: false,
    ),
    Badge(
      id: 'family_first',
      name: 'Family Guardian',
      description: 'Added 3 family members.',
      icon: Icons.family_restroom,
      isUnlocked: false,
    ),
  ];

  int get civicScore => _civicScore;
  int get level => _level;
  List<Badge> get badges => _badges;

  // Actions to earn points
  void awardPoints(int points) {
    _civicScore += points;
    _checkLevelUp();
    notifyListeners();
  }

  void _checkLevelUp() {
    // Simple level logic: Level up every 100 points
    int newLevel = (_civicScore / 100).floor();
    if (newLevel > _level) {
      _level = newLevel;
      // In a real app, we'd trigger a celebration effect here
    }
  }

  void unlockBadge(String badgeId) {
    int index = _badges.indexWhere((b) => b.id == badgeId);
    if (index != -1 && !_badges[index].isUnlocked) {
      _badges[index] = Badge(
        id: _badges[index].id,
        name: _badges[index].name,
        description: _badges[index].description,
        icon: _badges[index].icon,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      awardPoints(50); // Bonus for badge
      notifyListeners();
    }
  }
}
