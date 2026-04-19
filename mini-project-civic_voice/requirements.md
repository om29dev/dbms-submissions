# Civic Voice - Project Requirements & Setup

## 🛠️ System Requirements

To build, run, and develop the Civic Voice application, ensure your environment meets the following specifications:

*   **Operating System**: macOS (for iOS/macOS builds), Windows, or Linux.
*   **Flutter SDK**: Version `3.27.0` or higher.
*   **Dart SDK**: Version `3.6.0` or higher.
*   **IDE**: Android Studio, IntelliJ IDEA, or Visual Studio Code with Flutter/Dart extensions installed.
*   **Emulators**: Android Emulator (API level 24+) or iOS Simulator (iOS 13.0+).

## ☁️ Cloud Infrastructure Requirements (AWS)

Civic Voice relies on AWS Amplify for its secure, scalable backend.

*   **AWS CLI**: Configured with an IAM user possessing administrator permissions.
*   **Amplify CLI**: Installed globally (`npm install -g @aws-amplify/cli`).
*   **AWS Services Utilized**:
    *   **Amazon Cognito**: For robust User Pools and Identity Pools (Authentication).
    *   **AWS AppSync**: Managed GraphQL API service.
    *   **Amazon DynamoDB**: NoSQL database for structured profile and application data.
    *   **Amazon Bedrock**: For advanced generative AI capabilities powering the CVI assistant.

## 📦 Key Dependencies (`pubspec.yaml`)

The application integrates several key Flutter packages to deliver a premium experience:

*   **State & Architecture**:
    *   `provider`: `^6.1.2` (State management)
    *   `go_router`: `^14.6.2` (Declarative routing)
*   **UI & Styling**:
    *   `google_fonts`: `^6.2.1` (Dynamic typography)
    *   `flutter_animate`: `^4.5.2` (Declarative, fluid animations)
*   **AWS Framework**:
    *   `amplify_flutter`: `^2.4.1` (Core AWS Amplify integration)
    *   `amplify_auth_cognito`: `^2.4.1` (Authentication workflows)
    *   `amplify_api`: `^2.4.1` (GraphQL/REST API operations)
*   **AI Integration**:
    *   `http`: `^1.2.1` (Network requests to the API Gateway)
    *   `speech_to_text`: `^7.0.0` (Client-side localized voice recognition)
    *   `flutter_tts`: `^4.0.2` (Client-side text-to-speech feedback)

## 🚀 Environment Setup

1.  **Clone the Repository**.
2.  **Pull Backend Environment**:
    *   If working with an existing project, run `amplify pull` to synchronize the active cloud environment with your local `.amplify` configuration.
3.  **Install Packages**:
    *   Execute `flutter pub get` in the project root to fetch all dependencies.
4.  **Launch the App**:
    *   Select your target emulator or physical device and run `flutter run` or utilize your IDE's Run button.