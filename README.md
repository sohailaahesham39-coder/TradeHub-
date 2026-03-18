# 🏪 Trade Hub

### *The smart B2B marketplace — connect, collaborate, and trade without limits.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?logo=firebase)](https://firebase.google.com)
[![Provider](https://img.shields.io/badge/Provider-State%20Management-0175C2)](https://pub.dev/packages/provider)
[![Hive](https://img.shields.io/badge/Hive-Local%20DB-FF9900)](https://pub.dev/packages/hive)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=flutter)](https://flutter.dev)

---

## 📖 About Trade Hub

**Trade Hub** is a full-featured **B2B (Business-to-Business) Marketplace** mobile application built with Flutter. It provides a unified platform for suppliers, buyers, and service providers to discover products, book business events, process secure payments, and build professional networks — all within one app.

Built as a graduation project at **Sadat Academy for Management Sciences**, Trade Hub stands out with its **dual-language support (English & Arabic with RTL)**, **dark/light theme switching**, **glassmorphism UI**, **WCAG accessibility compliance**, and an integrated **CI/CD testing strategy** with over 80% code coverage target.

---

## 🚀 Key Features

- 📦 **Product & Supplier Discovery** — Browse detailed product listings and supplier profiles for informed B2B decisions
- 🗓️ **Event Booking & Calendar** — Discover business events, book tickets, and manage schedules with `table_calendar`
- 🗺️ **Interactive Business Maps** — Google Maps integration for locating suppliers and event venues
- 💳 **Secure Multi-Method Payments** — Stripe-powered transactions with order summaries and confirmations
- 📱 **QR Code Integration** — Generate and scan QR codes for event tickets and product verification
- 🔔 **Real-Time Notifications** — Firebase Cloud Messaging for instant business alerts and updates
- 🧾 **Personalized Dashboard** — Booking history, order tracking, and profile management
- 🌐 **English & Arabic (RTL)** — Full dual-language support with right-to-left layout compatibility
- 🌙 **Dark / Light Theme** — Dynamic theme switching with glassmorphism design elements
- ♿ **WCAG Accessibility** — Inclusive design compliant with web accessibility standards
- 📤 **Content Sharing** — Share products, events, and listings via `share_plus`
- 🖼️ **Image Upload & Storage** — Image picker with Firebase Storage for product and profile photos
- 📦 **Offline-Ready with Hive** — Local NoSQL database for caching and offline access
- 📐 **Responsive Design** — Pixel-perfect layouts across all screen sizes using `flutter_screenutil`
- ✨ **Animated UI** — Smooth transitions and shimmer loading states via `animate_do` and `shimmer`
- 🧪 **Comprehensive Testing** — Unit, widget, and integration tests with 80%+ code coverage target

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.7.2 |
| **State Management** | Provider 6.x |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Cloud Database** | Cloud Firestore (real-time NoSQL) |
| **Local Database** | Hive (fast, lightweight NoSQL) |
| **File Storage** | Firebase Storage |
| **Networking** | Cached Network Image, Flutter Cache Manager |
| **Localization** | flutter_localization + Intl (EN & AR/RTL) |
| **UI Design** | Glassmorphism UI, Google Fonts |
| **Calendar** | table_calendar |
| **Responsive Layout** | flutter_screenutil |
| **Animations** | animate_do, shimmer |
| **Onboarding** | smooth_page_indicator |
| **Image Handling** | image_picker, path_provider |
| **File Management** | flutter_archive, path_provider |
| **Sharing** | share_plus |
| **Data Collections** | collection |
| **CI/CD** | GitHub Actions (flutter test --coverage) |
| **Design Tools** | Figma |
| **Version Control** | Git & GitHub |
| **App Icon** | Flutter Launcher Icons |

---

## 🏗️ Project Structure

```
trade_hub/
├── lib/
│   ├── core/                          # App-wide config & utilities
│   │   ├── theme/                     # Light/dark themes, glassmorphism styles
│   │   ├── localization/              # EN & AR translations, RTL support
│   │   └── utils/                     # Helpers, validators, formatters
│   ├── data/                          # Data layer
│   │   ├── models/                    # Product, Supplier, Event, Booking, User models
│   │   ├── repositories/              # Firestore & Hive repositories
│   │   └── local/                     # Hive adapters & local cache
│   ├── providers/                     # Provider state management
│   │   ├── auth_provider.dart         # Firebase Auth state
│   │   ├── product_provider.dart      # Product listing & filter state
│   │   ├── event_provider.dart        # Event & calendar state
│   │   └── theme_provider.dart        # Dark/light theme toggle state
│   ├── screens/                       # 10+ feature-based UI screens
│   │   ├── auth/                      # Login & Register
│   │   ├── home/                      # Dashboard with personalized feed
│   │   ├── products/                  # Product listings & supplier profiles
│   │   ├── events/                    # Event discovery, calendar & ticket booking
│   │   ├── map/                       # Business connection map (Google Maps)
│   │   ├── payment/                   # Stripe payment & order confirmation
│   │   ├── notifications/             # FCM notification center
│   │   ├── settings/                  # Language, theme & accessibility settings
│   │   └── profile/                   # User profile & booking history
│   ├── widgets/                       # Reusable modular UI component library
│   │   ├── product_card.dart          # Shimmer-loading product card
│   │   ├── event_tile.dart            # Event calendar tile
│   │   ├── glass_card.dart            # Glassmorphism card component
│   │   └── qr_widget.dart             # QR code generator/scanner widget
│   └── main.dart                      # App entry point & Firebase init
├── assets/
│   └── icons/
│       └── icons.jpg
├── test/                              # Unit, widget & integration tests
├── integration_test/                  # End-to-end integration tests
├── pubspec.yaml
└── README.md
```

> 📌 The project uses **Provider** with a **modular component-based architecture**, enabling reusable UI, clean separation of concerns, and a scalable B2B platform ready for future expansion.

---

## ⚙️ Getting Started

### Prerequisites

- Flutter SDK `^3.7.2` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK `^3.7.2`
- Android Studio / Xcode
- Firebase project with Auth, Firestore & Storage enabled

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/sohailaahesham39-coder/TradeHub-.git
cd trade_hub

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# - Place google-services.json in android/app/
# - Place GoogleService-Info.plist in ios/Runner/

# 4. Generate app icons
dart run flutter_launcher_icons

# 5. Run tests with coverage
flutter test --coverage

# 6. Run the app
flutter run
```

---

## 🗃️ Database Design (ERD Summary)

| Entity | Key Attributes |
|---|---|
| **User** | userID (PK), name, email, businessType, language, theme |
| **Product** | productID (PK), supplierID (FK), name, category, price, images |
| **Supplier** | supplierID (PK), companyName, location, rating, products |
| **Event** | eventID (PK), title, date, location, ticketPrice, capacity |
| **Booking** | bookingID (PK), userID (FK), eventID/productID (FK), status, date |
| **Payment** | paymentID (PK), userID (FK), bookingID (FK), amount, method |

---

## 🎓 Academic Context

> **Graduation Project** — Sadat Academy for Management Sciences, Faculty of Computers and Information
>
> **Supervisor:** Dr. Heba Sabry
>
> **Team:** Ahmed Waleed Ahmed · Ali Hamed · Anas Ashraf Hassan · Mariam Mostafa Kamel

---

## 🔮 Future Roadmap

- 🤖 **AI Business Matching** — Smart supplier-buyer recommendations
- 📹 **In-App Video Conferencing** — Real-time meetings for product demos
- 📊 **Advanced Analytics Dashboard** — Trade insights and sales trends
- 🔗 **Blockchain Verification** — Secure high-value transaction audit trails
- 📴 **Offline Mode** — Full access to bookings and QR codes without internet
- 🎁 **Loyalty & Rewards** — Points system for active traders and referrals

---

<div align="center">
  <sub>Built with 💙 using Flutter · Powered by Firebase & Hive · Glassmorphism UI · EN/AR RTL</sub><br/>
  <sub>⭐ Star this repo if you found it helpful!</sub>
</div>
