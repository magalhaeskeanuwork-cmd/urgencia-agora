# 🏥 Urgência Agora

> Real-time SNS Portugal emergency room wait time tracker — built with SwiftUI, Claude AI, and Groq.

![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat&logo=swift)
![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue?style=flat&logo=apple)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

---

## 📱 About

**Urgência Agora** is a native iOS app that shows real-time emergency room wait times across SNS (Serviço Nacional de Saúde) hospitals in Portugal. Built for anyone who needs to quickly find the nearest hospital with the shortest queue — especially useful in stressful moments when every minute counts.

The app pulls live data from the official SNS API (`tempos.min-saude.pt`), refreshes every 10 minutes, and uses AI to help users make smarter decisions about where to go.

---

## ✨ Features

- 🕐 **Real-time wait times** — Live data from the official SNS portal, updated every 10 minutes
- 🗺️ **Directions** — One tap to open Apple Maps with driving directions to any hospital
- 🎨 **Manchester triage breakdown** — Wait times per triage colour (Immediate → Non-urgent)
- ⚠️ **Trust signal** — AI-powered flag that detects suspiciously low wait times vs historical averages
- 🤖 **Lusia — AI assistant** — Chat with an AI health assistant powered by Groq (LLaMA 3.3) that recommends the best hospital based on live data
- ❤️ **Favourites & history** — Save favourite hospitals and track past visits
- 🌍 **Bilingual** — Full Portuguese and English support
- ♿ **Accessibility** — Text size, bold text, high contrast, reduce motion, colour blind mode, haptic feedback
- 📋 **Disclaimer** — Transparent data sourcing with SNS attribution

---

## 🛠️ Built With

### Design
- **Figma** — UI/UX design, wireframes, and component design
- **Claude (Anthropic)** — UI design assistance, layout decisions, and design system guidance
- SNS24 green colour palette (`#007840`) to match the official NHS Portugal brand

### Development
- **SwiftUI** — Native iOS UI framework
- **Claude (Anthropic)** — All code was written with Claude as an AI pair programmer, from architecture decisions to debugging
- **Xcode 16** — IDE
- **MapKit** — Apple Maps integration for directions
- **Groq API** — Powers the Lusia AI assistant (LLaMA 3.3 70B model)
- **UserDefaults** — Local persistence for favourites and visit history

### Data
- **SNS API** — `https://servicos.min-saude.pt/pds/api/tems/standbyTime/{institutionId}`
- Data refreshes every 10 minutes automatically
- Fallback to mock data if the API is unavailable

---

## 🏗️ Architecture
```
Urgência Agora/
├── Models/
│   └── Hospital.swift          — Data models (Hospital, TriageLevel, HospitalType)
├── Services/
│   └── SNSService.swift        — SNS API integration + mock fallback
├── ViewModels/
│   └── HospitalViewModel.swift — State management, filtering, sorting
├── Views/
│   ├── ContentView.swift       — Main screen with burger menu
│   ├── HospitalCardView.swift  — Expandable hospital card
│   ├── ChatView.swift          — Lusia AI assistant chat
│   ├── FavoritesView.swift     — Favourites & visit history
│   └── SettingsView.swift      — Accessibility & app settings
└── Managers/
    └── FavoritesManager.swift  — Favourites & history persistence
```

---

## 🚀 Getting Started

### Requirements
- macOS 14+
- Xcode 16+
- iOS 17+ device or simulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/magalhaeskeanuwork-cmd/urgencia-agora.git
```

2. Open the project in Xcode:
```bash
cd urgencia-agora
open "Urgência Agora.xcodeproj"
```

3. Add your Groq API key in `ChatView.swift`:
```swift
private let apiKey = "your_groq_api_key_here"
```

4. Select a simulator or device and press **⌘R** to run.

---

## 🔑 API Keys

This app uses the **Groq API** for the Lusia AI assistant. To get a free API key:

1. Go to [console.groq.com](https://console.groq.com)
2. Sign up for a free account
3. Create an API key
4. Replace the key in `ChatView.swift`

The SNS data API is public and requires no authentication.

---

## 📊 Data Sources

| Source | URL | Update frequency |
|--------|-----|-----------------|
| SNS Wait Times | tempos.min-saude.pt | Every 10 minutes |
| Hospital details | Built-in (mock) | Static |

> ⚠️ **Disclaimer:** This app is independent and not affiliated with SNS or the Portuguese Ministry of Health. Wait times are indicative only. In an emergency always call **112**.

---

## 🤖 About Lusia

Lusia is the app's AI health assistant, named as a nod to Portugal's history. She is powered by **LLaMA 3.3 70B** via the Groq API and has real-time context of all hospital wait times. She can:

- Recommend the best hospital for your situation
- Explain the Manchester triage system
- Answer questions about SNS urgências
- Always remind you to call 112 in emergencies

---

## 🗺️ Roadmap

- [ ] Push notifications when wait times drop at favourite hospitals
- [ ] Home screen widget with live wait times
- [ ] Real GPS location for accurate distance calculation
- [ ] Coverage across all SNS hospitals in Portugal
- [ ] Apple Watch companion app

---

## 👨‍💻 Author

**Keanu Magalhães**
- GitHub: [@magalhaeskeanuwork-cmd](https://github.com/magalhaeskeanuwork-cmd)

---

## 📄 License

This project is licensed under the MIT License.

---

*Built in Portugal 🇵🇹 — with Claude, for the people who need it most.*
