import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../models/user_model.dart';
import '../core/services/aws_amplify_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _sessionKey = 'cvi_user_session';

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isGuest = false;
  String? _error;
  // Cached once at startup so the GoRouter redirect stays synchronous.
  bool _seenOnboard = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isRealUser => isAuthenticated && !_isGuest;

  /// Whether the user has completed the onboarding flow.
  /// Read synchronously by the GoRouter redirect to avoid async races.
  bool get seenOnboard => _seenOnboard;

  AuthProvider() {
    _init();
  }

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    // No notifyListeners() here — we notify once at the end when everything is ready.
    try {
      debugPrint('[AuthProvider] _init: Checking Amplify initialization...');
      if (!AwsAmplifyService.isInitialized) {
        await AwsAmplifyService.initialize();
      }

      debugPrint('[AuthProvider] _init: Restoring session...');
      // Cache the onboarding flag synchronously for the router redirect.
      final prefs = await SharedPreferences.getInstance();
      _seenOnboard = prefs.getBool('cvi_onboarded') ?? false;

      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        debugPrint(
            '[AuthProvider] _init: User is signed in, fetching details...');
        final user = await Amplify.Auth.getCurrentUser();
        final attributes = await Amplify.Auth.fetchUserAttributes();
        _currentUser = await _fetchUserModel(user, attributes);
      } else {
        debugPrint(
            '[AuthProvider] _init: Not signed in, trying guest restore...');
        await _tryRestoreGuestSession();
      }
    } catch (e) {
      debugPrint('[AuthProvider] _init Error: $e');
      _error = e.toString();
    } finally {
      debugPrint('[AuthProvider] _init Finished. Loading = false');
      _isLoading = false;
      notifyListeners(); // Single notification once the full initial state is known.
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<UserModel> _fetchUserModel(
      AuthUser authUser, List<AuthUserAttribute> attributes) async {
    final prefs = await SharedPreferences.getInstance();

    String name = 'User';
    String email = '';
    String phone = '';

    for (var attr in attributes) {
      if (attr.userAttributeKey == AuthUserAttributeKey.name) {
        name = attr.value;
      }
      if (attr.userAttributeKey == AuthUserAttributeKey.email) {
        email = attr.value;
      }
      if (attr.userAttributeKey == AuthUserAttributeKey.phoneNumber) {
        phone = attr.value;
      }
    }

    final lang = prefs.getString('cvi_lang_${authUser.userId}') ?? 'en';

    return UserModel(
      id: authUser.userId,
      name: name.isEmpty ? 'User' : name,
      email: email,
      mobile: phone,
      language: lang,
      createdAt: DateTime
          .now(), // Cognito doesn't expose createdAt directly in basic attrs
      lastLoginAt: DateTime.now(),
    );
  }

  Future<void> _tryRestoreGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    final guestId = prefs.getString('$_sessionKey/guest_id');
    if (guestId != null) {
      _currentUser = UserModel(
        id: guestId,
        name: 'Guest',
        language: prefs.getString('$_sessionKey/lang') ?? 'en',
        createdAt: DateTime.now(),
        isGuest: true,
      );
      _isGuest = true;
    }
  }

  void _clearError() {
    _error = null;
  }

  // ─── Public Methods ────────────────────────────────────────────────────────

  /// Sign in with email and password via Amplify Cognito.
  Future<bool> loginWithEmail(String email, String password) async {
    _clearError();
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
          '[AuthProvider] loginWithEmail: Checking existing session for $email...');

      // Proactively check for an existing session to avoid "User already signed in" error
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        debugPrint(
            '[AuthProvider] loginWithEmail: Existing session found, performing global sign-out first...');
        await Amplify.Auth.signOut(
            options: const SignOutOptions(globalSignOut: true));
      }

      debugPrint(
          '[AuthProvider] loginWithEmail: Starting signIn for $email...');
      final result = await Amplify.Auth.signIn(
        username: email.trim(),
        password: password,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final attributes = await Amplify.Auth.fetchUserAttributes();
        _currentUser = await _fetchUserModel(user, attributes);
        _isGuest = false;
        return true;
      } else if (result.nextStep.signInStep == AuthSignInStep.confirmSignUp) {
        _error = 'Please confirm your email address before logging in.';
        return false;
      }

      _error = 'Login failed. Please check your credentials.';
      return false;
    } on AuthException catch (e) {
      debugPrint('[AuthProvider] loginWithEmail: AuthException: ${e.message}');

      // If we still get a "user is already signed in" error despite the proactive check,
      // try to clear it once and retry.
      if (e.message.contains('signed in')) {
        debugPrint(
            '[AuthProvider] loginWithEmail: Detected active session in exception. Retrying after global signOut...');
        try {
          await Amplify.Auth.signOut(
              options: const SignOutOptions(globalSignOut: true));
          // Perform one retry
          return await loginWithEmail(email, password);
        } catch (retryError) {
          _error =
              'Unable to sign in because another user is active on this device.';
          return false;
        }
      }

      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    await loginWithEmail(email, password);
  }

  /// Mock Google Sign-In (wire up Cognito Hosted UI later).
  Future<bool> loginWithGoogle() async {
    _clearError();
    _isLoading = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      _error =
          'Google Sign-In is not yet configured on this Cognito User Pool. Please use email or guest login.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// OTP-based sign-in via Amplify Custom Auth
  Future<bool> sendOTP(String mobile) async {
    _clearError();
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[AuthProvider] sendOTP: Checking existing session...');
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        debugPrint(
            '[AuthProvider] sendOTP: Existing session found, performing global sign-out first...');
        await Amplify.Auth.signOut(
            options: const SignOutOptions(globalSignOut: true));
      }

      // In a real Cognito setup, this requires Custom Auth Challenge triggers.
      // For this migration, we trigger a standard signIn which sends an SMS MFA if configured.
      await Amplify.Auth.signIn(username: mobile.trim());
      return true;
    } on AuthException catch (e) {
      if (e.message.contains('signed in')) {
        debugPrint(
            '[AuthProvider] sendOTP: Detected active session in exception. Retrying after global signOut...');
        try {
          await Amplify.Auth.signOut(
              options: const SignOutOptions(globalSignOut: true));
          return await sendOTP(mobile);
        } catch (_) {}
      }
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to send OTP. Check your number and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String mobile, String otp) async {
    _clearError();
    _isLoading = true;
    try {
      final result =
          await Amplify.Auth.confirmSignIn(confirmationValue: otp.trim());
      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final attributes = await Amplify.Auth.fetchUserAttributes();
        _currentUser = await _fetchUserModel(user, attributes);
        _isGuest = false;
        return true;
      }
      _error = 'Invalid OTP. Please try again.';
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'OTP verification failed.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user with Amplify Cognito.
  Future<bool> signup(
    String name,
    String email,
    String password, {
    String? phone,
    String? language,
  }) async {
    _clearError();
    _isLoading = true;
    try {
      final userAttributes = {
        AuthUserAttributeKey.name: name,
        AuthUserAttributeKey.email: email.trim(),
      };

      if (phone != null && phone.isNotEmpty) {
        userAttributes[AuthUserAttributeKey.phoneNumber] = '+91${phone.trim()}';
      }

      final result = await Amplify.Auth.signUp(
        username: email.trim(),
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      if (result.isSignUpComplete) {
        // Auto sign-in if possible, but usually requires confirmation
        return true;
      } else if (result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
        // Return a specific custom error string to inform the UI to open the OTP dialog
        _error = 'CONFIRM_SIGNUP_REQUIRED';
        return false;
      }

      _error = 'Registration failed. Please try again.';
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Let the user browse without signing in.
  Future<void> continueAsGuest() async {
    _clearError();
    final guest = UserModel.guest();
    _currentUser = guest;
    _isGuest = true;
    // Set state fully before persisting; notify once at the end.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_sessionKey/guest_id', guest.id);
    await prefs.setString('$_sessionKey/lang', guest.language);
    notifyListeners(); // Single notification — state fully settled.
  }

  /// Confirm a new user registration with the OTP sent to their email/phone
  Future<bool> confirmSignUp(String email, String code) async {
    _clearError();
    _isLoading = true;
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email.trim(),
        confirmationCode: code.trim(),
      );
      if (result.isSignUpComplete) {
        return true;
      }
      _error = 'Verification failed. Please try again.';
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred during verification.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out and clear stored session.
  Future<void> logout() async {
    try {
      if (!_isGuest) {
        await Amplify.Auth.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_sessionKey/guest_id');
      await prefs.remove('$_sessionKey/lang');
      _currentUser = null;
      _isGuest = false;
    } catch (_) {
      _currentUser = null;
      _isGuest = false;
    } finally {
      notifyListeners();
    }
  }

  /// Persist and apply a new language for the current user.
  Future<void> updateLanguage(String langCode) async {
    if (_currentUser == null) {
      return;
    }
    _currentUser = _currentUser!.copyWith(language: langCode);
    final prefs = await SharedPreferences.getInstance();
    if (_isGuest) {
      await prefs.setString('$_sessionKey/lang', langCode);
    } else {
      await prefs.setString('cvi_lang_${_currentUser!.id}', langCode);
    }
    notifyListeners();
  }

  /// Sends a password reset email via Amplify.
  Future<void> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email.trim());
    } catch (_) {
      // Silently fail — success message is always shown for security
    }
  }

  /// Call this when the onboarding flow completes to keep the in-memory
  /// [seenOnboard] cache in sync with the SharedPreferences value.
  void markOnboarded() {
    _seenOnboard = true;
    // No notifyListeners() needed \u2014 this doesn't affect routing directly;
    // the caller (FirstLaunchScreen) drives navigation itself via context.go.
  }

  // ─── Legacy API Stubs ───────────────────────────────────────────────────────

  /// Alias for currentUser?.id used by legacy screens.
  String? get userId => _currentUser?.id;

  /// Alias for [error] used by legacy screens.
  String? get errorMessage => _error;

  /// Display name of the current user.
  String get userName => _currentUser?.name ?? 'User';
}
