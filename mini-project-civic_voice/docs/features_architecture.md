# 🏗️ Architecture: `lib/features`

This document contains an auto-generated structural analysis of all `.dart` files within `lib/features`.

## 📄 File: `features/auth/auth_screen.dart`
- **Lines of code**: 1267
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AuthScreen` extends `StatefulWidget`
  - `_AuthHeader` extends `StatelessWidget`
  - `_AnimatedTabBar` extends `StatelessWidget`
  - `_LoginTab` extends `StatefulWidget`
  - `_LoginTabState` extends `State<_LoginTab>`
  - `_GoogleButton` extends `StatelessWidget`
  - `_OTPSection` extends `StatelessWidget`
  - `_OTPBoxes` extends `StatelessWidget`
  - `_GuestSection` extends `StatelessWidget`
  - `_RegisterTab` extends `StatefulWidget`
  - `_RegisterTabState` extends `State<_RegisterTab>`
  - `_LangChipSelector` extends `StatelessWidget`
  - `_StateDropdown` extends `StatelessWidget`
  - `_NeonTextField` extends `StatefulWidget`
  - `_Divider` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:provider/provider.dart`
  - `../../core/constants/app_colors.dart`
  - `../../core/router/app_router.dart`
  - `../../core/utils/helpers.dart`
  - `../../models/user_model.dart`
  - `../../providers/auth_provider.dart`
  - `../../providers/user_provider.dart`
  - `../../providers/language_provider.dart`
  - `../../widgets/glass_card.dart`
  - `../../widgets/neon_button.dart`
  - `../../widgets/particle_background.dart`

---

## 📄 File: `features/auth/screens/authentication_screen.dart`
- **Lines of code**: 544
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AuthenticationScreen` extends `StatefulWidget`
  - `_GlowingButton` extends `StatefulWidget`
  - `_LanguageChip` extends `StatelessWidget`
  - `_LogoParticlesPainter` extends `CustomPainter`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/widgets/animated/particle_background.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`

---

## 📄 File: `features/auth/screens/auth_screen.dart`
- **Lines of code**: 394
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AuthScreen` extends `StatefulWidget`
  - `_AuthScreenState` extends `State<AuthScreen>`
  - `_MeshGradient` extends `StatelessWidget`
  - `_BlurredBlob` extends `StatelessWidget`
  - `_ParticleBackground` extends `StatefulWidget`
  - `_ParticlePainter` extends `CustomPainter`
  - `_PremiumLanguageSelector` extends `StatelessWidget`
  - `_LangToggle` extends `StatelessWidget`
- **Dependencies**:
  - `package:provider/provider.dart`
  - `package:animate_do/animate_do.dart`
  - `package:civic_voice_interface/core/constants/app_colors.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/t_text.dart`

---

## 📄 File: `features/auth/screens/login_screen.dart`
- **Lines of code**: 787
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `LoginScreen` extends `StatefulWidget`
  - `_GlowingButton` extends `StatefulWidget`
  - `_LanguageChip` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/providers/auth_provider.dart`
  - `package:civic_voice_interface/providers/user_provider.dart`

---

## 📄 File: `features/auth/screens/register_screen.dart`
- **Lines of code**: 538
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `RegisterScreen` extends `StatefulWidget`
  - `_RegisterScreenState` extends `State<RegisterScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/widgets/animated/particle_background.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/providers/user_provider.dart`
  - `package:civic_voice_interface/providers/auth_provider.dart`

---

## 📄 File: `features/auto_form/models/auto_form_model.dart`
- **Lines of code**: 146
- **Component Type**: 📦 Data Model
- **Classes**:
  - `SmartFormField`
  - `SubmitStep`
  - `SmartFormTemplate`
  - `AutoFillResult`

---

## 📄 File: `features/auto_form/providers/auto_form_provider.dart`
- **Lines of code**: 564
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `AutoFormProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `../models/auto_form_model.dart`
  - `../services/form_template_service.dart`
  - `../../../core/services/document_vault_service.dart`
  - `../../../providers/voice_provider.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/citizen_profile_provider.dart`

---

## 📄 File: `features/auto_form/screens/form_review_screen.dart`
- **Lines of code**: 652
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `FormReviewScreen` extends `StatefulWidget`
  - `_FormReviewScreenState` extends `State<FormReviewScreen>`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../core/services/document_vault_service.dart`
  - `../../../models/service_model.dart`
  - `../../../providers/language_provider.dart`
  - `../../../providers/voice_provider.dart`
  - `../providers/auto_form_provider.dart`

---

## 📄 File: `features/auto_form/screens/guided_submission_screen.dart`
- **Lines of code**: 460
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `GuidedSubmissionScreen` extends `StatefulWidget`
  - `_GuidedSubmissionScreenState` extends `State<GuidedSubmissionScreen>`
  - `_StepButton` extends `StatelessWidget`
  - `_CopyableDataRow` extends `StatefulWidget`
  - `_CopyableDataRowState` extends `State<_CopyableDataRow>`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:webview_flutter/webview_flutter.dart`
  - `../../../core/constants/app_colors.dart`
  - `../models/auto_form_model.dart`

---

## 📄 File: `features/auto_form/screens/smart_form_screen.dart`
- **Lines of code**: 979
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `SmartFormScreen` extends `StatefulWidget`
  - `_SmartFieldCard` extends `StatelessWidget`
  - `_LanguageOption` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../models/service_model.dart`
  - `../../../providers/language_provider.dart`
  - `../../../providers/voice_provider.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/citizen_profile_provider.dart`
  - `../models/auto_form_model.dart`
  - `../providers/auto_form_provider.dart`

---

## 📄 File: `features/auto_form/services/form_template_service.dart`
- **Lines of code**: 64
- **Component Type**: 📦 Data Model
- **Classes**:
  - `FormTemplateService`
- **Dependencies**:
  - `../models/auto_form_model.dart`

---

## 📄 File: `features/community/screens/community_verification_screen.dart`
- **Lines of code**: 224
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `CommunityVerificationScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/providers/community_provider.dart`
  - `package:intl/intl.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`

---

## 📄 File: `features/dashboard/dashboard_screen.dart`
- **Lines of code**: 1099
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `DashboardScreen` extends `StatefulWidget`
  - `_HeroHeader` extends `StatefulWidget`
  - `_HeroHeaderState` extends `State<_HeroHeader>`
  - `_StatsRow` extends `StatelessWidget`
  - `_StatData`
  - `_StatCard` extends `StatelessWidget`
  - `_SectionHeader` extends `StatelessWidget`
  - `_ServicesGrid` extends `StatelessWidget`
  - `_SchemeBanner` extends `StatelessWidget`
  - `_RecentActivity` extends `StatelessWidget`
  - `_ActivityData`
  - `_SmartFeaturesGrid` extends `StatelessWidget`
  - `_FeatureData`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../core/constants/app_colors.dart`
  - `../../core/router/app_router.dart`
  - `../../models/service_model.dart`
  - `../../providers/auth_provider.dart`
  - `../../providers/language_provider.dart`
  - `../../providers/services_provider.dart`
  - `../../widgets/decorative/jali_pattern.dart`
  - `../../widgets/decorative/tricolor_bar.dart`

---

## 📄 File: `features/dashboard/screens/application_dashboard_screen.dart`
- **Lines of code**: 222
- **Component Type**: 📱 UI Widget, 🔄 State Provider
- **Classes**:
  - `ApplicationDashboardScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:intl/intl.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/application_tracker_provider.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/dashboard/screens/main_dashboard_screen.dart`
- **Lines of code**: 1160
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `MainDashboardScreen` extends `StatefulWidget`
  - `_StatCard` extends `StatelessWidget`
  - `_QuickActionBtn` extends `StatelessWidget`
  - `_PopularServiceCard` extends `StatelessWidget`
  - `_SchemeCard` extends `StatelessWidget`
  - `_FloatingMicButton` extends `StatefulWidget`
  - `_SectionHeading` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../models/service_model.dart`
  - `../../../providers/analytics_provider.dart`
  - `../../../providers/auth_provider.dart`
  - `../../../providers/conversation_provider.dart`
  - `../../../widgets/t_text.dart`
  - `../../../providers/services_provider.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/notification_provider.dart`
  - `../../../widgets/flag/waving_flag_widget.dart`

---

## 📄 File: `features/dashboard/screens/premium_dashboard_screen.dart`
- **Lines of code**: 637
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `PremiumDashboardScreen` extends `StatefulWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:intl/intl.dart`
  - `package:go_router/go_router.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../widgets/decorative/jali_pattern.dart`
  - `../../../widgets/decorative/tricolor_bar.dart`
  - `../../../widgets/bilingual_label.dart`
  - `../../../widgets/indian_card.dart`
  - `../../../models/service_model_new.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/conversation_provider.dart`
  - `../../../providers/notification_provider.dart`
  - `../../../providers/analytics_provider.dart`

---

## 📄 File: `features/dashboard/widgets/analytics_panel.dart`
- **Lines of code**: 119
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AnalyticsPanel` extends `StatelessWidget`
- **Dependencies**:
  - `package:fl_chart/fl_chart.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../widgets/containers/glass_card.dart`

---

## 📄 File: `features/dashboard/widgets/horizontal_process_timeline.dart`
- **Lines of code**: 84
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `HorizontalProcessTimeline` extends `StatelessWidget`
- **Dependencies**:
  - `../../../core/constants/app_colors.dart`
  - `../../../widgets/containers/glass_card.dart`
  - `../../../models/service_model.dart`

---

## 📄 File: `features/dashboard/widgets/user_profile_modal.dart`
- **Lines of code**: 107
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `UserProfileModal` extends `StatelessWidget`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../gamification/widgets/achievement_badge.dart`
  - `../../../providers/achievement_provider.dart`
  - `../../../providers/auth_provider.dart`
  - `package:provider/provider.dart`

---

## 📄 File: `features/documents/screens/ai_document_scanner_screen.dart`
- **Lines of code**: 207
- **Component Type**: 📱 UI Widget, 🔄 State Provider
- **Classes**:
  - `AIDocumentScannerScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:image_picker/image_picker.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/document_scanner_provider.dart`
  - `../../../../widgets/cvi_button.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/documents/screens/ar_guidance_screen.dart`
- **Lines of code**: 167
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ARGuidanceScreen` extends `StatefulWidget`
  - `_ARGuidanceScreenState` extends `State<ARGuidanceScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`

---

## 📄 File: `features/documents/screens/documents_screen.dart`
- **Lines of code**: 802
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `DocumentsScreen` extends `StatefulWidget`
  - `_DocumentCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:intl/intl.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../providers/user_provider.dart`
  - `../../../models/document_model.dart`
  - `../../../core/services/document_inference_service.dart`
  - `package:file_picker/file_picker.dart`
  - `package:image_picker/image_picker.dart`
  - `../../../providers/language_provider.dart`

---

## 📄 File: `features/documents/screens/document_vault_screen.dart`
- **Lines of code**: 938
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `_DocSlot`
  - `DocumentVaultScreen` extends `StatefulWidget`
  - `_DocumentVaultScreenState` extends `State<DocumentVaultScreen>`
  - `_DocumentSlotCard` extends `StatelessWidget`
  - `_UploadOption` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:image_picker/image_picker.dart`
  - `package:file_picker/file_picker.dart`
  - `package:provider/provider.dart`
  - `../../../providers/document_vault_provider.dart`

---

## 📄 File: `features/documents/widgets/document_upload_flow.dart`
- **Lines of code**: 149
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `DocumentUploadFlow` extends `StatefulWidget`
  - `_DocumentUploadFlowState` extends `State<DocumentUploadFlow>`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `package:confetti/confetti.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/eligibility/screens/ai_eligibility_flow_screen.dart`
- **Lines of code**: 192
- **Component Type**: 📱 UI Widget, 🔄 State Provider
- **Classes**:
  - `AIEligibilityFlowScreen` extends `StatefulWidget`
  - `_AIEligibilityFlowScreenState` extends `State<AIEligibilityFlowScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/eligibility_checker_provider.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/eligibility/widgets/civic_confidence_gauge.dart`
- **Lines of code**: 111
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `CivicConfidenceGauge` extends `StatelessWidget`
  - `_GaugePainter` extends `CustomPainter`
- **Dependencies**:
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/eligibility/widgets/eligibility_checker.dart`
- **Lines of code**: 116
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `EligibilityChecker` extends `StatefulWidget`
  - `_EligibilityCheckerState` extends `State<EligibilityChecker>`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/forms/screens/auto_fill_form_screen.dart`
- **Lines of code**: 1042
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AutoFillFormScreen` extends `StatefulWidget`
  - `_AutoFillFormScreenState` extends `State<AutoFillFormScreen>`
  - `_FormFieldCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:url_launcher/url_launcher.dart`
  - `../../../core/services/document_vault_service.dart`
  - `../../../core/services/form_filler_service.dart`
  - `../../../models/service_model.dart`
  - `../../../core/router/app_router.dart`
  - `package:provider/provider.dart`
  - `../../../providers/language_provider.dart`

---

## 📄 File: `features/forms/screens/smart_browser_screen.dart`
- **Lines of code**: 673
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `SmartBrowserScreen` extends `StatefulWidget`
  - `_SmartBrowserScreenState` extends `State<SmartBrowserScreen>`
- **Dependencies**:
  - `package:webview_flutter/webview_flutter.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/gamification/screens/gamification_screen.dart`
- **Lines of code**: 209
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `GamificationScreen` extends `StatelessWidget`
  - `_ScoreArcPainter` extends `CustomPainter`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../providers/gamification_provider.dart`

---

## 📄 File: `features/gamification/widgets/achievement_badge.dart`
- **Lines of code**: 121
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AchievementBadge` extends `StatelessWidget`
  - `FadeInScale` extends `StatefulWidget`
- **Dependencies**:
  - `../../../core/constants/app_colors.dart`
  - `../../../providers/achievement_provider.dart`

---

## 📄 File: `features/location/screens/office_finder_screen.dart`
- **Lines of code**: 99
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `OfficeFinderScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `package:url_launcher/url_launcher.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/location/screens/office_locator_screen.dart`
- **Lines of code**: 303
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `OfficeLocatorScreen` extends `StatefulWidget`
  - `_OfficeLocatorScreenState` extends `State<OfficeLocatorScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:url_launcher/url_launcher.dart`
  - `package:go_router/go_router.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/navigation/screens/main_navigation_screen.dart`
- **Lines of code**: 81
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `MainNavigationScreen` extends `StatefulWidget`
  - `_MainNavigationScreenState` extends `State<MainNavigationScreen>`
- **Dependencies**:
  - `package:provider/provider.dart`
  - `../../../providers/auth_provider.dart`
  - `../../../providers/user_provider.dart`
  - `../../dashboard/screens/premium_dashboard_screen.dart`
  - `../../services/screens/services_screen.dart`
  - `../../voice_interface/screens/voice_dashboard_screen.dart`
  - `../../profile/profile_screen.dart`
  - `../../../widgets/navigation/cvi_bottom_nav.dart`

---

## 📄 File: `features/notifications/notifications_screen.dart`
- **Lines of code**: 448
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `NotificationsScreen` extends `StatefulWidget`
  - `_NotificationsScreenState` extends `State<NotificationsScreen>`
  - `_DismissibleCard` extends `StatelessWidget`
  - `_SwipeBackground` extends `StatelessWidget`
  - `_NotificationCard` extends `StatelessWidget`
  - `_EmptyState` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:provider/provider.dart`
  - `../../core/constants/app_colors.dart`
  - `../../providers/notification_provider.dart`

---

## 📄 File: `features/notifications/screens/notifications_screen_v2.dart`
- **Lines of code**: 536
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `NotificationsScreenV2` extends `StatefulWidget`
  - `_NotificationsScreenV2State` extends `State<NotificationsScreenV2>`
  - `_NotificationDismissibleCard` extends `StatelessWidget`
  - `_SwipeBackground` extends `StatelessWidget`
  - `_NotificationCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../providers/notification_provider.dart`
  - `../../../widgets/t_text.dart`
  - `../../../core/router/app_router.dart`

---

## 📄 File: `features/onboarding/onboarding_screen.dart`
- **Lines of code**: 770
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `OnboardingScreen` extends `StatefulWidget`
  - `_OnboardingScreenState` extends `State<OnboardingScreen>`
  - `_NextButton` extends `StatelessWidget`
  - `_Slide1` extends `StatefulWidget`
  - `_WaveRing` extends `StatelessWidget`
  - `_Slide2` extends `StatefulWidget`
  - `_Slide3` extends `StatefulWidget`
  - `_LangChip`
  - `_LanguageChip` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:provider/provider.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `../../core/constants/app_colors.dart`
  - `../../core/router/app_router.dart`
  - `../../providers/language_provider.dart`
  - `../../widgets/neon_button.dart`
  - `../../widgets/particle_background.dart`

---

## 📄 File: `features/onboarding/screens/first_launch_screen.dart`
- **Lines of code**: 358
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `FirstLaunchScreen` extends `StatefulWidget`
  - `_FirstLaunchScreenState` extends `State<FirstLaunchScreen>`
  - `_LangChip` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../providers/language_provider.dart`
  - `../../../providers/services_provider.dart`
  - `../../../widgets/particle_background.dart`
  - `../../../widgets/t_text.dart`

---

## 📄 File: `features/onboarding/screens/welcome_screen.dart`
- **Lines of code**: 141
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `WelcomeScreen` extends `StatelessWidget`
  - `_GlowBlob` extends `StatelessWidget`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `package:google_fonts/google_fonts.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/profile/profile_screen.dart`
- **Lines of code**: 1301
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ProfileScreen` extends `StatelessWidget`
  - `_ProfileHeader` extends `StatelessWidget`
  - `_VerifiedBadge` extends `StatelessWidget`
  - `_ApplicationsSection` extends `StatelessWidget`
  - `_LanguageSection` extends `StatelessWidget`
  - `_SegmentedSizeControl` extends `StatefulWidget`
  - `_SegmentedSizeControlState` extends `State<_SegmentedSizeControl>`
  - `_VoiceSettingsSection` extends `StatefulWidget`
  - `_VoiceSettingsSectionState` extends `State<_VoiceSettingsSection>`
  - `_GenderToggle` extends `StatelessWidget`
  - `_MicPermissionCard` extends `StatelessWidget`
  - `_PrivacySection` extends `StatefulWidget`
  - `_PrivacySectionState` extends `State<_PrivacySection>`
  - `_SettingsListTile` extends `StatelessWidget`
  - `_AboutSection` extends `StatelessWidget`
  - `_MySectionHeader` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:provider/provider.dart`
  - `package:google_fonts/google_fonts.dart`
  - `../../core/constants/app_colors.dart`
  - `../../core/router/app_router.dart`
  - `../../models/user_model.dart`
  - `../../providers/auth_provider.dart`
  - `../../providers/accessibility_provider.dart`
  - `../../providers/language_provider.dart`
  - `../../providers/services_provider.dart`
  - `../../providers/voice_provider.dart`
  - `../../widgets/indian_card.dart`
  - `../../widgets/cvi_button.dart`
  - `../../widgets/bilingual_label.dart`
  - `../../widgets/decorative/jali_pattern.dart`

---

## 📄 File: `features/profile/screens/citizen_profile_dashboard.dart`
- **Lines of code**: 361
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `CitizenProfileDashboard` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/citizen_profile_provider.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/profile/screens/complete_profile_screen.dart`
- **Lines of code**: 725
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `CompleteProfileScreen` extends `StatefulWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `package:url_launcher/url_launcher.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../providers/auth_provider.dart`
  - `../../../providers/language_provider.dart`
  - `../../../providers/analytics_provider.dart`
  - `../../../widgets/particle_background.dart`

---

## 📄 File: `features/profile/screens/family_dashboard_screen.dart`
- **Lines of code**: 258
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `FamilyDashboardScreen` extends `StatefulWidget`
  - `_FamilyDashboardScreenState` extends `State<FamilyDashboardScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/language_provider.dart`
  - `../../../models/family_member_model.dart`

---

## 📄 File: `features/profile/screens/notes_screen.dart`
- **Lines of code**: 164
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `NotesScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../providers/notes_provider.dart`
  - `package:intl/intl.dart`

---

## 📄 File: `features/profile/screens/personal_information_screen.dart`
- **Lines of code**: 203
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `PersonalInformationScreen` extends `StatefulWidget`
  - `_PersonalInformationScreenState` extends `State<PersonalInformationScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../widgets/animated/particle_background.dart`
  - `../../../providers/user_provider.dart`

---

## 📄 File: `features/profile/screens/user_onboarding_screen.dart`
- **Lines of code**: 320
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `UserOnboardingScreen` extends `StatefulWidget`
  - `_UserOnboardingScreenState` extends `State<UserOnboardingScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../widgets/animated/particle_background.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/language_provider.dart`

---

## 📄 File: `features/profile/screens/user_profile_screen.dart`
- **Lines of code**: 873
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `UserProfileScreen` extends `StatefulWidget`
  - `_UserProfileScreenState` extends `State<UserProfileScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../core/services/notification_service.dart`
  - `../../../core/services/supabase_service.dart`
  - `package:supabase_flutter/supabase_flutter.dart`
  - `package:image_picker/image_picker.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../widgets/animated/particle_background.dart`
  - `../../../providers/language_provider.dart`
  - `../../../core/constants/app_language.dart`
  - `user_onboarding_screen.dart`
  - `personal_information_screen.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/accessibility_provider.dart`
  - `notes_screen.dart`
  - `family_dashboard_screen.dart`
  - `../../services/screens/virtual_queue_screen.dart`
  - `../../gamification/screens/gamification_screen.dart`
  - `../../community/screens/community_verification_screen.dart`
  - `../../services/screens/emergency_screen.dart`
  - `../../documents/screens/ar_guidance_screen.dart`

---

## 📄 File: `features/recommendations/screens/recommendations_screen.dart`
- **Lines of code**: 518
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `RecommendationsScreen` extends `StatefulWidget`
  - `_RecommendationsScreenState` extends `State<RecommendationsScreen>`
  - `_RecommendationCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../models/scheme_model.dart`
  - `../../../providers/citizen_profile_provider.dart`
  - `../../../widgets/glass_card.dart`
  - `../../../widgets/t_text.dart`
  - `../../../core/services/csv_scheme_service.dart`

---

## 📄 File: `features/services/screens/all_services_screen.dart`
- **Lines of code**: 259
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AllServicesScreen` extends `StatefulWidget`
  - `_AllServicesScreenState` extends `State<AllServicesScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/widgets/animated/particle_background.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/models/service_model_new.dart`
  - `package:civic_voice_interface/features/services/screens/service_detail_screen_new.dart`

---

## 📄 File: `features/services/screens/eligibility_checker_screen.dart`
- **Lines of code**: 431
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `EligibilityCheckerScreen` extends `StatefulWidget`
  - `_EligibilityCheckerScreenState` extends `State<EligibilityCheckerScreen>`
  - `_StepContent` extends `StatelessWidget`
  - `_ChoiceTile` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../models/service_model.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/services/screens/emergency_screen.dart`
- **Lines of code**: 284
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `EmergencyScreen` extends `StatefulWidget`
  - `_EmergencyScreenState` extends `State<EmergencyScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:geolocator/geolocator.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/core/services/emergency_service.dart`

---

## 📄 File: `features/services/screens/my_applications_screen.dart`
- **Lines of code**: 421
- **Component Type**: 📱 UI Widget, 📦 Data Model
- **Classes**:
  - `MyApplicationsScreen` extends `StatefulWidget`
  - `_MyApplicationsScreenState` extends `State<MyApplicationsScreen>`
  - `_ApplicationCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `package:url_launcher/url_launcher.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../models/application_tracker_model.dart`
  - `../../../providers/services_provider.dart`
  - `../../../providers/auth_provider.dart`
  - `package:provider/provider.dart`

---

## 📄 File: `features/services/screens/offline_guidance_screen.dart`
- **Lines of code**: 280
- **Component Type**: 📱 UI Widget, 🔄 State Provider
- **Classes**:
  - `OfflineGuidanceScreen` extends `StatefulWidget`
  - `_OfflineGuidanceScreenState` extends `State<OfflineGuidanceScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/offline_guidance_provider.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/services/screens/schemes_screen.dart`
- **Lines of code**: 253
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `SchemesScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/services/scheme_knowledge_base.dart`
  - `../../../models/scheme_model.dart`
  - `../../../providers/user_provider.dart`
  - `../../../providers/language_provider.dart`
  - `scheme_detail_screen.dart`

---

## 📄 File: `features/services/screens/scheme_detail_screen.dart`
- **Lines of code**: 459
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `SchemeDetailScreen` extends `StatefulWidget`
  - `_SchemeDetailScreenState` extends `State<SchemeDetailScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/constants/app_colors.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/models/scheme_model.dart`
  - `package:civic_voice_interface/providers/user_provider.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/providers/voice_provider.dart`
  - `package:civic_voice_interface/models/application_model.dart`

---

## 📄 File: `features/services/screens/scheme_discovery_screen.dart`
- **Lines of code**: 208
- **Component Type**: 📱 UI Widget, 🔄 State Provider
- **Classes**:
  - `SchemeDiscoveryScreen` extends `StatefulWidget`
  - `_SchemeDiscoveryScreenState` extends `State<SchemeDiscoveryScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/scheme_discovery_provider.dart`
  - `../../../../widgets/glass_card.dart`

---

## 📄 File: `features/services/screens/services_screen.dart`
- **Lines of code**: 416
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ServicesScreen` extends `StatefulWidget`
  - `_ServicesScreenState` extends `State<ServicesScreen>`
  - `_ServiceCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:go_router/go_router.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../providers/services_provider.dart`
  - `../../../providers/analytics_provider.dart`
  - `../../../providers/language_provider.dart`
  - `../../../models/service_model.dart`
  - `../../../widgets/decorative/tricolor_bar.dart`
  - `../../../widgets/service_icon_tile.dart`

---

## 📄 File: `features/services/screens/service_detail_screen.dart`
- **Lines of code**: 338
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ServiceDetailScreen` extends `StatefulWidget`
  - `_ServiceDetailScreenState` extends `State<ServiceDetailScreen>`
  - `_Premium3DDocCard` extends `StatelessWidget`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:provider/provider.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../models/service_model.dart`
  - `../../../providers/voice_provider.dart`
  - `../../eligibility/widgets/civic_confidence_gauge.dart`

---

## 📄 File: `features/services/screens/service_detail_screen_new.dart`
- **Lines of code**: 568
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ServiceDetailScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:url_launcher/url_launcher.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`
  - `package:civic_voice_interface/widgets/animated/particle_background.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/models/service_model_new.dart`
  - `package:civic_voice_interface/models/scheme_model.dart`
  - `package:civic_voice_interface/providers/user_provider.dart`
  - `package:civic_voice_interface/core/services/scheme_knowledge_base.dart`

---

## 📄 File: `features/services/screens/service_detail_screen_v2.dart`
- **Lines of code**: 1736
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ServiceDetailScreenV2` extends `StatefulWidget`
  - `_ServiceHeader` extends `StatelessWidget`
  - `_CVITabBar` extends `StatelessWidget`
  - `_OverviewTab` extends `StatelessWidget`
  - `_GlanceItem` extends `StatelessWidget`
  - `_DocumentsTab` extends `StatelessWidget`
  - `_CountBadge` extends `StatelessWidget`
  - `_DocumentCard` extends `StatefulWidget`
  - `_DocumentCardState` extends `State<_DocumentCard>`
  - `_StepsTab` extends `StatelessWidget`
  - `_StepTile` extends `StatelessWidget`
  - `_TrackTab` extends `StatelessWidget`
  - `_StatusTimeline` extends `StatelessWidget`
  - `_ContactRow` extends `StatelessWidget`
  - `_SectionCard` extends `StatelessWidget`
  - `_StickyBar` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:url_launcher/url_launcher.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../core/router/app_router.dart`
  - `../../../models/service_model.dart`

---

## 📄 File: `features/services/screens/service_navigation_screen.dart`
- **Lines of code**: 62
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ServiceNavigationScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `../../../core/constants/app_colors.dart`
  - `../../../models/service_model.dart`
  - `../../../widgets/cards/service_card.dart`

---

## 📄 File: `features/services/screens/track_application_screen.dart`
- **Lines of code**: 234
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `TrackApplicationScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:intl/intl.dart`
  - `package:provider/provider.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/models/application_model.dart`
  - `package:civic_voice_interface/providers/language_provider.dart`
  - `package:civic_voice_interface/widgets/glass/glass_card.dart`

---

## 📄 File: `features/services/screens/virtual_queue_screen.dart`
- **Lines of code**: 227
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `VirtualQueueScreen` extends `StatefulWidget`
  - `_VirtualQueueScreenState` extends `State<VirtualQueueScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../../core/theme/app_theme.dart`
  - `../../../widgets/glass/glass_card.dart`
  - `../../../core/services/queue_service.dart`
  - `../../../models/queue_token_model.dart`
  - `package:intl/intl.dart`
  - `../../../providers/language_provider.dart`

---

## 📄 File: `features/services/widgets/process_navigator.dart`
- **Lines of code**: 185
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ProcessNavigator` extends `StatefulWidget`
  - `PathPainter` extends `CustomPainter`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/service_detail/service_detail_screen.dart`
- **Lines of code**: 1253
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ServiceDetailScreen` extends `StatefulWidget`
  - `_DetailSliverAppBar` extends `StatelessWidget`
  - `_StickyTabBar` extends `StatelessWidget`
  - `_TabBarDelegate` extends `SliverPersistentHeaderDelegate`
  - `_OverviewTab` extends `StatelessWidget`
  - `_DocumentsTab` extends `StatefulWidget`
  - `_DocumentsTabState` extends `State<_DocumentsTab>`
  - `_DocProgressBar` extends `StatelessWidget`
  - `_StepsTab` extends `StatefulWidget`
  - `_StepsTabState` extends `State<_StepsTab>`
  - `_TimelineTab` extends `StatelessWidget`
  - `_LegendItem` extends `StatelessWidget`
  - `_LinksTab` extends `StatelessWidget`
  - `_ServiceFAB` extends `StatelessWidget`
  - `_SectionTitle` extends `StatelessWidget`
  - `_Chip` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:go_router/go_router.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:url_launcher/url_launcher.dart`
  - `../../core/constants/app_colors.dart`
  - `../../core/router/app_router.dart`
  - `../../models/service_model.dart`
  - `../../providers/language_provider.dart`
  - `../../providers/services_provider.dart`
  - `../../widgets/glass_card.dart`
  - `../../widgets/neon_button.dart`

---

## 📄 File: `features/splash/splash_screen.dart`
- **Lines of code**: 152
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `SplashScreen` extends `StatefulWidget`
  - `_SplashScreenState` extends `State<SplashScreen>`
- **Dependencies**:
  - `package:go_router/go_router.dart`
  - `package:flutter_tts/flutter_tts.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `../../core/router/app_router.dart`
  - `../../providers/auth_provider.dart`

---

## 📄 File: `features/voice/voice_screen.dart`
- **Lines of code**: 1109
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `VoiceScreen` extends `StatefulWidget`
  - `_TopBar` extends `StatelessWidget`
  - `_ConversationArea` extends `StatelessWidget`
  - `_IdleMic` extends `StatelessWidget`
  - `_WaveformBars` extends `StatefulWidget`
  - `_WaveformBarsState` extends `State<_WaveformBars>`
  - `_UserBubble` extends `StatelessWidget`
  - `_BotBubble` extends `StatelessWidget`
  - `_TypingBubble` extends `StatefulWidget`
  - `_BottomMicBar` extends `StatelessWidget`
  - `_TextBar` extends `StatelessWidget`
- **Dependencies**:
  - `package:flutter_animate/flutter_animate.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `../../core/constants/app_colors.dart`
  - `../../models/conversation_model.dart`
  - `../../providers/conversation_provider.dart`
  - `../../providers/language_provider.dart`
  - `../../providers/voice_provider.dart`
  - `../../providers/analytics_provider.dart`
  - `../../widgets/decorative/chakra_painter.dart`
  - `../../widgets/decorative/tricolor_bar.dart`

---

## 📄 File: `features/voice/screens/voice_complaint_screen.dart`
- **Lines of code**: 741
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `VoiceComplaintScreen` extends `StatefulWidget`
  - `_VoiceComplaintScreenState` extends `State<VoiceComplaintScreen>`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `package:provider/provider.dart`
  - `package:image_picker/image_picker.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/complaint_provider.dart`
  - `../../../../widgets/glass_card.dart`
  - `../../../../providers/voice_provider.dart`
  - `../../../../providers/language_provider.dart`

---

## 📄 File: `features/voice/widgets/ai_visualizer.dart`
- **Lines of code**: 409
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `AIVisualizer` extends `StatefulWidget`
  - `_VisualizerPainter` extends `CustomPainter`
- **Dependencies**:
  - `../../../providers/voice_provider.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/voice_interface/screens/conversation_interface_screen.dart`
- **Lines of code**: 131
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `ConversationInterfaceScreen` extends `StatefulWidget`
  - `_ConversationInterfaceScreenState` extends `State<ConversationInterfaceScreen>`
- **Dependencies**:
  - `package:animate_do/animate_do.dart`
  - `package:animated_text_kit/animated_text_kit.dart`
  - `../../../core/constants/app_colors.dart`

---

## 📄 File: `features/voice_interface/screens/voice_dashboard_screen.dart`
- **Lines of code**: 605
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `VoiceDashboardScreen` extends `StatelessWidget`
  - `_AICoreVisualizer` extends `StatefulWidget`
  - `_CorePainter` extends `CustomPainter`
  - `_ConversationConsole` extends `StatelessWidget`
- **Dependencies**:
  - `package:intl/intl.dart`
  - `package:provider/provider.dart`
  - `package:flutter_animate/flutter_animate.dart`
  - `package:google_fonts/google_fonts.dart`
  - `../../../../core/constants/app_colors.dart`
  - `../../../../providers/voice_provider.dart`
  - `../../../../providers/conversation_provider.dart`
  - `../../../../providers/language_provider.dart`
  - `../../../../models/conversation_model.dart`
  - `../../../../widgets/decorative/chakra_painter.dart`
  - `../../../../widgets/decorative/jali_pattern.dart`
  - `../../../../widgets/bilingual_label.dart`
  - `package:url_launcher/url_launcher.dart`

---

## 📄 File: `features/voice_interface/screens/voice_interface_screen.dart`
- **Lines of code**: 733
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `VoiceInterfaceScreen` extends `StatefulWidget`
  - `_AnimatedMessageBubble` extends `StatefulWidget`
  - `_QuickResponseChip` extends `StatefulWidget`
  - `_QuickResponseChipState` extends `State<_QuickResponseChip>`
  - `_AnimatedGridPainter` extends `CustomPainter`
  - `_RotatingRingsPainter` extends `CustomPainter`
- **Dependencies**:
  - `package:provider/provider.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:civic_voice_interface/core/theme/app_theme.dart`
  - `package:civic_voice_interface/widgets/animated/voice_waveform.dart`
  - `package:civic_voice_interface/widgets/animated/particle_background.dart`
  - `package:civic_voice_interface/providers/conversation_provider.dart`
  - `package:civic_voice_interface/providers/voice_provider.dart`
  - `package:civic_voice_interface/models/conversation_model.dart`
  - `package:intl/intl.dart`

---

