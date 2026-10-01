# DevTo Pulse - Architecture Specifications

Bu doküman, **DevTo Pulse** projesinde uygulanan mimari prensipleri, modüller arası bağımlılık kurallarını, SOLID entegrasyonunu ve Offline-First veri stratejisini detaylandırır.

---

## 1. Core Architectural Principles

### 1.1 Loose Coupling & High Cohesion
Her modül tek bir sorumluluğa sahiptir ve diğer modüllerin somut (concrete) sınıflarından habersizdir. Modüller arası iletişim **`CoreInterfaces`** modülünde tanımlanan protokoller üzerinden gerçekleşir.

### 1.2 Single Source of Truth (SSOT)
Arayüz bileşenleri verinin kaynağını (API mi yoksa DB mi) sorgulamaz. `SwiftData` veritabanı uygulamanın tek doğruluk kaynağıdır. Ağ katmanı veriyi çeker, veritabanına yazar; arayüz ise veritabanındaki değişimleri reaktif olarak dinler.

### 1.3 Dependency Inversion Principle (DIP)
Aksine bağımlılık ilkesi gereği:
- **Yüksek seviyeli modüller (Feature UI)**, düşük seviyeli modüllere (Core Network/Storage) doğrudan bağımlı olamaz.
- Her iki taraf da **`CoreInterfaces`** içindeki soyutlamalara (protokollere) bağımlıdır.

---

## 2. Module Specifications & Responsibilities

| Module | Type | Responsibilities | Dependencies |
| :--- | :--- | :--- | :--- |
| **`CoreInterfaces`** | Contract | Modüllerin ortak kullandığı Protocol'ler, DTO'lar, Domain Entity'ler ve Hata Enum'ları. | *None* |
| **`CoreNetwork`** | Infrastructure | Dev.to REST API endpoint yönetimi, JSON parsing ve HTTP hataları. | `CoreInterfaces` |
| **`CoreStorage`** | Infrastructure | `SwiftData` container yönetimi, `SDArticle` persistence modelleri ve `ArticleRepository` somutlaştırması. | `CoreInterfaces`, `CoreNetwork` |
| **`DesignSystem`** | UI Core | Renk paletleri, tipografi, Shimmer (skeleton) yükleme animasyonları, Reusable Card View'lar. | *None* |
| **`FeatureFeed`** | Feature | Akış ekranı, arama barı, kategori filtreleme SwiftUI View ve `@Observable` ViewModel yapıları. | `CoreInterfaces`, `DesignSystem` |
| **`DevToPulseApp`** | Main Target | App Launch, Dependency Injection Container kaydı, Root Navigation Coordinator. | *All Packages* |

---

## 3. Data Flow Strategy & Persistence

### 3.1 Fetch and Upsert Sequence
1. **User Opens App:** `FeatureFeed` ViewModel'i `repository.fetchArticles()` metodunu çağırır.
2. **Local First Return:** Repository, SwiftData içerisindeki mevcut verileri anında döner.
3. **Background Network Task:** `CoreNetwork` üzerinden `GET https://dev.to/api/articles` çağrısı tetiklenir.
4. **Upsert Operation:** API yanıtı başarılı olursa, benzersiz `id` değerine göre SwiftData kayıtları güncellenir (`Upsert`).
5. **UI Reaction:** SwiftData veritabanı güncellendiğinde UI otomatik olarak kendisini yeniler.
6. **Error Handling (Offline State):** İnternet yoksa network hatası yakalanır (catch), kullanıcıya bildirim gösterilir ve önbellekteki veriler ekranda kalmaya devam eder.

---

## 4. SOLID Implementation Examples in Project

- **Single Responsibility (SRP):** `DevToNetworkService` sadece HTTP isteklerinden, `SDArticle` sadece yerel veri modellerinden sorumludur.
- **Open/Closed (OCP):** Yeni bir API sağlayıcısı eklemek gerektiğinde `ArticleRepositoryProtocol` türetilerek yeni bir sınıf yazılır; var olan ViewModel koduna dokunulmaz.
- **Liskov Substitution (LSP):** `MockArticleRepository` ile `ArticleRepository` birbirlerinin yerine eksiksiz olarak geçebilir (Unit testlerde).
- **Interface Segregation (ISP):** Tek bir devasa protokol yerine `ArticleReaderProtocol` ve `ArticleWriterProtocol` şeklinde ayrıştırılmış yapılar.
- **Dependency Inversion (DIP):** `FeedViewModel`, somut `ArticleRepository` sınıfına değil `ArticleRepositoryProtocol` arayüzüne bağımlıdır.

---

## 5. Dependency Injection (DI) Strategy

Projede basit ve performanslı olan **Initializer (Constructor) Injection** yöntemi benimsenmiştir.

```swift
// Main App Target / Composition Root
@main
struct DevToPulseApp: App {
    let container: ModelContainer
    let repository: ArticleRepositoryProtocol
    
    init() {
        do {
            container = try ModelContainer(for: SDArticle.self)
            let network = DevToNetworkService()
            repository = ArticleRepository(networkService: network, modelContainer: container)
        } catch {
            fatalError("Failed to initialize SwiftData container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: FeedViewModel(repository: repository))
        }
        .modelContainer(container)
    }
}
```