# 🏗️ Architecture: `lib/core`

This document contains an auto-generated structural analysis of all `.dart` files within `lib/core`.

## 📄 File: `core/config/ai_config.dart`
- **Lines of code**: 14
- **Classes**:
  - `AIConfig`
- **Dependencies**:
  - `package:flutter_dotenv/flutter_dotenv.dart`

---

## 📄 File: `core/constants/app_assets.dart`
- **Lines of code**: 63
- **Classes**:
  - `AppAssets`

---

## 📄 File: `core/constants/app_colors.dart`
- **Lines of code**: 164
- **Classes**:
  - `AppColors`

---

## 📄 File: `core/constants/app_language.dart`
- **Lines of code**: 21

---

## 📄 File: `core/constants/app_strings.dart`
- **Lines of code**: 248
- **Classes**:
  - `AppStrings`

---

## 📄 File: `core/engine/reasoning_engine.dart`
- **Lines of code**: 107
- **Classes**:
  - `ReasoningEngine`
- **Dependencies**:
  - `package:civic_voice_interface/models/scheme_model.dart`

---

## 📄 File: `core/router/app_router.dart`
- **Lines of code**: 524
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `Routes`
  - `AppRouter`
  - `_AppShell` extends `StatelessWidget`
  - `_ErrorScreen` extends `StatelessWidget`
- **Dependencies**:
  - `package:go_router/go_router.dart`
  - `package:provider/provider.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `../../features/voice/screens/voice_complaint_screen.dart`
  - `../../features/documents/screens/ai_document_scanner_screen.dart`
  - `../../features/services/screens/scheme_discovery_screen.dart`
  - `../../features/dashboard/screens/application_dashboard_screen.dart`
  - `../../features/services/screens/offline_guidance_screen.dart`
  - `../../features/profile/screens/citizen_profile_dashboard.dart`
  - `../../features/recommendations/screens/recommendations_screen.dart`
  - `../../features/services/screens/eligibility_checker_screen.dart`
  - `../../providers/language_provider.dart`
  - `../../providers/auth_provider.dart`
  - `../../features/auth/auth_screen.dart`
  - `../../features/dashboard/screens/main_dashboard_screen.dart`
  - `../../features/voice/voice_screen.dart`
  - `../../features/services/screens/services_screen.dart`
  - `../../features/profile/profile_screen.dart`
  - `../../features/onboarding/screens/first_launch_screen.dart`
  - `../../features/splash/splash_screen.dart`
  - `../../features/services/screens/service_detail_screen_v2.dart`
  - `../../models/service_model.dart`
  - `../../features/notifications/screens/notifications_screen_v2.dart`
  - `../../features/services/screens/my_applications_screen.dart`
  - `../../features/documents/screens/documents_screen.dart`
  - `../../features/documents/screens/document_vault_screen.dart`
  - `../../features/forms/screens/auto_fill_form_screen.dart`
  - `../../features/forms/screens/smart_browser_screen.dart`
  - `../../features/auto_form/screens/smart_form_screen.dart`
  - `../../features/auto_form/screens/form_review_screen.dart`
  - `../../features/auto_form/screens/guided_submission_screen.dart`
  - `../../features/auto_form/models/auto_form_model.dart`
  - `../../providers/document_vault_provider.dart`
  - `../../widgets/navigation/cvi_bottom_nav.dart`

---

## 📄 File: `core/services/csv_scheme_service.dart`
- **Lines of code**: 158
- **Classes**:
  - `CsvSchemeService`
- **Dependencies**:
  - `package:csv/csv.dart`
  - `../../models/scheme_model.dart`

---

## 📄 File: `core/services/document_ai_service.dart`
- **Lines of code**: 331
- **Classes**:
  - `DocumentAIService`
- **Dependencies**:
  - `package:http/http.dart`
  - `package:flutter_image_compress/flutter_image_compress.dart`
  - `../config/ai_config.dart`
  - `../../models/cvi_document_model.dart`

---

## 📄 File: `core/services/document_inference_service.dart`
- **Lines of code**: 125
- **Classes**:
  - `VerificationResult`
  - `DocumentInferenceService`
- **Dependencies**:
  - `package:image/image.dart`
  - `reasoning_engine.dart`

---

## 📄 File: `core/services/document_vault_service.dart`
- **Lines of code**: 260
- **Classes**:
  - `DocumentVaultService`
- **Dependencies**:
  - `package:supabase_flutter/supabase_flutter.dart`
  - `document_ai_service.dart`

---

## 📄 File: `core/services/emergency_service.dart`
- **Lines of code**: 113
- **Classes**:
  - `DisasterGuide`
  - `EmergencyService`
- **Dependencies**:
  - `package:geolocator/geolocator.dart`
  - `package:url_launcher/url_launcher.dart`

---

## 📄 File: `core/services/form_filler_service.dart`
- **Lines of code**: 538
- **Classes**:
  - `FormFieldDef`
  - `GovernmentFormDef`
  - `FormFillerService`
- **Dependencies**:
  - `../../models/cvi_document_model.dart`
  - `document_vault_service.dart`

---

## 📄 File: `core/services/notification_service.dart`
- **Lines of code**: 78
- **Classes**:
  - `NotificationService`
- **Dependencies**:
  - `package:flutter_local_notifications/flutter_local_notifications.dart`
  - `package:timezone/data/latest_all.dart`

---

## 📄 File: `core/services/offline_mode_service.dart`
- **Lines of code**: 75
- **Classes**:
  - `OfflineModeService`
- **Dependencies**:
  - `package:connectivity_plus/connectivity_plus.dart`
  - `scheme_knowledge_base.dart`

---

## 📄 File: `core/services/queue_service.dart`
- **Lines of code**: 39
- **Classes**:
  - `QueueService`
- **Dependencies**:
  - `../../models/queue_token_model.dart`

---

## 📄 File: `core/services/reasoning_engine.dart`
- **Lines of code**: 455
- **Classes**:
  - `DetectionResult`
  - `SmartIntentParser`
  - `ReasoningEngine`
- **Dependencies**:
  - `package:flutter_dotenv/flutter_dotenv.dart`
  - `package:http/http.dart`
  - `scheme_knowledge_base.dart`

---

## 📄 File: `core/services/reminder_service.dart`
- **Lines of code**: 66
- **Classes**:
  - `ReminderService`
- **Dependencies**:
  - `package:flutter_local_notifications/flutter_local_notifications.dart`
  - `package:timezone/timezone.dart`
  - `package:timezone/data/latest.dart`

---

## 📄 File: `core/services/scheme_knowledge_base.dart`
- **Lines of code**: 246
- **Classes**:
  - `SchemeKnowledgeBase`
- **Dependencies**:
  - `../../models/scheme_model.dart`

---

## 📄 File: `core/services/supabase_service.dart`
- **Lines of code**: 66
- **Classes**:
  - `SupabaseService`
- **Dependencies**:
  - `package:supabase_flutter/supabase_flutter.dart`
  - `package:flutter_dotenv/flutter_dotenv.dart`

---

## 📄 File: `core/services/translation_service.dart`
- **Lines of code**: 24
- **Classes**:
  - `TranslationService`
- **Dependencies**:
  - `reasoning_engine.dart`

---

## 📄 File: `core/theme/app_theme.dart`
- **Lines of code**: 370
- **Classes**:
  - `AppTheme`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `../constants/app_colors.dart`

---

## 📄 File: `core/themes/app_theme.dart`
- **Lines of code**: 74
- **Classes**:
  - `AppTheme`
- **Dependencies**:
  - `package:google_fonts/google_fonts.dart`
  - `../constants/app_colors.dart`

---

## 📄 File: `core/utils/app_initializer.dart`
- **Lines of code**: 69
- **Classes**:
  - `AppInitializer`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `../../providers/language_provider.dart`
  - `../../providers/voice_provider.dart`
  - `../../providers/services_provider.dart`

---

## 📄 File: `core/utils/helpers.dart`
- **Lines of code**: 36

---

## 📄 File: `core/utils/intent_engine.dart`
- **Lines of code**: 223
- **Classes**:
  - `IntentResult`
  - `IntentEngine`

---

## 📄 File: `core/utils/response_generator.dart`
- **Lines of code**: 241
- **Classes**:
  - `ResponseGenerator`
- **Dependencies**:
  - `../../models/service_model.dart`
  - `intent_engine.dart`

---

