import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/voice/screens/voice_complaint_screen.dart';
import '../../features/documents/screens/ai_document_scanner_screen.dart';
import '../../features/services/screens/scheme_discovery_screen.dart';
import '../../features/dashboard/screens/application_dashboard_screen.dart';
import '../../features/services/screens/offline_guidance_screen.dart';
import '../../features/profile/screens/citizen_profile_dashboard.dart';
import '../../features/recommendations/screens/recommendations_screen.dart';
import '../../features/services/screens/eligibility_checker_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';

import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/screens/main_dashboard_screen.dart';
import '../../features/voice/voice_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/onboarding/screens/first_launch_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/services/screens/service_detail_screen_v2.dart';
import '../../models/service_model.dart';
import '../../features/notifications/screens/notifications_screen_v2.dart';
import '../../features/services/screens/my_applications_screen.dart';
import '../../features/documents/screens/documents_screen.dart';
import '../../features/documents/screens/document_vault_screen.dart';
import '../../features/forms/screens/auto_fill_form_screen.dart';
import '../../features/forms/screens/smart_browser_screen.dart';
import '../../features/auto_form/screens/smart_form_screen.dart';
import '../../features/auto_form/screens/form_review_screen.dart';
import '../../features/auto_form/screens/guided_submission_screen.dart';
import '../../features/auto_form/models/auto_form_model.dart';
import '../../providers/document_vault_provider.dart';
import '../../widgets/navigation/cvi_bottom_nav.dart';

/// Route name constants — use these instead of raw strings.
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const dashboard = '/dashboard';
  static const voice = '/voice';
  static const services = '/services';
  static const serviceDetail = '/service/:id';
  static const eligibility = '/service/:id/eligibility';
  static const profile = '/profile';
  static const family = '/family';
  static const notifications = '/notifications';
  static const myApplications = '/my-applications';
  static const documents = '/documents';
  static const documentVault = '/document-vault';
  static const autoFillForm = '/auto-fill/:serviceId';
  static const smartBrowser = '/smart-browser';
  static const officeLocator = '/office-locator';
  static const voiceComplaint = '/voice-complaint';
  static const documentScanner = '/document-scanner';
  static const schemeDiscovery = '/scheme-discovery';
  static const appTracker = '/app-tracker';
  static const offlineGuidance = '/offline-guidance';
  static const citizenProfile = '/citizen-profile';
  static const recommendations = '/recommendations';
  static const smartForm = '/smart-form/:serviceId';
  static const formReview = '/form-review';
  static const guidedSubmit = '/guided-submit';
  // ── New routes ──────────────────────────────────────────────────────────
  static const settings = '/settings';
  static const profileEdit = '/profile-edit';

  static String serviceDetailPath(String id) => '/service/$id';
  static String eligibilityPath(String id) => '/service/$id/eligibility';
  static String autoFillFormPath(String serviceId) => '/auto-fill/$serviceId';
  static String smartFormPath(String serviceId) => '/smart-form/$serviceId';
}

/// Manages the GoRouter instance and listens to auth state for redirects.
class AppRouter {
  late final GoRouter router;
  static bool hasShownSplash = false;

  AppRouter(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: false,
      refreshListenable: authProvider,
      redirect: (context, state) {
        // CRITICAL: This redirect MUST be synchronous.
        // The router's refreshListenable fires on every notifyListeners() call.
        // If this function were async (using await), two concurrent redirect calls
        // could race: one navigates and unmounts the page while the other resumes
        // on the dead element → '_elements.contains(element)': is not true crash.
        final auth = context.read<AuthProvider>();
        final loc = state.matchedLocation;

        // 1. Enforce splash screen at least once per session
        if (!hasShownSplash) {
          if (loc != Routes.splash) return Routes.splash;
          return null; // Let the splash screen play
        }

        final isOnAuth = loc == Routes.auth;
        final isOnOnboarding = loc == Routes.onboarding;
        final isOnSplash = loc == Routes.splash;

        // seenOnboard is cached in AuthProvider during _init() — no await needed.
        final seenOnboard = auth.seenOnboard;

        // 2. Not Authenticated → Send to Auth or Onboarding
        if (!auth.isAuthenticated) {
          if (!isOnAuth && !isOnOnboarding && !isOnSplash) {
            return Routes.auth;
          }
          if (!seenOnboard && !isOnOnboarding && !isOnSplash) {
            return Routes.onboarding;
          }
          return null;
        }

        // 3. Authenticated → Redirect to Dashboard from any non-app screen.
        // The auth screen must NOT call context.go() itself; this redirect is
        // the sole driver of post-login navigation.
        if (isOnAuth || isOnSplash || isOnOnboarding) {
          return Routes.dashboard;
        }

        return null;
      },
      routes: [
        // ── Splash ────────────────────────────────────────────────────────
        GoRoute(
          path: Routes.splash,
          name: 'splash',
          pageBuilder: (context, state) => _buildPage(
            state,
            const SplashScreen(),
          ),
        ),

        // ── Onboarding ────────────────────────────────────────────────────
        GoRoute(
          path: Routes.onboarding,
          name: 'onboarding',
          pageBuilder: (context, state) => _buildPage(
            state,
            const FirstLaunchScreen(),
          ),
        ),

        // ── Auth ──────────────────────────────────────────────────────────
        GoRoute(
          path: Routes.auth,
          name: 'auth',
          pageBuilder: (context, state) => _buildPage(
            state,
            const AuthScreen(),
          ),
        ),

        // ── Shell: Dashboard + nested tabs ───────────────────────────────
        ShellRoute(
          builder: (context, state, child) => _AppShell(child: child),
          routes: [
            GoRoute(
              path: Routes.dashboard,
              name: 'dashboard',
              pageBuilder: (context, state) => _noTransitionPage(
                state,
                const MainDashboardScreen(key: PageStorageKey('dashboard')),
              ),
            ),
            GoRoute(
              path: Routes.services,
              name: 'services',
              pageBuilder: (context, state) => _noTransitionPage(
                state,
                const ServicesScreen(key: PageStorageKey('services')),
              ),
            ),
            GoRoute(
              path: Routes.profile,
              name: 'profile',
              pageBuilder: (context, state) => _noTransitionPage(
                state,
                const ProfileScreen(key: PageStorageKey('profile')),
              ),
            ),
            GoRoute(
              path: Routes.recommendations,
              name: 'recommendations',
              pageBuilder: (context, state) => _noTransitionPage(
                state,
                const RecommendationsScreen(
                    key: PageStorageKey('recommendations')),
              ),
            ),
          ],
        ),

        // ── Full-Screen Routes ───────────────────────────────────────────
        GoRoute(
          path: Routes.voice,
          name: 'voice',
          pageBuilder: (context, state) {
            final scheme = state.extra as ServiceModel?;
            return _buildPage(
              state,
              VoiceScreen(scheme: scheme),
            );
          },
        ),

        // ── Service Detail (full-screen, outside shell) ───────────────────
        GoRoute(
          path: Routes.serviceDetail,
          name: 'serviceDetail',
          pageBuilder: (context, state) {
            final service = state.extra as ServiceModel;
            return _buildPage(state, ServiceDetailScreenV2(service: service));
          },
        ),

        GoRoute(
          path: Routes.eligibility,
          name: 'eligibility',
          pageBuilder: (context, state) {
            final service = state.extra as ServiceModel;
            return _buildPage(
                state, EligibilityCheckerScreen(service: service));
          },
        ),

        GoRoute(
          path: Routes.notifications,
          name: 'notifications',
          pageBuilder: (context, state) => _buildPage(
            state,
            const NotificationsScreenV2(),
          ),
        ),

        // ── My Applications (full-screen) ──────────────────────────────────
        GoRoute(
          path: Routes.myApplications,
          name: 'myApplications',
          pageBuilder: (context, state) => _buildPage(
            state,
            const MyApplicationsScreen(),
          ),
        ),

        // ── Documents (full-screen) ────────────────────────────────────────
        GoRoute(
          path: Routes.documents,
          name: 'documents',
          pageBuilder: (context, state) => _buildPage(
            state,
            const DocumentsScreen(),
          ),
        ),

        // ── Document Vault (AI-powered) ──────────────────────────────────────
        GoRoute(
          path: Routes.documentVault,
          name: 'documentVault',
          pageBuilder: (context, state) => _buildPage(
            state,
            const DocumentVaultScreen(),
          ),
        ),

        GoRoute(
          path: Routes.autoFillForm,
          name: 'autoFillForm',
          pageBuilder: (context, state) {
            final serviceId = state.pathParameters['serviceId'] ?? '';
            final service = state.extra as ServiceModel?;
            return _buildPage(
              state,
              AutoFillFormScreen(
                serviceId: serviceId,
                service: service,
              ),
            );
          },
        ),

        // ── Smart Browser ───────────────────────────────────────────────────
        GoRoute(
          path: Routes.smartBrowser,
          name: 'smartBrowser',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final docs = context.read<DocumentVaultProvider>().documents;
            return _buildPage(
              state,
              SmartBrowserScreen(
                url: extra['url'] as String,
                title: extra['title'] as String,
                formData: extra['formData'] as Map<String, String>,
                documents: docs,
                languageCode: extra['languageCode'] as String? ??
                    context.read<LanguageProvider>().languageCode,
                initialTranslate: extra['initialTranslate'] as bool? ?? true,
              ),
            );
          },
        ),

        // ── Office Locator (full-screen) ───────────────────────────────────
        GoRoute(
          path: Routes.officeLocator,
          name: 'officeLocator',
          pageBuilder: (context, state) => _buildPage(
            state,
            const Scaffold(
                body: Center(child: Text('Office Locator Screen'))), // Temp
          ),
        ),
        GoRoute(
          path: Routes.voiceComplaint,
          name: 'voiceComplaint',
          pageBuilder: (context, state) =>
              _buildPage(state, const VoiceComplaintScreen()),
        ),
        GoRoute(
          path: Routes.documentScanner,
          name: 'documentScanner',
          pageBuilder: (context, state) =>
              _buildPage(state, const AIDocumentScannerScreen()),
        ),
        GoRoute(
          path: Routes.schemeDiscovery,
          name: 'schemeDiscovery',
          pageBuilder: (context, state) =>
              _buildPage(state, const SchemeDiscoveryScreen()),
        ),
        GoRoute(
          path: Routes.appTracker,
          name: 'appTracker',
          pageBuilder: (context, state) =>
              _buildPage(state, const ApplicationDashboardScreen()),
        ),
        GoRoute(
          path: Routes.offlineGuidance,
          name: 'offlineGuidance',
          pageBuilder: (context, state) =>
              _buildPage(state, const OfflineGuidanceScreen()),
        ),
        GoRoute(
          path: Routes.citizenProfile,
          name: 'citizenProfile',
          pageBuilder: (context, state) =>
              _buildPage(state, const CitizenProfileDashboard()),
        ),

        // ── Settings ──────────────────────────────────────────────────────
        GoRoute(
          path: Routes.settings,
          name: 'settings',
          pageBuilder: (context, state) =>
              _buildPage(state, const SettingsScreen()),
        ),

        // ── Edit Profile ───────────────────────────────────────────────────
        GoRoute(
          path: Routes.profileEdit,
          name: 'profileEdit',
          pageBuilder: (context, state) =>
              _buildPage(state, const EditProfileScreen()),
        ),

        // ── Smart AI Form (new auto_form module) ────────────────────────────
        GoRoute(
          path: Routes.smartForm,
          name: 'smartForm',
          pageBuilder: (context, state) {
            final serviceId = state.pathParameters['serviceId'] ?? '';
            final service = state.extra as ServiceModel?;
            return _buildPage(
              state,
              SmartFormScreen(
                serviceId: serviceId,
                service: service,
              ),
            );
          },
        ),

        // ── Form Review ────────────────────────────────────────────────────
        GoRoute(
          path: Routes.formReview,
          name: 'formReview',
          pageBuilder: (context, state) {
            final service = state.extra as ServiceModel?;
            return _buildPage(
              state,
              FormReviewScreen(service: service),
            );
          },
        ),

        // ── Guided Submission ──────────────────────────────────────────────
        GoRoute(
          path: Routes.guidedSubmit,
          name: 'guidedSubmit',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return _buildPage(
              state,
              GuidedSubmissionScreen(
                url: extra['url'] as String,
                title: extra['title'] as String,
                formData: extra['formData'] as Map<String, String>,
                submitSteps: (extra['submitSteps'] as List<dynamic>?)
                        ?.cast<SubmitStep>() ??
                    [],
                portalName: extra['portalName'] as String? ?? '',
              ),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => _ErrorScreen(error: state.error),
    );
  }

  /// Fade + slide-up transition for full-screen routes.
  static CustomTransitionPage<void> _buildPage(
          GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );

  /// Instant swap for bottom-nav shell tabs (no transition).
  static NoTransitionPage<void> _noTransitionPage(
          GoRouterState state, Widget child) =>
      NoTransitionPage<void>(key: state.pageKey, child: child);

  void dispose() {
    router.dispose();
  }
}

// ─── Bottom Navigation Shell ──────────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  static const _tabs = [
    Routes.dashboard, // 0
    Routes.services, // 1
    Routes.voice, // 2
    Routes.recommendations, // 3
    Routes.profile, // 4
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CVIBottomNav(
              currentIndex: currentIdx,
              onTap: (i) {
                if (i == 2) {
                  context.push(Routes.voice);
                } else {
                  context.go(_tabs[i]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Screen ─────────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFFF1744), size: 64),
              const SizedBox(height: 16),
              const Text('Page Not Found',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE6F1FF))),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown navigation error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8892A4), fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () => context.go(Routes.dashboard),
                icon: const Icon(Icons.home_rounded, color: Color(0xFF00F5FF)),
                label: const Text('Go Home',
                    style: TextStyle(color: Color(0xFF00F5FF))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
