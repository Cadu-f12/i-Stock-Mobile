# Agent Guide

## Project purpose

I-STOCK Mobile is a Flutter/Dart mobile companion for the I-STOCK inventory system at DDA Metalúrgica. Its intended scope is consultation of cutting-insert data and stock balances, plus stock entries and withdrawals. The mobile app is not the owner of cutting-insert master data.

## Source of truth

- For interface design standards, consult [`docs/design_system.md`](docs/design_system.md).
- For system requirements, consult [`docs/requirements.md`](docs/requirements.md).
- Follow the real web API contract for endpoints, payloads, identifiers, authentication, and accepted operations. Do not invent API behavior.

## Current repository state

This repository is currently a Flutter starter project. The platform host folders (`android/`, `ios/`, `linux/`, and `web/`) and the Dart/test folders exist, but the application feature architecture has not yet been implemented.

Current relevant files:

- `lib/main.dart` is still Flutter's initial counter example (`MyApp`, `MyHomePage`, and the increment button).
- `test/widget_test.dart` is still the initial counter widget test.
- `pubspec.yaml` contains Flutter, `cupertino_icons`, `flutter_test`, and `flutter_lints`; it does not currently include `flutter_bloc`, `http`, or an SQLite dependency.
- `docs/requirements.md` and `docs/design_system.md` describe the intended product and UI behavior; they are context documents, not evidence that those features already exist in code.
- `README.md` and `README.pt-BR.md` are project documentation. Keep them separate from the AI context documents unless the user explicitly requests README changes.

The repository may contain additional generated or platform-specific files. Inspect the actual tree and current Git state before making assumptions, and preserve unrelated user work.

## Product rules agents must preserve

- Master-data records are consultation-only on mobile: users must not create, edit, or remove cutting inserts, users, manufacturers, suppliers, reasons, or other auxiliary records.
- Stock entries and withdrawals are the operations that update inventory. Every recorded operation has a movement associated with the selected cutting insert.
- History is consultation-only. Recorded movements must not be edited or removed by the mobile app.
- Offline-first behavior prioritizes local data, distinguishes cached/projected/confirmed values, and reports when required data is unavailable offline.
- Pending movements must be preserved through failures and conflicts. Conflicts must be visible; local operations must not be silently overwritten.
- Photos are captured and stored locally on the device. Photo files and their paths must not be uploaded to the API or synchronized to other devices.
- A withdrawal must respect the locally available balance including pending movements, while the API remains responsible for server confirmation.
- Use the actual API contract for synchronization, including its endpoints, formats, authentication rules, and responses. Never infer or fabricate missing details.

## Implementation guidance

When implementation begins, keep UI state explicit for loading, content, empty, error, pending, failed, and conflict cases. Preserve synchronization metadata and historical relationships in local persistence. Consult `docs/requirements.md` before changing scope; if a requirement is missing or must change, explain the impact and request user approval before modifying the requirements document.

Do not treat the planned stack as already installed. The requirements anticipate BLoC via `flutter_bloc`, HTTP via `http`, and SQLite, but dependencies and architecture must be introduced only as part of an explicitly requested implementation task.

## Change discipline

Before editing, inspect `git status` and the relevant files. Do not delete or overwrite existing user work. Keep changes scoped to the requested task, avoid commits unless explicitly requested, and verify documentation changes with a diff. Do not claim a feature is implemented merely because it is specified in the context documents.
