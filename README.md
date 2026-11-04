# Admitly — School Admission Management

A Flutter mobile app for managing school admissions. Built for the machine task assessment.

---

## What it does

Two user roles — **Parent** and **Admission Team** — walk through a fixed admission pipeline:

**Parent**
- Register or sign in with Google
- Add student details and submit an application
- Optionally pay the registration fee (Razorpay test integration)
- Book one entrance exam slot from the available list
- Track the application status at every step

**Admission Team**
- Log in with predefined credentials (not publicly registerable)
- View all student applications, filtered by status
- Create and manage entrance exam slots
- Enter exam scores after the exam
- Assign a course once the exam is done

**Application status pipeline:**
```
applicationCreated → feePaid / feeSkipped → slotBooked → examCompleted → admissionCompleted
```

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc ^8.1.6` |
| Dependency injection | `get_it ^8.0.0` |
| Navigation | `go_router ^14.3.0` |
| Auth | `firebase_auth`, `google_sign_in` |
| Database | `cloud_firestore` |
| Payments | `razorpay_flutter ^1.3.6` |
| Secure storage | `flutter_secure_storage ^9.2.4` |
| Biometric auth | `local_auth ^2.3.0` |
| UI scaling | `flutter_screenutil ^5.9.3` |
| Fonts | `google_fonts` (Plus Jakarta Sans) |
| Error handling | `dartz` |
| Testing | `bloc_test`, `mocktail` |

---

## Architecture

Feature-based Clean Architecture. Each feature is split into three layers:

```
feature/
├── data/
│   ├── datasources/      # Firestore calls (abstract + impl)
│   ├── models/           # Firestore ↔ entity conversion
│   └── repositories/     # Implements the domain contract
├── domain/
│   ├── entities/         # Plain Dart classes, no framework deps
│   ├── repositories/     # Abstract contracts
│   └── usecases/         # One class per action
└── presentation/
    ├── bloc/             # Events, States, BLoC logic
    ├── views/            # Screens
    └── widgets/          # Widgets specific to this feature
```

Features:
```
lib/features/
├── auth/        # Login, register, Google sign-in, role routing
├── student/     # Student CRUD, status workflow, admin actions
├── payment/     # Razorpay flow, payment Firestore write
├── exam_slot/   # Slot creation (admin), slot booking (parent)
├── home/        # Admin dashboard, parent home
├── profile/     # Profile view, theme toggle, biometric toggle, logout
└── splash/      # Splash → auth check → role-based routing
```

Shared code lives in `lib/core/` — colors, text styles, theme, services, shared widgets, base use case.

---

## Setup

### Prerequisites
- Flutter 3.x / Dart 3.x
- A Firebase project with Authentication and Firestore enabled

### 1. Clone
```bash
git clone <repo-url>
cd admitly
```

### 2. Firebase configuration

The config files are gitignored. Generate them with FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This creates:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Enable these in the Firebase Console:
- Authentication → Email/Password
- Authentication → Google
- Firestore Database

### 3. Create the admission team account

The admission team cannot self-register. Create the account manually:

1. Firebase Console → Authentication → Add user (any email/password)
2. Firestore → `users` collection → document with that user's UID:
```json
{
  "uid": "<uid>",
  "email": "<email>",
  "name": "Admission Team",
  "role": "admissionTeam"
}
```

### 4. Install and run
```bash
flutter pub get
flutter run
```

---

## Firestore Security Rules

Deploy the included `firestore.rules`:
```bash
firebase deploy --only firestore:rules
```

Summary of what the rules enforce:
- **users** — each user reads/writes their own document; admission team can read all
- **students** — parents create and edit their own students; admission team reads/updates all; parents can delete only at `applicationCreated` status
- **examSlots** — authenticated read; admission team creates; authenticated update (needed for the client-side booking transaction)
- **payments** — parents create their own; admission team reads all; no updates or deletes

### Composite Index (required for payment history)

Create this manually in Firebase Console → Firestore → Indexes:

| Collection | Field | Order |
|---|---|---|
| `payments` | `parentId` | Ascending |
| `payments` | `paidAt` | Descending |

---

## Razorpay

Using test key `rzp_test_TvlQDkQAxJmT4S`. The key secret is never in the app.

To trigger a successful test payment, use UPI ID `success@razorpay` in the payment sheet. On success, a `PaymentEntity` is written to Firestore and the student status moves to `feePaid`.

> Card and UPI flows in the test environment may require Razorpay KYC activation on the account. Net banking works without it.

---

## Tests

```bash
flutter test
```

19 unit tests across two BLoC test files:

- `test/features/student/presentation/bloc/student_bloc_test.dart` — 10 cases covering load, create, update, delete, and status transitions
- `test/features/exam_slot/presentation/bloc/exam_slot_bloc_test.dart` — 9 cases covering load, slot creation, booking (including the transaction path), and entity properties

---

## Known Issues / Limitations

- **Exam slot booking transaction** runs client-side. The Firestore rule allows any authenticated user to update a slot so the transaction can increment `bookedCount`. In a production setup this would move to a Cloud Function with stricter field validation.
- **Razorpay on iOS** requires running `pod install` in the `ios/` directory and an Apple Developer account for certain payment methods.
- **Google Sign-In on Android** requires the SHA-1 fingerprint of the signing key to be added in the Firebase Console under Project Settings → Android app.
- **Payment methods** in the Razorpay test environment are limited without KYC activation on the Razorpay account.
- The admission team account must be created manually in Firebase — there is no in-app provisioning.
