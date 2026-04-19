import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../gamification/widgets/achievement_badge.dart';
import '../../../providers/achievement_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CitizenProfileModal extends StatelessWidget {
  const CitizenProfileModal({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 30),
          FadeInDown(
            child: const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=a042581f4e29026704d'),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            auth.userName,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          Text(
            auth.isGuest
                ? 'Guest Access • Public Info'
                : 'Premium Citizen Tier • Verified',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Achievements (${achievementProvider.unlockedCount}/${achievementProvider.achievements.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievementProvider.achievements.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 15),
                  child: AchievementBadge(
                      achievement: achievementProvider.achievements[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          _buildSettingsTile(
              Icons.language_rounded, 'Language Settings', 'English (India)'),
          _buildSettingsTile(Icons.security_rounded, 'Security & Privacy',
              'Biometric Enabled'),
          _buildSettingsTile(Icons.help_outline_rounded, 'Help & Support',
              '24/7 Citizen Desk'),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              auth.logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/welcome', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('LOG OUT',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }
}
