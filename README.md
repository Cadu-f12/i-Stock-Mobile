# I-STOCK Mobile

> A Flutter mobile app for managing industrial cutting insert inventory at DDA Metalúrgica, Santa Catarina, Brazil.

**🇺🇸 English** | [🇧🇷 Português](README.pt-BR.md)

---

## 📌 About the Project

**I-STOCK Mobile** is the mobile companion to the I-Stock inventory management system. It is being developed with Flutter to give employees a convenient way to access inventory information and record stock activity from mobile devices.

The project supports the inventory workflow for industrial cutting inserts used in machining and manufacturing. Its goal is to make stock information and daily operations easier to access wherever the work takes place.

This application is being created as a separate mobile repository and is intended to work with the I-Stock system's backend API as that integration is defined.

---

## 🎯 Purpose

Accurate inventory information helps prevent material shortages and production interruptions. A mobile application can make it easier for authorized users to consult stock and record inventory activity without relying on a desktop workstation.

The app's scope and available features will evolve as the project requirements and API integration are established.

---

## 💡 Planned Capabilities

The mobile app is intended to support inventory tasks such as:

* Viewing cutting insert inventory and stock levels.
* Recording stock entries and withdrawals.
* Reviewing inventory movement history.
* Identifying items that may need replenishment.

These capabilities describe the project direction; availability depends on implementation and backend support.

---

## 🏗️ Architecture

The app is built with **Flutter** and **Dart**. It is designed to communicate with the I-Stock backend through its REST API.

```text
┌─────────────────────────────┐
│       Mobile App            │
│       Flutter + Dart        │
└──────────────┬──────────────┘
               │ HTTP / REST API
               ▼
┌─────────────────────────────┐
│       I-Stock Backend       │
│       Java + Spring Boot    │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          MySQL              │
└─────────────────────────────┘
```

---

## 🛠️ Technology

* **Flutter** — cross-platform mobile UI toolkit.
* **Dart** — application programming language.
* **REST API** — planned communication with the I-Stock backend.

---

## 🚀 Getting Started

### Prerequisites

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and a supported development environment for Android or iOS.

### Run the application

```bash
git clone https://github.com/Cadu-f12/i-Stock-Mobile.git
cd i-Stock-Mobile
flutter pub get
flutter run
```

Select a connected device or start an emulator before running the app. API connection settings and backend requirements will be documented as they are added to the project.

---

## 📂 Project Structure

```text
i-Stock-Mobile/
├── android/                 # Android host project
├── ios/                     # iOS host project
├── lib/                     # Dart application source
├── test/                    # Flutter tests
├── web/                     # Web host project
├── pubspec.yaml             # Package metadata and dependencies
└── README.md
```

The structure may grow as application features and integrations are implemented.

---

## 🎓 Project Context

I-STOCK Mobile is associated with the I-Stock inventory management project for **DDA Metalúrgica**, Santa Catarina, Brazil. The original system is an academic software development project at **SENAI/SC**.

---

## 🌐 Documentation

* 🇺🇸 **English** — `README.md`
* 🇧🇷 **Português** — [`README.pt-BR.md`](README.pt-BR.md)
