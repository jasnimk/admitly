# Admitly — School Admission Management

Flutter + Firebase app for managing school admissions across two user roles.

---

## Roles & Flow

**Parent** — registers (email/password or Google), adds student details, optionally pays the registration fee, books an entrance exam slot, tracks application status.

**Admission Team** — registers through the same screen (selecting the Admission Team role), pending admin approval before access is granted. Views all applications, creates exam slots, enters exam scores, assigns courses.

**Status pipeline:**
```
applicationCreated → feePaid / feeSkipped → slotBooked → examCompleted → admissionCompleted
```

---

## Architecture

Feature-based Clean Architecture with strict layer separation per feature.

```
feature/
├── data/         # Firestore datasource, models, repository implementation
├── domain/       # Entities, repository contracts, use cases
└── presentation/ # BLoC (events, states), screens, widgets
```

Features: `auth`, `student`, `payment`, `exam_slot`, `home`, `profile`, `splash`

Shared: `lib/core/` — colors, text styles, theme, services, base use case, shared widgets.

BLoC handles all state — loading, success, error. No Firebase calls in UI widgets.

---

## Authentication Notes

**Google Sign-In** — if no existing account is found in Firestore for the Google user, they are automatically registered as a Parent. There is no role selection for Google sign-in.

**Admission Team accounts** — registered through the app's register screen (Admission Team role option). The account starts with `isVerified: false`; the n8n webhook fires immediately after registration to notify the admin. The admin sets `isVerified: true` in Firestore via the n8n flow. Until approved, the member sees a pending screen with a "Check Status" button.

---

## Automation — n8n Integration

When a new Admission Team account is created, the app fires a fire-and-forget HTTP POST:

```
POST https://admitly.app.n8n.cloud/webhook/admitly-register
{ "userId": "...", "email": "...", "name": "...", "adminEmail": "..." }
```

Non-blocking — if it fails, the account creation still succeeds and the error is only logged locally. The n8n workflow handles the downstream approval notification. The webhook URL and admin email are defined in `AppConstants`.

---

## Tech Stack

`flutter_bloc`, `get_it`, `firebase_auth`, `google_sign_in`, `cloud_firestore`, `razorpay_flutter`, `flutter_secure_storage`, `local_auth`, `dartz`, `flutter_screenutil`

Testing: `bloc_test`, `mocktail`

---

## Tests

```bash
flutter test
```

19 unit tests — `StudentBloc` (10 cases: load, create, update, delete, status transitions) and `ExamSlotBloc` (9 cases: load, create, book, Firestore transaction path, entity properties).

---

## Known Issues

- Exam slot booking transaction runs client-side. The Firestore rule currently allows any authenticated user to update a slot so the booking transaction can increment `bookedCount`. Ideally this moves to a Cloud Function with field-level validation.
- Razorpay test mode has limited payment methods without KYC activation. Net banking works; card/UPI may not in test.
