# Admitly — School Admission Management

Flutter + Firebase app for managing school admissions across two user roles.

---

## Roles & Flow

**Parent** — registers (email/password or Google), adds student details, optionally pays the registration fee, books an entrance exam slot, tracks application status.

**Admission Team** — logs in with predefined credentials (not publicly registerable). Views all applications, creates exam slots, enters exam scores, assigns courses.

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

## Tech Stack

`flutter_bloc`, `get_it`, `go_router`, `firebase_auth`, `google_sign_in`, `cloud_firestore`, `razorpay_flutter`, `flutter_secure_storage`, `local_auth`, `dartz`, `flutter_screenutil`

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
- Admission team accounts must be created manually in Firebase — there is no in-app registration flow for that role.
