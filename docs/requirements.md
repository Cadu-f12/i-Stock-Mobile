# I-STOCK Mobile — Requirements v1

**Date:** 24/11/2026
**Version:** v1 — simplified mobile scope
**Status:** Product scope defined; API contract documented; platform and some integration details remain open.

## 1. Objective and scope

I-STOCK Mobile is a simplified mobile application for signing in, viewing pastilles and managing their stock, and searching stock movements. It includes optional native biometric authentication to unlock a still-valid signed-in session.

The application has three screens:

1. **Login** — sign in with email and password.
2. **Pastilles** — the main screen, listing all pastilles and providing stock actions for each one.
3. **Movement history** — view and search movements for all pastilles.

Biometric unlocking is part of the login/session flow and is not a separate screen or navigation destination.

Only these three product screens are in this scope. Offline-first operation, local notifications, and local item photography are not included. The client uses Flutter. API endpoints and payloads are defined by the [I-STOCK Manager API contract](api/openapi.yaml); this requirements document defines product behavior and scope.

## 2. Functional requirements

### RF-01 — Sign in

- The login screen must provide email and password fields and a sign-in action.
- The application must report missing or invalid credentials clearly and must not expose protected screens until sign-in succeeds.
- The authenticated area must provide a way to sign out.
- The API authenticates requests with bearer JWTs. Tokens expire after 15 minutes; the API does not issue refresh tokens. The client must follow the API response and must not invent endpoints or renewal behavior.
- The client must store a JWT only in platform-secure storage and must never store the user's email/password as a way to restore a session.
- The login endpoint and request/response schema must follow the [I-STOCK Manager API contract](api/openapi.yaml). Password recovery and account provisioning must follow the existing identity service; their behavior is not defined here.

### RF-02 — Navigate the three screens

- After successful email/password sign-in or successful biometric unlocking of a still-valid session, the Pastilles screen is the main screen.
- The signed-in user must be able to navigate to Pastilles and Movement history.
- Protected screens must require an authenticated session.

### RF-03 — View pastilles and stock

- The Pastilles screen must show all pastilles returned for the signed-in user's inventory, with each pastille's identity and current stock balance.
- The screen must provide a way to manage stock for an individual pastille.
- Pastille fields beyond identity and current stock must follow the data available from the system; this requirement does not authorize creating, editing, or deleting pastille records.

### RF-04 — Manage stock

- A user must be able to record a stock entry or withdrawal for a selected pastille.
- Each operation must have a positive quantity and be associated with the selected pastille and the signed-in user.
- A withdrawal must not exceed the available stock, subject to the validation rules of the system of record.
- A successful operation must update the displayed stock according to the system response and create a corresponding movement visible in Movement history.
- The operation model, including any reason or other required fields, must follow the existing backend contract. Do not invent unsupported operation types or API behavior.

### RF-05 — View and search movement history

- Movement history must show movements for all pastilles available to the signed-in user.
- The user must be able to search the displayed movements. Search must work across movement and pastille information available to the application; the exact searchable fields remain an open decision.
- Each movement must show enough information to identify its pastille, operation, quantity, and date/time, plus other information supplied by the system such as responsible user or reason.
- Movement history is read-only in this scope. Stock changes are made from the Pastilles screen and create movements; users cannot edit or remove recorded movements here.

### RF-06 — Unlock a session with biometrics

- After a successful email/password sign-in, the user may opt in to biometric unlocking when the device supports biometrics and has them configured.
- When the user chooses biometric unlocking, the app must use the operating system's native biometric prompt before restoring the securely stored JWT.
- A successful biometric prompt only unlocks the locally stored token. The app must still use that bearer token with the API; biometrics do not authenticate directly with the API or issue a JWT.
- The JWT remains usable only until its 15-minute expiration. If it has expired or the API rejects it as invalid, the app must require email and password again. It must not store or submit the password automatically, and it must not imply that biometrics renewed the session.
- If biometric hardware or enrollment is unavailable, the user has not opted in, or the prompt is cancelled or fails, email/password sign-in must remain available. Show a clear message when the saved session has expired.
- Signing out must remove the locally stored JWT and disable biometric unlocking for that signed-out session.

## 3. Product boundaries

- The Pastilles screen manages stock only. Pastille catalog maintenance is not part of this three-screen scope.
- Movement history is for viewing and searching; movement creation happens through stock actions.
- No offline stock operations, local database, photos, or notifications are required by this version.

## 4. Interface requirements

- The mobile interface must provide clear loading, content, empty, and error states for data-backed screens, plus clear states for biometric availability, cancellation, failure, and session expiration.
- Stock changes must show whether the operation succeeded or failed. The displayed balance must not imply success before the system confirms the operation.
- Search results and empty results must be distinguishable.
- Pastilles and Movement history must remain available from the signed-in application shell.
- Layouts and primary actions must be usable on supported mobile device sizes.

## 5. Data and integration

- Pastille identifiers, stock balances, movement records, and user identity must use the existing I-STOCK system/API contract.
- Stock changes must use operations accepted by the backend. The server response is authoritative for the confirmed balance and movement.
- Authentication uses bearer JWTs with a 15-minute lifetime and no refresh-token flow. The client must use the actual API contract in [I-STOCK Manager API](api/openapi.yaml). The Swagger documents login and pastille listing/detail operations; it currently does not document stock mutation or a dedicated movement-history/search operation. Confirm those contracts before implementing those integrations.
- Biometrics are a device-local gate for access to the stored JWT. Biometric data must not be sent to the I-STOCK API.

## 6. Technology and platform

- The product target is a Flutter mobile application.
- Android/iOS minimum versions, the biometric plugin, and secure-storage implementation must be confirmed during implementation planning.
- Requirements describe the intended product and do not imply that a feature is already implemented. Consult `AGENTS.md` for the current implementation snapshot.

## 7. Open decisions

Resolve these before implementation where they affect the design or integration:

1. What are the logout endpoint contract and password-recovery/account-provisioning rules? The documented login contract is in `docs/api/openapi.yaml`.
2. Does stock management mean only entries and withdrawals, or are stock corrections/absolute adjustments also required?
3. Which fields are searchable in movement history, and should search be immediate or submitted?
4. Which Android/iOS versions and biometric types must be supported?
5. Which API operations will support stock mutations and movement-history/search, and what are their request/response contracts? Pastille and movement schemas currently documented by the API are in `docs/api/openapi.yaml`.

## 8. Requirements governance

Validate implementation against this document. If the existing API or identity service differs from these requirements, document the gap and agree on the product or integration change before implementing unsupported behavior. Update this document when the user approves a scope change.
