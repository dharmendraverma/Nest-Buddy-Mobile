# NestBuddy Flutter App

Production-oriented Flutter quick-commerce app for mobile and web.

## Backend

API base URL:

```text
https://nestbuddy-backend-production.up.railway.app/api
```

Swagger/OpenAPI source:

```text
https://nestbuddy-backend-production.up.railway.app/api/docs
```

Implemented real API integrations:

- `GET /categories`
- `GET /categories/{slug}`
- `GET /products?category=&search=&page=&limit=`
- `POST /cart/items`
- `POST /orders`

## Firebase Phone Auth

OTP login uses Firebase Authentication, not the backend API.

Current Firebase packages:

- `firebase_core: ^4.9.0`
- `firebase_auth: ^6.5.1`

Configure Firebase before running:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

That command can replace `lib/firebase_options.dart` with your real Firebase project options. You can also pass the included template values through `--dart-define`, for example:

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_WEB_API_KEY=... \
  --dart-define=FIREBASE_WEB_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=...
```

Enable the Phone provider in Firebase Console > Authentication > Sign-in method.

The current Swagger document does not expose address endpoints, so address management is an app-local flow.

## Architecture

```text
lib/
  core/
    constants/
    network/
    theme/
    utils/
  routing/
  shared/
  features/
    auth/
    catalog/
    cart/
    address/
    checkout/
    orders/
    profile/
```

Each feature is split into `domain`, `data`, and `presentation` where applicable. State is managed with Riverpod, navigation with GoRouter, networking with Dio, and immutable models are declared with Freezed.

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

For mobile:

```bash
flutter run
```
