# Agent Guide

## Project purpose

I-STOCK Mobile is a Flutter mobile application for the I-STOCK inventory system at DDA Metalúrgica. Its intended scope is email/password sign-in, biometric unlocking of a valid signed-in session, viewing pastilles and managing their stock, and searching movement history.

## Source of truth

- For interface design standards, consult [`docs/design_system.md`](docs/design_system.md).
- For system requirements, consult [`docs/requirements.md`](docs/requirements.md).
- For the current application architecture and folder responsibilities, consult [`docs/architecture.md`](docs/architecture.md).
- For I-STOCK Manager API endpoints, payloads, identifiers, authentication, and documented operations, consult [`docs/api/openapi.yaml`](docs/api/openapi.yaml). Follow the contract and do not invent API behavior. If a required operation is missing from the Swagger, identify the gap before implementing the integration.

## Current repository state

The repository contains an implemented login view and Cubit, a login repository connected to the I-STOCK API, optional biometric unlocking of a valid securely stored session, and automated Cubit, repository, and widget tests. After authentication, navigation still opens a placeholder Pastilles page; stock management and movement history have not been implemented. The product target is mobile; the existence of other Flutter platform folders does not add them to product scope.

`docs/requirements.md` and `docs/design_system.md` describe the intended product and UI behavior; they are not evidence that every specified feature already exists in code. `README.md` and `README.pt-BR.md` are project documentation. Keep them separate from the AI context documents unless the user explicitly requests README changes.

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

Use Flutter for the mobile client. Consult `docs/api/openapi.yaml` for API contracts. Confirm missing API behavior with the backend owner instead of guessing. Do not add map or location functionality. Add dependencies and architecture only as part of an explicitly requested implementation task.

## Testing

- Every new feature must include automated tests under Flutter's `test/` directory at the appropriate layer, such as Cubit, repository, or widget tests.
- When changing existing behavior or fixing a bug, add or update tests in `test/` that cover the changed behavior and relevant failure cases.
- Keep automated test code, fixtures, and test helpers inside `test/`. Prefer controlled or mocked dependencies; do not send real credentials or rely on a live API in routine tests.
- Run the relevant tests with `flutter test` and report any tests that could not be run.

## Change discipline

Before editing, inspect `git status` and the relevant files. Do not delete or overwrite existing user work. Keep changes scoped to the requested task, avoid commits unless explicitly requested, and verify documentation changes with a diff. Do not claim a feature is implemented merely because it is specified in the context documents.
