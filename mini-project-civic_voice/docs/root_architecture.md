# 🏗️ Architecture: `lib/root`

This document contains an auto-generated structural analysis of all `.dart` files within `lib/root`.

## 📄 File: `app.dart`
- **Lines of code**: 101
- **Component Type**: 📱 UI Widget
- **Classes**:
  - `CVIApp` extends `StatefulWidget`
  - `_CVIAppState` extends `State<CVIApp>`
- **Dependencies**:
  - `package:provider/provider.dart`
  - `package:google_fonts/google_fonts.dart`
  - `package:flutter_localizations/flutter_localizations.dart`
  - `core/theme/app_theme.dart`
  - `core/router/app_router.dart`
  - `providers/language_provider.dart`
  - `providers/auth_provider.dart`
  - `providers/accessibility_provider.dart`
  - `widgets/loading_overlay.dart`

---

## 📄 File: `main.dart`
- **Lines of code**: 76
- **Component Type**: 🔄 State Provider
- **Dependencies**:
  - `package:flutter_dotenv/flutter_dotenv.dart`
  - `package:provider/provider.dart`
  - `package:shared_preferences/shared_preferences.dart`
  - `package:supabase_flutter/supabase_flutter.dart`
  - `core/constants/app_assets.dart`
  - `providers/auth_provider.dart`
  - `providers/language_provider.dart`
  - `providers/voice_provider.dart`
  - `providers/conversation_provider.dart`
  - `providers/user_provider.dart`
  - `providers/services_provider.dart`
  - `providers/notification_provider.dart`
  - `providers/analytics_provider.dart`
  - `providers/accessibility_provider.dart`
  - `providers/document_vault_provider.dart`
  - `providers/eligibility_checker_provider.dart`
  - `providers/complaint_provider.dart`
  - `providers/document_scanner_provider.dart`
  - `providers/scheme_discovery_provider.dart`
  - `providers/application_tracker_provider.dart`
  - `providers/offline_guidance_provider.dart`
  - `providers/citizen_profile_provider.dart`
  - `features/auto_form/providers/auto_form_provider.dart`
  - `core/services/csv_scheme_service.dart`
  - `app.dart`

---

