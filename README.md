# Admitly — School Admission Management App

A Flutter mobile application for managing school admissions, built with Clean Architecture and Firebase.

---

## Features

### Parent Flow
- **Register / Login** — email & password or Google Sign-In
- **Student Applications** — create multiple student profiles with documents
- **Registration Fee Payment** — Razorpay integration (₹500 one-time fee)
- **Exam Slot Booking** — browse available slots and book for each student
- **Application Tracking** — real-time status updates across the full pipeline

### Admin Flow
- **Application Dashboard** — view all student applications with status filters
- **Admit / Reject** — approve or reject applications
- **Score Entry** — record exam scores per student
- **Course Assignment** — assign students to courses (Grade 1–6)
- **Exam Slot Management** — create and manage available exam slots

### Status Pipeline
```
applicationCreated → feePaid / feeSkipped → slotBooked → admissionCompleted / rejected
```

---

## Architecture

Feature-based Clean Architecture with strict layer separation:

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTextStyles, AppDimensions
│   ├── errors/           # Failure types
│   ├── services/         # AuthService, FirestoreService
│   ├── theme/            # ThemeData, AppTheme
│   ├── usecases/         # Base UseCase<Type, Params>
│   ├── utils/            # Extensions, helpers
│   └── widgets/          # Shared: AppButton, AppBottomSheet, AppStatusBadge, …
│
└── features/
    ├── auth/             # Login, Register, Google Sign-In
    ├── student/          # Student CRUD, BLoC, status workflow
    ├── payment/          # Razorpay, PaymentEntity, Firestore write
    ├── exam_slot/        # Slot creation, booking, BLoC
    ├── admin/            # Admin-only application review screens
    ├── home/             # ParentHomeScreen, AdminDashboardScreen
    ├── profile/          # User profile, sign-out
    └── splash/           # Splash → auth routing
```

Each feature follows:
```
feature/
├── data/
│   ├── datasources/      # Firestore remote datasource (abstract + impl)
│   ├── models/           # Firestore ↔ entity mappers
│   └── repositories/     # Repository implementation
├── domain/
│   ├── entities/         # Pure Dart entities
│   ├── repositories/     # Abstract repository contracts
│   └── usecases/         # One class per use-case
└── presentation/
    ├── bloc/             # BLoC events, states, logic
    ├── views/            # Full screens
    └── widgets/          # Screen-specific widgets / bottom sheets
```

**State management:** `flutter_bloc ^8.1.6` with `BlocConsumer` for listener + builder separation.  
**Dependency injection:** `get_it ^8.0.0` with a single `injection_container.dart`.  
**Navigation:** `go_router ^14.3.0` with role-based route guards.

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` |
| DI | `get_it` |
| Navigation | `go_router` |
| Backend | Firebase (Auth, Firestore) |
| Auth | `firebase_auth`, `google_sign_in` |
| Payments | `razorpay_flutter` |
| Functional errors | `dartz` |
| UI scaling | `flutter_screenutil` |
| Fonts | `google_fonts` (Plus Jakarta Sans) |
| Secure storage | `flutter_secure_storage` |
| Testing | `bloc_test`, `mocktail` |

---

## Setup

### Prerequisites
- Flutter 3.x
- Dart 3.x
- Firebase project with Auth + Firestore enabled
- Razorpay account (test key)

### 1. Clone
```bash
git clone <repo-url>
cd admitly
```

### 2. Firebase Configuration

This project uses `flutterfire` for Firebase setup. The config files are **gitignored** and must be generated locally:

```bash
flutterfire configure
```

This generates:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run
```bash
flutter run
```

---

## Firestore Security Rules

Security rules are in `firestore.rules`. Key policies:

- **users** — authenticated read; write only own document
- **students** — parent reads/writes own students; admission team reads all; parent may delete own `applicationCreated` students
- **examSlots** — authenticated read; admission team creates/updates/deletes
- **payments** — parent creates own; admission team reads all; no updates or deletes

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

### Composite Index (required)

Create this index manually in the Firebase Console → Firestore → Indexes:

| Collection | Field | Order |
|---|---|---|
| payments | parentId | Ascending |
| payments | paidAt | Descending |

---

## Razorpay Integration

- Uses `rzp_test_TvlQDkQAxJmT4S` (test key ID) — client-side only
- Key Secret **never** goes in the app; it belongs on a backend/webhook
- Amount: ₹500 (50000 paise)
- On success: student status → `feePaid`; `PaymentEntity` written to Firestore
- Test UPI ID: `success@razorpay`

> **Note:** Card/UPI payment methods require Razorpay KYC activation. Net banking works without activation.

---

## Running Tests

```bash
# All unit tests
flutter test test/

# BLoC tests only
flutter test test/features/
```

Tests cover:
- `StudentBloc` — 10 cases (load, create, update, delete, status workflow)
- `ExamSlotBloc` — 8 cases (load, book, create, entity properties)

---

## Design System

5-color palette enforced across all UI:

| Token | Hex | Use |
|---|---|---|
| Midnight (primary) | `#15171F` | Buttons, icons, headings |
| Slate (accent) | `#4A5568` | Accents |
| Fog (grey) | `#718096` | Subtle text, placeholders |
| Mist (border) | `#E2E8F0` | Dividers, borders |
| Canvas (background) | `#F0F2F4` | Screen backgrounds |

All text uses **Plus Jakarta Sans** via `AppTextStyles.plusJakartaSans(...)`.  
All spacing/sizing uses `flutter_screenutil` (design base: 390×844).

Shared widget library in `lib/core/widgets/`:
- `AppButton` — primary / outlined / text variants
- `AppBottomSheet` — standard sheet wrapper with handle, header, keyboard avoidance
- `AppSheetHandle` / `AppSheetHeader` — composable sheet chrome
- `AppSectionHeader` — section title + optional "View all" action
- `AppStatusBadge` — color-coded status pill
- `AppEmptyState` — empty list placeholder
- `AppSnackBar` — success / error / info toasts

---

## Assumptions

1. A single Razorpay test account is shared; KYC must be completed for full payment method support in production.
2. Admin role is set via Firestore `users/{uid}.role = 'admissionTeam'` — there is no in-app admin provisioning flow.
3. Registration fee is a fixed ₹500; no variable pricing logic is needed.
4. Exam slots are created by admission team staff only; parents browse and book from available slots.
5. `feeSkipped` is an allowed transition — an admission team member can manually advance an application even if fee is pending.
6. The app targets Android primarily; iOS support follows the same codebase but iOS-specific Razorpay setup (pod install) is required.
