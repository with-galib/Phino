# Phino
A cross-platform file sharing application built with Flutter, designed to enable seamless peer-to-peer file transfers between Android, iOS, macOS, and PC, without the need for an external server.

# 🐊 PHINO — File Sharing App

> **Share files instantly over WiFi. No internet needed. No cables. No limits.**

Built with Flutter by **Galib** — works seamlessly between Android devices.

---

## ✨ Features

- 📁 **Multiple file sharing** — select and send as many files as you want at once
- 📶 **WiFi local transfer** — fast file transfer over your local network, no internet required
- 📱 **Android to Android** — works between any two Android devices on the same WiFi
- 🔒 **No cloud, no servers** — your files never leave your local network
- 🎨 **Beautiful dark UI** — clean purple-themed dark mode interface
- 💫 **Splash screen animation** — smooth animated intro when the app opens
- 📋 **One-tap IP copy** — copy sender's IP with a single tap
- 📥 **Download All** — receive all shared files at once
- 🔍 **Device model display** — shows your device name in the app bar

---

## 🚀 How It Works

### Sending Files
1. Open PHINO and go to the **Send** tab
2. Tap **Browse Files** and select one or multiple files
3. Tap **Start Sharing** — your IP address will appear
4. Share the IP with the receiver

### Receiving Files
1. Open PHINO and go to the **Receive** tab
2. Enter the sender's IP address
3. Tap **Connect** — all shared files will appear
4. Tap the download icon on each file or tap **Download All**

> ⚠️ Both devices must be connected to the **same WiFi network**

---

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `flutter` | Cross-platform UI framework |
| `file_picker` | Browse and select files |
| `shelf` + `shelf_router` | Local HTTP server on sender side |
| `dio` | HTTP client for file download |
| `network_info_plus` | Get device WiFi IP address |
| `path_provider` | Get storage directory for saving files |
| `permission_handler` | Handle storage & network permissions |
| `open_filex` | Open downloaded files |
| `device_info_plus` | Get device model name |

---

## 📦 Installation

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio or VS Code
- Android device or emulator

### Steps

```bash
# Clone the repository
git clone https://github.com/with-galib/Phino.git

# Navigate into the project
cd phino

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build APK
```bash
flutter build apk --release
```
APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Permissions Required

| Permission | Reason |
|---|---|
| `INTERNET` | Local network communication |
| `ACCESS_WIFI_STATE` | Read WiFi network info |
| `READ_EXTERNAL_STORAGE` | Browse and read files |
| `WRITE_EXTERNAL_STORAGE` | Save received files |
| `READ_MEDIA_*` | Access media files on Android 13+ |

---

## 📁 Project Structure

```
phino/
├── lib/
│   └── main.dart         # All app logic and UI
├── assets/
│   └── logo.png          # App logo (crocodile)
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml
└── pubspec.yaml
```

---

## 🗺️ Roadmap

- [ ] iOS support
- [ ] Web upload page (share from browser)
- [ ] Transfer speed indicator
- [ ] File preview before download
- [ ] Dark/light theme toggle
- [ ] Transfer history

---

## 👨‍💻 Developer

**Galib** — designed and built PHINO from scratch.

> *"No AirDrop? No problem. PHINO does it better."*

---

## 📄 License

This project is open source and available under the [GNU v3.0](LICENSE).

---

<p align="center">Made with 🐊 and Flutter by Galib</p>

//commit
