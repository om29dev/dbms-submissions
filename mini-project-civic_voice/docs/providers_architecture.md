# 🏗️ Architecture: `lib/providers`

This document contains an auto-generated structural analysis of all `.dart` files within `lib/providers`.

## 📄 File: `providers/accessibility_provider.dart`
- **Lines of code**: 86
- **Component Type**: 🔄 State Provider
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`

---

## 📄 File: `providers/achievement_provider.dart`
- **Lines of code**: 58
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `Achievement`
  - `AchievementProvider` extends `ChangeNotifier`

---

## 📄 File: `providers/analytics_provider.dart`
- **Lines of code**: 69
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `AnalyticsProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `package:amplify_flutter/amplify_flutter.dart`

---

## 📄 File: `providers/application_tracker_provider.dart`
- **Lines of code**: 56
- **Component Type**: 🔄 State Provider
- **Dependencies**:
  - `../models/app_tracker_model.dart`

---

## 📄 File: `providers/auth_provider.dart`
- **Lines of code**: 323
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `AuthProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `package:amplify_flutter/amplify_flutter.dart`
  - `../models/user_model.dart`

---

## 📄 File: `providers/citizen_profile_provider.dart`
- **Lines of code**: 93
- **Component Type**: 🔄 State Provider
- **Dependencies**:
  - `../models/citizen_profile_model.dart`

---

## 📄 File: `providers/community_provider.dart`
- **Lines of code**: 75
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `VerificationRequest`

---

## 📄 File: `providers/complaint_provider.dart`
- **Lines of code**: 108
- **Component Type**: 🔄 State Provider
- **Dependencies**:
  - `package:geolocator/geolocator.dart`
  - `../models/complaint_model.dart`

---

## 📄 File: `providers/conversation_provider.dart`
- **Lines of code**: 125
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `ConversationProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `../models/conversation_model.dart`
  - `../core/services/reasoning_engine.dart`

---

## 📄 File: `providers/document_scanner_provider.dart`
- **Lines of code**: 53
- **Component Type**: 🔄 State Provider

---

## 📄 File: `providers/document_vault_provider.dart`
- **Lines of code**: 172
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `DocumentVaultProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `../core/services/document_vault_service.dart`
  - `../models/cvi_document_model.dart`

---

## 📄 File: `providers/eligibility_checker_provider.dart`
- **Lines of code**: 50
- **Component Type**: 🔄 State Provider

---

## 📄 File: `providers/gamification_provider.dart`
- **Lines of code**: 93
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `Badge`

---

## 📄 File: `providers/language_provider.dart`
- **Lines of code**: 219
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `LanguageProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `../core/constants/app_strings.dart`
  - `../services/translation_service.dart`

---

## 📄 File: `providers/notes_provider.dart`
- **Lines of code**: 92
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `Note`
- **Dependencies**:
  - `package:record/record.dart`
  - `package:audioplayers/audioplayers.dart`
  - `package:path_provider/path_provider.dart`
  - `../core/services/reminder_service.dart`

---

## 📄 File: `providers/notification_provider.dart`
- **Lines of code**: 204
- **Component Type**: 🔄 State Provider, 📦 Data Model
- **Classes**:
  - `CVINotification`
  - `NotificationProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `../core/services/notification_service.dart`

---

## 📄 File: `providers/offline_guidance_provider.dart`
- **Lines of code**: 119
- **Component Type**: 🔄 State Provider, 📦 Data Model
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `../models/offline_guide_model.dart`

---

## 📄 File: `providers/scheme_discovery_provider.dart`
- **Lines of code**: 85
- **Component Type**: 🔄 State Provider
- **Dependencies**:
  - `../models/scheme_discovery_model.dart`

---

## 📄 File: `providers/services_provider.dart`
- **Lines of code**: 286
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `ServicesProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`
  - `../models/service_model.dart`
  - `../data/mock/services_data.dart`
  - `../data/csv_schemes_loader.dart`

---

## 📄 File: `providers/theme_provider.dart`
- **Lines of code**: 37
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `ThemeProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:shared_preferences/shared_preferences.dart`

---

## 📄 File: `providers/user_provider.dart`
- **Lines of code**: 376
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `UserProfile`
  - `UserProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `../models/document_model.dart`
  - `../models/application_model.dart`
  - `../models/family_member_model.dart`
  - `../core/services/aws_amplify_service.dart`

---

## 📄 File: `providers/voice_provider.dart`
- **Lines of code**: 330
- **Component Type**: 🔄 State Provider
- **Classes**:
  - `VoiceProvider` extends `ChangeNotifier`
- **Dependencies**:
  - `package:permission_handler/permission_handler.dart`
  - `package:speech_to_text/speech_to_text.dart`
  - `package:flutter_tts/flutter_tts.dart`

---

