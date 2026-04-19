# Civic Voice - Architecture and Design

## 🏛️ Application Architecture

Civic Voice is built upon a scalable, modular architecture leveraging the Flutter framework for the frontend client and AWS Amplify for cloud infrastructure. 

### Frontend Organization

The Flutter client employs a feature-first architectural pattern combined with Provider for robust state management.

1.  **Core (`lib/core/`)**:
    *   **Theme**: Centralized definitions for colors (`AppColors`), typography (`GoogleFonts`), and stylistic constants.
    *   **Routing**: Defined using `go_router` for deep linking and straightforward navigation.
    *   **Services**: Abstraction layers for backend communication (`ApiService`, `AuthService`, `CitizenProfileService`).
2.  **Features (`lib/features/`)**:
    *   **Auth**: Login, signup, verification, and reset flows handling the entry and authentication state.
    *   **Dashboard**: The primary user hub, available in Data-Rich (Main) and Minimalist (Premium) variants.
    *   **Services**: Interactive directory, categorization, and detailed guides for public services.
    *   **Voice (CVI)**: The conversational AI interface, implementing voice-to-text, generative AI inference, and text-to-speech.
    *   **Profile**: User data management and application history tracking.
3.  **State Management (`lib/providers/`)**:
    *   `AuthProvider`: Manages the Cognito session lifecycle.
    *   `UserProvider`: Centralizes access to the active user's details and active applications.
    *   `ConversationProvider`: Manages the history and state of interaction with the AI assistant.
    *   `LanguageProvider`: Facilitates instantaneous, app-wide language switching (English/Hindi).
    *   `ServicesProvider`: Caches and provides data related to the various available government services.
    *   `AnalyticsProvider`: Tracks non-identifiable usage statistics for performance monitoring.
    *   `NotificationProvider`: Manages in-app alerts and notifications.
4.  **Widgets (`lib/widgets/`)**:
    *   Reusable UI components enforcing consistency (e.g., `IndianCard`, `JaliPattern`, `TricolorBar`, `BilingualLabel`).

### Cloud Architecture (AWS Amplify)

The backend infrastructure is provisioned and managed entirely via AWS Amplify.

1.  **Authentication (Amazon Cognito)**:
    *   Handles secure user registration, verification, and JWT token issuance.
2.  **API & Data (AWS AppSync & DynamoDB)**:
    *   GraphQL API mapping directly to DynamoDB tables for storing user profiles, service details, and application data. Models are automatically synchronized using DataStore/API capabilities.
3.  **Artificial Intelligence (Amazon Bedrock via API Gateway/Lambda)**:
    *   The `CVI` Voice feature utilizes Amazon Bedrock (invoking models like Meta Llama 3) to process natural language queries regarding civic services and respond intelligently to the user.

## 🎨 Design System

The visual design of Civic Voice is a core focus, aiming for a "premium" feel that is both accessible and culturally resonant.

*   **Color Palette**: Grounded in deep, sophisticated backgrounds (`bgDeep`: 0xFF121212) contrasted with vibrant accent colors inspired by the Indian flag (Saffron, White, Emerald, Navy, and elegant Gold).
*   **Typography**: A modern pairing of `Playfair Display` for elegant primary headings, `Poppins` for clean, legible body text and UI elements, and `Noto Sans Devanagari` for precise Hindi rendering.
*   **Visual Motifs**: Integration of subtle cultural elements such as glassmorphic `IndianCard` components, semi-transparent `JaliPattern` overlays, and waving `TricolorBar` accents to instill trust and familiarity.
*   **Motion**: Extensive use of `flutter_animate` for smooth transitions, list loading staggers, and dynamic interaction feedback (such as the pulsing microphone in the Voice interface).
*   **Accessibility**: High color contrast ratios, clear bilingual labeling, and a Voice-First UI approach for the core assistant feature.
