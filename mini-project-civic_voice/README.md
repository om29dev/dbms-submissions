# Civic Voice — CVI

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.27%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.6%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AWS](https://img.shields.io/badge/AWS_Amplify-Powered-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![AI](https://img.shields.io/badge/Amazon_Bedrock-AI-8A2BE2?style=for-the-badge&logo=amazonaws&logoColor=white)

<br/>

> **"Bridging the gap between citizens and the services that matter most."**

Civic Voice is a modern, premium Flutter application designed to empower every citizen of Bharat by providing a centralized, voice-first platform for navigating government services, discovering welfare schemes, and receiving AI-powered guidance — all in their language.

</div>

---

## 🌟 Overview

Navigating government services in India is often complex, inaccessible, and overwhelming. **Civic Voice** changes that. By combining a meticulously crafted UI, a conversational AI assistant (CVI), bilingual support, and a robust AWS cloud backend, Civic Voice delivers an unprecedented, dignified digital experience to every citizen — from metros to villages.

---

## ✨ Key Features

### 🎙️ CVI — Your AI Civic Assistant
A completely custom, intelligent voice and text assistant powered by **Amazon Bedrock (Meta Llama 3)**. Ask questions about government schemes, eligibility, documentation, and procedures in both **English and Hindi** — and receive accurate, contextual answers in seconds.

### 🗂️ Government Services Hub
A comprehensive, searchable directory of public services — **Aadhaar, PAN, Passport, Ration Card, Driving License, and more** — complete with step-by-step guides, required documents, timelines, fee structures, and official application links.

### 🔍 AI Eligibility Checker
An intelligent, multi-step flow that analyses your profile data and tells you exactly which government schemes you qualify for, with a **Civic Confidence Gauge** scoring your eligibility in real-time.

### 📄 Smart Document Vault
A biometric-secured, encrypted personal vault to safely store, manage, and retrieve your critical documents (Aadhaar, PAN, certificates). Features **AI-powered scanning** and automatic inference of document fields.

### 🤖 Auto-Form Assistant
A guided, voice-enabled form-filling flow that pre-populates government application forms using data from your Document Vault and Citizen Profile, then launches a **Smart Browser** for seamless in-app guided submission.

### 🏅 Citizen Profile & Gamification
A centralized digital citizen profile to manage personal information and family members, track application statuses, and earn **achievements and badges** as you complete civic tasks.

### 📍 Office Locator
Locate the nearest government offices with GPS-powered maps and direct navigation links, making in-person visits effortless.

### 🔔 Smart Notifications & Reminders
Stay on top of application deadlines, scheme expiry dates, and important announcements with intelligent, scheduled local notifications.

### 🌐 Offline-First Guidance
A curated offline knowledge base ensures core service information and emergency guidance remain accessible even without an internet connection.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter 3.27+ / Dart 3.6+ | Cross-platform mobile & web UI |
| **State Management** | Provider `^6.1.2` | Reactive application state |
| **Routing** | GoRouter `^17.1.0` | Declarative deep-link routing |
| **AI Assistant** | Amazon Bedrock (Meta Llama 3) | Generative AI via API Gateway/Lambda |
| **Authentication** | AWS Amplify + Amazon Cognito | Secure user auth & JWT tokens |
| **Database** | Amazon DynamoDB via AppSync | GraphQL API & NoSQL data storage |
| **Storage** | Supabase Storage / AWS S3 | Document and media storage |
| **Voice** | `speech_to_text` + `flutter_tts` | Client-side STT & TTS |
| **Animations** | `flutter_animate` + `lottie` | Smooth, declarative UI motion |
| **Maps** | Google Maps Flutter | GPS-powered office locator |
| **Security** | `flutter_secure_storage` + `local_auth` | Biometric document vault |
| **Typography** | Google Fonts (Playfair Display, Poppins) | Premium bilingual typography |

---

## 🏗️ Architecture Overview

Civic Voice follows a **Feature-First architectural pattern** on the Flutter client, backed by a fully managed AWS cloud infrastructure.

```
civic_voice/
├── lib/
│   ├── core/           # Theme, routing, services, AI reasoning engine
│   ├── features/       # Modular feature screens (auth, dashboard, services, voice…)
│   ├── models/         # Data structures (User, Service, Scheme, Document…)
│   ├── providers/      # State management controllers (Auth, Language, Voice…)
│   ├── services/       # Business logic abstraction layers
│   └── widgets/        # Reusable, branded UI components
├── assets/             # Lottie animations, images, icons, data (CSV)
├── docs/               # Detailed architectural documentation
└── amplify/            # AWS Amplify backend configuration
```

### Pipeline Flow

```
User Input (Voice / Touch)
        │
        ▼
   Intent Engine  ──►  ReasoningEngine (Amazon Bedrock)
        │                       │
        ▼                       ▼
  Services Provider      Scheme Knowledge Base
        │                       │
        ▼                       ▼
    UI Renderer  ◄──  ResponseGenerator (Bilingual)
```

---

## 🎨 Design System

The visual identity of Civic Voice is crafted to feel **premium, culturally resonant, and deeply accessible**:

- **Color Palette**: Deep sophisticated backgrounds (`#121212`) contrasted with vibrant accents inspired by the Indian Tricolor — Saffron, Emerald, Navy, and elegant Gold.
- **Typography**: `Playfair Display` for headings, `Poppins` for UI text, and `Noto Sans Devanagari` for precise Hindi rendering.
- **Visual Motifs**: Glassmorphic `IndianCard` components, semi-transparent `JaliPattern` overlays, and animated `TricolorBar` accents.
- **Motion**: Fluid micro-animations via `flutter_animate` with staggered list loads and a pulsing voice interface.
- **Accessibility**: High-contrast ratios, bilingual labels throughout, and a voice-first UX as the primary interaction model.

---

## 📚 Documentation Index

Deep dive into the specifics of Civic Voice's architecture:

| Document | Description |
|---|---|
| 🏗️ [Root Architecture](./docs/root_architecture.md) | Top-level project structure and entry-point overview |
| ⚙️ [Core Architecture](./docs/core_architecture.md) | Theme, routing, services, and AI reasoning engine |
| 🧩 [Features Architecture](./docs/features_architecture.md) | Every feature module — screens, providers, widgets |
| 🗃️ [Models Architecture](./docs/models_architecture.md) | All data models and entity structures |
| 🔄 [Providers Architecture](./docs/providers_architecture.md) | State management layer and provider contracts |
| 🔌 [Services Architecture](./docs/services_architecture.md) | Backend and business logic service abstractions |
| 🎨 [Widgets Architecture](./docs/widgets_architecture.md) | Reusable UI component library |
| 💾 [Data Architecture](./docs/data_architecture.md) | Data flow, persistence, and storage strategy |
| 🖌️ [Design System](./design.md) | Colors, typography, motifs, and motion design |
| 📋 [Requirements & Setup](./requirements.md) | System requirements and environment configuration |

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | `>= 3.27.0` (stable channel) |
| Dart SDK | `>= 3.6.0` |
| Android Studio / VS Code | Latest with Flutter/Dart extensions |
| AWS CLI | Configured with IAM admin permissions |
| Amplify CLI | `npm install -g @aws-amplify/cli` |

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/civic_voice.git
   cd civic_voice
   ```

2. **Pull backend environment** *(if connecting to existing AWS backend)*
   ```bash
   amplify pull
   ```

3. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure Environment Variables**

   Create a `.env` file in the project root:
   ```env
   # AWS / AI
   API_GATEWAY_URL=your_api_gateway_url
   BEDROCK_REGION=ap-south-1

   # Supabase (Document Vault)
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key

   # Google Maps
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

The project follows a feature-first architectural pattern:

*   `lib/core/`: Application-wide constants, networking, routing, and theme definitions.
*   `lib/features/`: Individual feature modules (auth, dashboard, services, voice, profile).
*   `lib/models/`: Data structures representing application entities.
*   `lib/providers/`: State management controllers handling business logic.
*   `lib/widgets/`: Reusable, custom UI components.

## 🤝 Contributing

We welcome contributions from the community! Whether it's bug fixes, new features, or documentation improvements.

1. **Fork** the repository
2. Create your **feature branch**: `git checkout -b feature/YourAmazingFeature`
3. **Commit** your changes: `git commit -m 'feat: add YourAmazingFeature'`
4. **Push** to the branch: `git push origin feature/YourAmazingFeature`
5. Open a **Pull Request**

Please ensure your code follows Flutter's official style guide and that `flutter analyze` passes before submitting.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📬 Contact

Project Link: [https://github.com/om29dev/civic_voice](https://github.com/om29dev/civic_voice)

---

<div align="center">
  <i>Built with ❤️ for Bharat — empowering every citizen, one voice at a time.</i>
</div>
