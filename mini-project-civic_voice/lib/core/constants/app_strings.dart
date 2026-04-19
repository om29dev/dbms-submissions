/// All UI string keys with their English source text.
/// Google Translate (via TranslationService) handles runtime translation.
/// Add new strings here to pre-translate them on language switch.
abstract class AppStrings {
  // ─── App Identity ──────────────────────────────────────────────────────────
  static const String appName    = 'Civic Voice';
  static const String appTagline = 'Your Voice, Your Government';
  static const String appVersion = '1.0.0';

  // ─── Legacy helper (kept for compatibility) ────────────────────────────────
  static String get(Map<String, String> map, String langCode) =>
      map[langCode] ?? map['en'] ?? '';

  // ─── Legacy per-key maps (kept for legacy screens that use AppStrings.X) ──
  static const Map<String, String> signIn         = {'en': 'Sign In'};
  static const Map<String, String> signUp         = {'en': 'Create Account'};
  static const Map<String, String> signOut        = {'en': 'Sign Out'};
  static const Map<String, String> email          = {'en': 'Email Address'};
  static const Map<String, String> password       = {'en': 'Password'};
  static const Map<String, String> forgotPassword = {'en': 'Forgot Password?'};
  static const Map<String, String> phone          = {'en': 'Phone Number'};
  static const Map<String, String> otpSent        = {'en': 'OTP sent to your phone'};
  static const Map<String, String> dashboard      = {'en': 'Dashboard'};
  static const Map<String, String> welcomeBack    = {'en': 'Welcome back'};
  static const Map<String, String> myServices     = {'en': 'My Services'};
  static const Map<String, String> recentActivity = {'en': 'Recent Activity'};
  static const Map<String, String> quickActions   = {'en': 'Quick Actions'};
  static const Map<String, String> tapToSpeak     = {'en': 'Tap to speak'};
  static const Map<String, String> listening      = {'en': 'Listening...'};
  static const Map<String, String> processing     = {'en': 'Processing your request...'};
  static const Map<String, String> govtServices   = {'en': 'Government Services'};
  static const Map<String, String> continueBtn    = {'en': 'Continue'};
  static const Map<String, String> getStarted     = {'en': 'Get Started'};
  static const Map<String, String> cancel         = {'en': 'Cancel'};
  static const Map<String, String> confirm        = {'en': 'Confirm'};
  static const Map<String, String> save           = {'en': 'Save'};
  static const Map<String, String> edit           = {'en': 'Edit'};
  static const Map<String, String> loading        = {'en': 'Loading...'};
  static const Map<String, String> error          = {'en': 'Something went wrong'};
  static const Map<String, String> noData         = {'en': 'No data available'};
  static const Map<String, String> notifications  = {'en': 'Notifications'};
  static const Map<String, String> profile        = {'en': 'Profile'};
  static const Map<String, String> settings       = {'en': 'Settings'};
  static const Map<String, String> language       = {'en': 'Language'};
  static const Map<String, String> privacyPolicy  = {'en': 'Privacy Policy'};
  static const Map<String, String> fullName       = {'en': 'Full Name'};

  // ─── ALL English source strings ─────────────────────────────────────────────
  /// Single source of truth. TranslationService translates these to hi/mr/ta.
  /// TText('some text') also auto-adds unseen strings here at runtime.
  static const Map<String, String> englishStrings = {
    // ── NAV ──────────────────────────────────────────────────────────────
    'nav_home':     'Home',
    'nav_services': 'Services',
    'nav_voice':    'Voice',
    'nav_profile':  'Profile',

    // ── DASHBOARD ─────────────────────────────────────────────────────────
    'dashboard_greeting_morning':   'Good Morning',
    'dashboard_greeting_afternoon': 'Good Afternoon',
    'dashboard_greeting_evening':   'Good Evening',
    'dashboard_subtitle':           'How can we serve you today?',
    'dashboard_quick_actions':      'Quick Actions',
    'dashboard_popular_services':   'Popular Services',
    'dashboard_see_all':            'See All',
    'dashboard_view_all':           'View All',
    'dashboard_my_applications':    'My Applications',
    'dashboard_civic_score':        'Civic Score',
    'dashboard_welcome_back':       'Welcome back',
    'dashboard_citizen':            'Citizen',
    'dashboard_your_services':      'Your Services',
    'dashboard_notifications':      'Notifications',
    'dashboard_govt_schemes':       'Government Schemes',
    'dashboard_recent_queries':     'Recent Voice Queries',
    'dashboard_no_queries':         'No recent queries.\nTap the mic below to start a conversation with CVI!',
    'dashboard_gov_scheme':         'Gov Scheme',
    'dashboard_benefit':            'Benefit',
    'dashboard_ends':               'Ends',
    'dashboard_queries_today':      'Queries Today',
    'dashboard_active_apps':        'Active Apps',
    'dashboard_services_explored':  'Services Explored',
    'dashboard_saved_docs':         'Saved Docs',
    'dashboard_views_today':        'views today',
    'dashboard_ask_cvi':            'Ask CVI',
    'dashboard_my_apps':            'My Apps',
    'dashboard_documents':          'Documents',

    // ── SERVICES ──────────────────────────────────────────────────────────
    'services_title':             'Government Services',
    'services_sub_hi':            'Government Services',
    'services_search_hint':       'Search services',
    'services_count_suffix':      'services',
    'services_choose':            'Choose a service',
    'services_cat_all':           'All',
    'services_cat_identity':      'Identity',
    'services_cat_finance':       'Finance',
    'services_cat_health':        'Health',
    'services_cat_agriculture':   'Agriculture',
    'services_cat_education':     'Education',
    'services_cat_business':      'Business',
    'services_popular':           'Popular',
    'services_free':              'Free',
    'services_online':            'Online',
    'services_apply_now':         'Apply Now',
    'services_check_eligibility': 'Check Eligibility',
    'services_required_docs':     'Required Documents',
    'services_timeline':          'Processing Time',
    'services_fees':              'Fees',
    'services_dept':              'Department',

    // ── PROFILE ───────────────────────────────────────────────────────────
    'profile_title':              'My Profile',
    'profile_personal_info':      'Personal Information',
    'profile_my_services':        'My Services',
    'profile_language':           'Language Settings',
    'profile_notifications':      'Notifications',
    'profile_about_support':      'About & Support',
    'profile_edit':               'Edit Profile',
    'profile_save_changes':       'Save Changes',
    'profile_info_name':          'Full Name',
    'profile_info_age':           'Age',
    'profile_info_state':         'State',
    'profile_info_district':      'District',
    'profile_services_explored':  'Services Explored',
    'profile_view_history':       'View History',
    'profile_notif_updates':      'Application Updates',
    'profile_notif_schemes':      'Government Scheme Deadlines',
    'profile_notif_new':          'New Services Added',
    'profile_civic_score':        'Civic Score',
    'profile_total':              'Total',
    'profile_sign_out':           'Sign Out',
    'profile_sign_out_q':         'Are you sure you want to sign out of Civic Voice?',
    'profile_privacy':            'Privacy Policy',
    'profile_report_issue':       'Report an Issue',
    'profile_rate_app':           'Rate the App',
    'profile_app_version':        'App Version',
    'profile_translating':        'Translating via Google...',
    'profile_trans_failed':       'Translation failed — showing English',

    // ── AUTH ──────────────────────────────────────────────────────────────
    'auth_sign_in':         'Sign In',
    'auth_sign_up':         'Sign Up',
    'auth_continue':        'Continue',
    'auth_email':           'Email Address',
    'auth_password':        'Password',
    'auth_google':          'Continue with Google',
    'auth_or':              'or',
    'auth_subtitle':        'Your voice, your rights, your services.',
    'auth_welcome':         'Welcome to',
    'auth_welcome_back':    'Welcome Back',
    'auth_mobile':          'Enter your mobile number to continue',
    'auth_phone_number':    'Phone Number',
    'auth_get_otp':         'GET OTP',
    'auth_otp_hint':        'Enter OTP',
    'auth_verify_otp':      'Verify OTP',

    // ── ONBOARDING ────────────────────────────────────────────────────────
    'onboard_skip':         'Skip',
    'onboard_next':         'Next',
    'onboard_get_started':  'Get Started',
    'onboard_title_1':      'Speak Your Need',
    'onboard_body_1':       'Ask for any government service in your language',
    'onboard_title_2':      'Get Smart Guidance',
    'onboard_body_2':       'AI-powered guidance through government processes',
    'onboard_title_3':      'Track Your Progress',
    'onboard_body_3':       'Stay updated on all your service applications',
    'onboard_select_lang':  'Select Your Language',
    'onboard_lang_hint':    'You can change this anytime in settings',

    // ── VOICE / AI ────────────────────────────────────────────────────────
    'voice_title':          'Civic Voice AI',
    'voice_tap_to_speak':   'Tap to Speak',
    'voice_listening':      'Listening...',
    'voice_processing':     'Processing your request...',
    'voice_try_asking':     'Try asking:',
    'voice_how_aadhar':     'How do I apply for Aadhaar?',
    'voice_pm_kisan':       'Tell me about PM Kisan scheme',
    'voice_ration_card':    'How to get a ration card?',

    // ── NOTIFICATIONS ─────────────────────────────────────────────────────
    'notif_title':          'Notifications',
    'notif_empty':          'No notifications yet',
    'notif_mark_read':      'Mark all as read',
    'notif_all':            'All',
    'notif_unread':         'Unread',
    'notif_today':          'Today',

    // ── MY APPLICATIONS ───────────────────────────────────────────────────
    'apps_title':           'My Applications',
    'apps_empty':           'No applications yet',
    'apps_status_pending':  'Pending',
    'apps_status_approved': 'Approved',
    'apps_status_rejected': 'Rejected',
    'apps_applied_on':      'Applied on',
    'apps_track':           'Track Status',

    // ── DOCUMENTS ─────────────────────────────────────────────────────────
    'docs_title':           'My Documents',
    'docs_upload':          'Upload Document',
    'docs_scan':            'Scan Document',
    'docs_empty':           'No documents saved',

    // ── LOCATION ──────────────────────────────────────────────────────────
    'location_title':       'Find Government Office',
    'location_search':      'Search offices near you',
    'location_get_dir':     'Get Directions',
    'location_call':        'Call Office',

    // ── GAMIFICATION ──────────────────────────────────────────────────────
    'game_title':           'Civic Score',
    'game_points':          'Points',
    'game_badges':          'Badges Earned',
    'game_streak':          'Day Streak',
    'game_rank':            'Rank',

    // ── COMMON ────────────────────────────────────────────────────────────
    'cancel':               'Cancel',
    'confirm':              'Confirm',
    'save':                 'Save',
    'edit':                 'Edit',
    'loading':              'Loading...',
    'error':                'Something went wrong',
    'retry':                'Retry',
    'close':                'Close',
    'back':                 'Back',
    'next':                 'Next',
    'done':                 'Done',
    'yes':                  'Yes',
    'no':                   'No',
    'ok':                   'OK',
    'search':               'Search',
    'filter':               'Filter',
    'sort':                 'Sort',
    'share':                'Share',
    'download':             'Download',
    'submit':               'Submit',
    'apply':                'Apply',
    'view_details':         'View Details',
    'see_more':             'See More',
    'see_less':             'See Less',
    'learn_more':           'Learn More',
    'required':             'Required',
    'optional':             'Optional',
    'pending':              'Pending',
    'verified':             'Verified',
    'not_verified':         'Not Verified',
  };
}
