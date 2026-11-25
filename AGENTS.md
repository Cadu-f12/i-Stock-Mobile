# Agent Guide

## Project purpose

I-STOCK Mobile is a Flutter mobile application for the I-STOCK inventory system at DDA Metalúrgica. Its intended scope is email/password sign-in, biometric unlocking of a valid signed-in session, viewing pastilles and managing their stock, and searching movement history.

## Source of truth

- For interface design standards, consult [`docs/design_system.md`](docs/design_system.md).
- For system requirements, consult [`docs/requirements.md`](docs/requirements.md).
- Follow the real I-STOCK API contract for endpoints, payloads, identifiers, authentication, and accepted operations. Do not invent API behavior.

## Current repository state

This repository is currently a Flutter starter project. The platform host folders (`android/`, `ios/`, `linux/`, and `web/`) and the Dart/test folders exist, but the application feature architecture has not yet been implemented. The product target is mobile; the existence of other Flutter platform folders does not add them to product scope.

Current relevant files:

- `lib/main.dart` is still Flutter's initial counter example (`MyApp`, `MyHomePage`, and the increment button).
- `test/widget_test.dart` is still the initial counter widget test.
- `pubspec.yaml` contains Flutter, `cupertino_icons`, `flutter_test`, and `flutter_lints`; no product architecture or API/biometric dependencies have been selected.
- `docs/requirements.md` and `docs/design_system.md` describe the intended product and UI behavior; they are context documents, not evidence that those features already exist in code.
- `README.md` and `README.pt-BR.md` are project documentation. Keep them separate from the AI context documents unless the user explicitly requests README changes.

The repository may contain additional generated or platform-specific files. Inspect the actual tree and current Git state before making assumptions, and preserve unrelated user work.

## Product rules agents must preserve

- The product has three screens: Login, Pastilles, and Movement history. Biometric unlocking is an authentication capability, not a separate screen. Do not add product screens without an approved requirements update.
- The Pastilles screen lists pastilles and supports stock entry and withdrawal. Pastille catalog maintenance is outside the current scope.
- Every successful stock operation must be associated with its pastille and appear in movement history. History is read-only; do not edit or remove recorded movements.
- Protected screens require a signed-in user. The API issues bearer JWTs that expire after 15 minutes and does not provide refresh tokens. A biometric prompt may unlock a securely stored JWT only while that session remains valid; it cannot create or renew a session. After expiry, require email and password again. Never store the user's password.
- Biometric authentication is optional and must use the device's native authentication prompt. Keep email/password sign-in available if biometrics are unavailable, disabled, cancelled, or fail.
- Offline-first behavior, local notifications, and local photos are not part of the current requirements.
- Use the actual identity and API contracts for authentication and stock operations, including endpoints, formats, and responses. Never infer or fabricate missing details.

## Implementation guidance

When implementation begins, keep UI state explicit for loading, content, empty, error, and operation-in-progress cases. Consult `docs/requirements.md` before changing scope; if a requirement is missing or must change, explain the impact and request user approval before modifying the requirements document.

Use Flutter for the mobile client. Confirm the actual API request/response contract and choose the biometric and secure-storage integrations before implementation. Do not add map or location functionality. Add dependencies and architecture only as part of an explicitly requested implementation task.

## Change discipline

Before editing, inspect `git status` and the relevant files. Do not delete or overwrite existing user work. Keep changes scoped to the requested task, avoid commits unless explicitly requested, and verify documentation changes with a diff. Do not claim a feature is implemented merely because it is specified in the context documents.
