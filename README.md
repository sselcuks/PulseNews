# DevTo Pulse: Modular Offline-First iOS Reader

[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://apple.com)
[![Architecture](https://img.shields.io/badge/Architecture-Modular--SPM-blue?style=for-the-badge)](ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**DevTo Pulse**, [Dev.to](https://dev.to) üzerindeki teknoloji ve yazılım makalelerini **Offline-First (Önce Çevrimdışı)** prensibiyle sunan, **Local Swift Package Manager (SPM)** üzerinde modüler olarak inşa edilmiş modern bir iOS uygulamasıdır.

---

## 🚀 Key Features

- 📱 **Offline-First Storage:** İnternet bağlantısı olmasa dahi daha önce yüklenen haberlerin anında görüntülenmesi (`SwiftData`).
- 🧩 **Modular Architecture:** Sıkı bağımlılıkları (tight coupling) engelleyen 5 bağımsız Swift paketi.
- 🔄 **Automatic Background Sync:** `URLSession` ve `async/await` kullanarak arka planda sessiz veri senkronizasyonu.
- 🎨 **Design System Module:** Reusable SwiftUI bileşenleri ve izolasyonlu UI temalama.
- 📑 **Bookmarks & Offline Reading:** Beğenilen makaleleri yerel veritabanına kaydetme.
- 🧪 **Testable Core:** Protocol-Driven tasarım sayesinde %100 mock'lanabilir Network ve Storage katmanları.

---

## 🏛️️ Architecture Overview

Uygulama, bağımlılıkların her zaman yukarıdan aşağıya (App → Features → Infrastructure) aktığı katmanlı bir mimariye sahiptir.

```
                  ┌─────────────────────────────────┐
                  │          DevToPulseApp          │
                  │     (App Root & DI Container)   │
                  └────────────────┬────────────────┘
                                   │
         ┌─────────────────────────┴─────────────────────────┐
         ▼                                                   ▼
┌──────────────────┐                               ┌──────────────────┐
│   FeatureFeed    │                               │ FeatureBookmarks │
└────────┬─────────┘                               └────────┬─────────┘
         │                                                  │
         └─────────────────────────┬────────────────────────┘
                                   │
         ┌─────────────────────────┼────────────────────────┐
         ▼                         ▼                        ▼
┌──────────────────┐      ┌──────────────────┐     ┌──────────────────┐
│  CoreInterfaces  │      │   DesignSystem   │     │   CoreStorage    │
└──────────────────┘      └──────────────────┘     └────────┬─────────┘
                                                            │
                                                            ▼
                                                   ┌──────────────────┐
                                                   │   CoreNetwork    │
                                                   └──────────────────┘
```

> Mimari tasarım prensipleri ve katman ayrıntıları için [ARCHITECTURE.md](ARCHITECTURE.md) dosyasını inceleyin.

---

## 🌐 Offline-First Data Flow

Arayüz katmanı (UI) **hiçbir zaman doğrudan API isteği atmaz**. Veri her zaman **Single Source of Truth** olan `SwiftData` üzerinden okunur:

```
[ SwiftUI View ] ◄── (@Query) ── [ SwiftData Local DB ]
                                           ▲
                                           │ (Upsert / Cache)
                                   [ ArticleRepository ]
                                           ▲
                                           │ (Fetch Async)
                                   [ Dev.to REST API ]
```

---

## 🛠️ Tech Stack & Requirements

- **Language:** Swift 5.9+
- **Minimum Target:** iOS 17.0+
- **UI Framework:** SwiftUI + `@Observable` macro
- **Persistence:** SwiftData
- **Networking:** Native `URLSession` + `async/await`
- **Modularization:** Local Swift Package Manager (SPM)
- **Architecture Pattern:** MVVM-C + Repository Pattern + Protocol-Oriented Programming

---

## 📦 Local Package Structure

```text
DevToPulse/
├── DevToPulse/               # Main App Target (DI & Navigation Root)
└── Packages/                 # Local Swift Packages
    ├── CoreInterfaces/       # Shared Protocols & Domain Entities
    ├── CoreNetwork/          # Dev.to REST API Service
    ├── CoreStorage/          # SwiftData Database & Repository Implementation
    ├── DesignSystem/         # UI Tokens, Card Views, Custom Modifiers
    └── FeatureFeed/          # Article List UI & ViewModels
```

---

## 🚀 Getting Started

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/username/DevToPulse.git
   ```
2. `DevToPulse.xcodeproj` dosyasını Xcode 15+ ile açın.
3. Bağımlılıkların (Local SPM) yüklenmesini bekleyin.
4. Hedef cihaz olarak **iOS 17 Simülatörünü** seçip `Cmd + R` ile çalıştırın.

---

## 📝 License

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.