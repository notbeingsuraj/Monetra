# Monetra – Flutter App

Premium P2P lending & financial management mobile app.

## Setup

```bash
cd flutter_app
flutter pub get
flutter run
```

## Architecture

- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Network**: Dio
- **Storage**: flutter_secure_storage
- **Font**: Inter (Google Fonts)

## Folder Structure

```
lib/
├── core/           # Theme, constants, shared widgets, utils
├── features/       # Auth, Dashboard, Transactions, Lending, Profile
│   └── [feature]/
│       ├── data/
│       ├── presentation/
│       └── logic/
├── services/       # API client, secure storage
└── main.dart
```
