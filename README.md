# Pipo Controller

*A Flutter app to control LG WebOS TVs via WebSocket (SSAP protocol).*

This app was created because my physical LG TV remote was constantly annoying me —
malfunctioning, delayed responses, and sometimes not working at all.

The apps I found on the Play Store worked, but they were filled with ads.
Almost impossible to use.

So I decided to build my own — and use it as an opportunity to learn Flutter
(I'm a native Android developer).

---

## ✨ Features

- Volume control
- Mute toggle
- Home button
- Recent apps
- Pointer support
- Direct WebSocket communication with LG WebOS TVs

---

## 🛠 Tech Stack

- Flutter
- Dart
- WebSocket
- LG SSAP API

---

## 📺 Requirements

- LG TV with WebOS
- TV and phone/computer connected to the same Wi-Fi network
- Developer mode enabled on the TV (only for advanced usage)

---

## 🚀 Installation

🚀 Option 1 — Run from Source (Developer)

- Clone the repository: 
  - git clone https://github.com/YOUR_USERNAME/pipo-controller.git
  - cd pipo-controller

- Install dependencies:
  - flutter pub get

- Run on a device:
  - flutter run
---
🚀 Option 2 — Build APK
- Generate a release APK:
    - flutter build apk --release
    - The APK will be located at:
      - build/app/outputs/flutter-apk/app-release.apk

- Install it on your Android device.

## 🔐 First Connection 
- Go to your TV network settings and get the IP address;
- Click in connected button (top-right). Type the IP in text field.
- The TV will display a pairing request. It must be accepted in the TV;
- Accept it using your physical remote.

- *The app will store the client key for future automatic connections.*

## 📌 Roadmap
- Premium dark UI
- Smooth splash animation
- Direct auto-connect
- TV auto-discovery in local network
- Play Store release (NO ADS)

📄 License

This project is for educational and personal use.