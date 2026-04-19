import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../dashboard/screens/premium_dashboard_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../voice_interface/screens/voice_dashboard_screen.dart';
import '../../profile/profile_screen.dart';
import '../../../widgets/navigation/cvi_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Re-ordered to put Voice in the center
  final List<Widget> _pages = [
    const PremiumDashboardScreen(),
    const ServicesScreen(),
    const VoiceDashboardScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (authProvider.isAuthenticated &&
          userProvider.isGuest &&
          authProvider.userId != null) {
        userProvider.fetchUserProfile(authProvider.userId!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0C0A08),
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children:
                _pages, // I'll keep the existing `_pages` variable containing the screens.
          ),
          bottomNavigationBar: null,
          floatingActionButton: null,
          floatingActionButtonLocation: null,
        ),
        // Floating nav bar at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CVIBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
      ],
    );
  }
}
