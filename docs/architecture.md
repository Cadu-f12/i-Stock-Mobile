# I-STOCK Mobile — Architecture and folder structure

This document describes the architecture that currently exists in the Flutter app. The intended product scope is in [`requirements.md`](requirements.md), visual guidance is in [`design_system.md`](design_system.md), and API contracts are in [`api/openapi.yaml`](api/openapi.yaml). A folder listed here does not imply that every planned feature has been implemented.

## Application structure

The app currently uses a small feature-oriented separation of responsibilities for login:

```text
lib/
├── main.dart
├── cubits/
├── exceptions/
├── models/
├── repositories/
├── states/
└── views/
```

- `main.dart` is the composition root: it loads environment configuration, creates the login repository, secure session store, and native device authenticator, provides `LoginCubit`, and starts the Flutter app.
- `views/` contains screens and UI widgets. `login_page.dart` renders the login form; `pastilles_placeholder_page.dart` is only a temporary destination after successful login.
- `cubits/` contains Cubit classes that handle user actions and coordinate the view with repositories. `login_cubit.dart` owns login, optional biometric unlock, session expiry, and sign-out.
- `states/` contains the explicit UI states consumed by the views. `login_state.dart` defines the shared login state and its initial, error, loading, and loaded variants.
- `models/` contains data objects passed between layers, such as login credentials, the session returned by the API, and the locally stored session with its expiry.
- `repositories/` defines data-access contracts and their implementations. The login repository calls I-STOCK Manager; the session store uses platform-secure storage, and the device authenticator uses the native biometric prompt with device credential fallback.
- `exceptions/` contains login-specific exceptions used to communicate request, response, and credential failures from the repository to the Cubit.

For the implemented login flow, the view sends actions to the Cubit; the Cubit validates input and calls the repository; the repository communicates with the API and returns a model or raises an exception; the Cubit emits a state for the view to render. After password login, the user can opt in to saving a short-lived session. The lock action returns to Login without clearing that session; sign-out clears it. On a later launch or after locking, the Cubit checks its expiry and invokes device authentication before reading the saved JWT.

## Tests

```text
test/
├── cubits/
├── repositories/
└── widget_test.dart
```

- `test/cubits/` covers login state transitions, session expiry, and biometric unlock behavior.
- `test/repositories/` covers HTTP requests and API response handling with a controlled client.
- `test/widget_test.dart` covers login screen behavior, opt-in, and unlock navigation. `test/helpers/` holds controlled session and device-authentication fakes.
- Keep Flutter feature tests, fixtures, and helpers under `test/`. See the testing rules in [`AGENTS.md`](../AGENTS.md).

## Documentation and platform folders

- `docs/` contains product requirements, visual guidance, this architecture guide, and the API contract in `docs/api/openapi.yaml`.
- `android/` and `ios/` contain Flutter host projects and native configuration for the mobile platforms.
- `linux/` and `web/` are generated Flutter host targets currently present in the repository; their presence does not add them to the mobile product scope.
- Root configuration files such as `pubspec.yaml` declare Dart/Flutter dependencies, assets, and package settings; `analysis_options.yaml` configures Dart analysis.

## Current boundaries

Login is the only implemented API-backed feature. Optional biometric unlocking and secure session storage are implemented for Android and iOS; Pastilles remains a placeholder, and stock operations and movement history have not been implemented. Add new layers or folders only when a feature needs them, and keep tests for each new feature under `test/`.
