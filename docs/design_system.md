# I-STOCK Mobile — Design System v1

**Coverage:** Simplified I-STOCK mobile application
**Functional basis:** [mobile requirements v1](requirements.md)
**Date:** November 24, 2026

This guide defines visual and interaction patterns for Login, Pastilles, and Movement history, including the native biometric-unlock flow. Product behavior comes from the [requirements document](requirements.md). API endpoints and payloads are defined separately in the [I-STOCK Manager API contract](api/openapi.yaml); this guide does not define API behavior or select specific Flutter packages.

## 1. Product structure

After login, use a shared mobile application shell with clear navigation to:

1. **Pastilles** — main screen for stock overview and stock actions.
2. **Movement history** — searchable, read-only list of stock movements.

Biometric unlocking is part of the Login/session flow, not a separate screen or navigation destination. Show the signed-in user's account context and a sign-out action in the shell. Login is shown outside the authenticated shell.

## 2. Brand and visual foundations

Keep the DDA brand's royal blue and white, with cool neutrals inspired by steel and graphite. State colors are semantic and do not replace the brand identity.

| Token | Value | Usage |
|---|---|---|
| DDA Blue | #34458F | Identity, active navigation, and primary actions |
| DDA Blue Deep | #25336F | Pressed states and text on light backgrounds |
| DDA Blue Soft | #E9EDFA | Selection and soft highlights |
| DDA Blue Mid | #5368B5 | Supporting elements and focus outline |
| White | #FFFFFF | Surfaces and text on blue |
| Steel 50 | #F5F6F8 | General background |
| Steel 100 | #ECEEF2 | Supporting surfaces |
| Steel 200 | #D8DCE4 | Borders and dividers |
| Steel 500 | #727B8B | Metadata and secondary icons |
| Graphite | #252B35 | Primary text |
| Success | #237A51 | Confirmed stock operation |
| Warning | #A8660A | Attention or low-stock state when supported by data |
| Danger | #B43B42 | Error, rejected operation, or blocked action |

### Typography, spacing, and shape

- Use Inter, with Segoe UI, Roboto, or sans-serif fallbacks.
- Page titles: 26–30 px, weight 700; section titles: 17–19 px; body: 14–16 px; metadata: at least 12 px.
- Quantities use tabular figures for easy comparison.
- Use a 4 px spacing scale: 4, 8, 12, 16, 24, 32, and 40 px.
- Use an 8 px radius for controls and a 12 px radius for cards and panels.
- Keep contrast strong and hierarchy clear in industrial work environments.

## 3. Screen patterns

### Login

- Keep the screen focused on email, password, and the primary sign-in action.
- Label fields persistently; do not rely on placeholder text as the only label.
- Show validation and authentication errors beside the relevant field or form, with a next step supported by the authentication service.
- Keep a clearly labeled biometric-unlock action visible alongside email/password sign-in. If there is no opted-in, valid saved session, explain that the user must sign in with email and password to enable it.
- Explain that biometric unlocking only restores the saved session; if its 15-minute JWT has expired, ask for email and password again.
- Handle biometric unavailable, not enrolled, cancelled, and failed states without hiding or blocking email/password sign-in.
- Never imply that biometric verification renews a JWT or sends biometric data to the API.
- Do not expose the authenticated navigation until email/password authentication succeeds or biometrics unlock a still-valid session.

### Pastilles — main screen

- Make the stock list the primary content; do not replace it with a metrics dashboard.
- Show every pastille returned by the inventory source in a readable mobile list.
- Keep the pastille identity and current balance visible together.
- Provide distinct, labeled actions for stock entry and withdrawal on each pastille.
- The stock action flow identifies the selected pastille, accepts a quantity, and clearly labels the operation type before confirmation.
- Show inline quantity validation and the available balance when a withdrawal is invalid.
- Show a success or failure message after submission. Update the confirmed balance only from the system result.
- Do not show catalog create, edit, or delete controls in this scope.

### Movement history

- Provide a prominent search field and a clear way to reset the search.
- Use readable cards or stacked rows showing pastille, operation, quantity, and date/time. Include reason and responsible user when supplied by the system.
- Make entry and withdrawal distinguishable by text and icon as well as color.
- Keep the history read-only. Search results, no matches, loading, and errors each need a clear state.

## 4. Interaction and status patterns

- Use visible focus and pressed states for interactive elements.
- Disable or clearly mark a submission while it is in progress to prevent accidental duplicate stock actions.
- Preserve form input when an operation fails so the user can correct or retry it.
- Pair status colors with words or icons; never rely on color alone.
- Use concise messages that state what happened and the next step.
- Provide loading, content, empty, and error states for data-backed screens. For biometric access, distinguish unavailable/not enrolled, cancelled, failed, and expired-session states; always offer password sign-in.
- Provide a lock action that returns to Login while preserving a still-valid, opted-in session. On sign-out, remove the stored JWT and return to Login.

## 5. Responsive behavior and accessibility

- Keep Pastilles and Movement history reachable through mobile navigation.
- Use touch-friendly controls and readable mobile layouts.
- Support accessible focus, logical heading order, and labels announced with form controls.
- Associate validation errors with their fields and announce operation results to assistive technology.
- Target WCAG AA contrast. Avoid hover-only actions and respect reduced-motion preferences.
- Keep primary controls comfortably clickable on touch screens.
