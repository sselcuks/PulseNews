# Open-Code Incremental Development Prompts

Bu doküman, **Open-Code / Claude Code / Cursor** gibi AI kodlama araçlarını kullanarak projeyi adım adım ve hata yapmadan inşa etmenizi sağlayacak sıralı istemleri (prompt) içerir.

Komutları belirtilen sırayla AI asistanına yapıştırarak modülleri oluşturun.

---

## 📍 Phase 1: Local SPM Package Setup

```text
PROMPT 1:
Lütfen iOS 17+ uyumlu, Swift 5.9 destekleyen bir SPM paketi yapısı kurgula. 
"Packages/BlogAppModules" altında şu modülleri ve bağımlılıklarını Package.swift dosyası olarak oluştur:
1. CoreInterfaces (Bağımsız)
2. CoreNetwork (CoreInterfaces'e bağımlı)
3. CoreStorage (CoreInterfaces ve CoreNetwork'e bağımlı)
4. DesignSystem (Bağımsız UI paketi)
5. FeatureFeed (CoreInterfaces ve DesignSystem'e bağımlı)

Lütfen Package.swift dosyasının kodunu tam ve eksiksiz olarak üret.
```

---

## 📍 Phase 2: CoreInterfaces Module

```text
PROMPT 2:
CoreInterfaces modülü için aşağıdaki Swift dosyalarını oluştur:
1. `ArticleEntity.swift`: Identifiable ve Sendable protokolerini destekleyen, id, title, description, articleURL, coverImageURL, publishedAt, readingTimeMinutes ve authorName alanlarına sahip bir struct.
2. `ArticleRepositoryProtocol.swift`: `fetchArticles(page: Int) async throws -> [ArticleEntity]` ve `getCachedArticles() async throws -> [ArticleEntity]` fonksiyonlarını tanımlayan Sendable protokol.
3. `NetworkError.swift`: invalidURL, serverError, decodingError durumlarını barındıran Custom Error enum yapısı.
```

---

## 📍 Phase 3: CoreNetwork Module

```text
PROMPT 3:
CoreNetwork modülü içinde Dev.to API entegrasyonu için:
1. Dev.to API'sinin JSON yanıtını parse edecek `DevToArticleDTO.swift` (Decodable, Sendable) modelini yaz. Field'lar: id, title, description, url, cover_image, readable_published_at, reading_time_minutes, user (name).
2. `DevToNetworkServiceProtocol` ve bunu uygulayan `DevToNetworkService` sınıfını URLSession ve async/await kullanarak geliştir. Endpoint: `https://dev.to/api/articles?page=\(page)&per_page=20`. Hata durumlarını NetworkError enum'ı ile yönet.
```

---

## 📍 Phase 4: CoreStorage Module & Repository Pattern

```text
PROMPT 4:
CoreStorage modülünde SwiftData tabanlı Offline-First mimari kur:
1. `SDArticle.swift`: SwiftData `@Model` sınıfı oluştur. `id` alanı @Attribute(.unique) olsun.
2. `ArticleRepository.swift`: CoreInterfaces modülündeki `ArticleRepositoryProtocol` protokolünü uygulayan sınıfı yaz.
   - Initializer'da `DevToNetworkServiceProtocol` ve `ModelContainer` almalı.
   - `fetchArticles(page:)` metodu: Önce ağdan çekip SwiftData'ya upsert etmeli, ardından veritabanındaki güncel verileri `ArticleEntity` dizisine dönüştürüp döndürmeli.
   - İnternet yoksa catch bloğunda yerel veritabanındaki verileri döndürerek kesintisiz çalışma (Offline-First) sağlamalı.
```

---

## 📍 Phase 5: DesignSystem Module

```text
PROMPT 5:
DesignSystem modülü içinde SwiftUI bileşenleri oluştur:
1. `ArticleCardViewView.swift`: Kapak resmi, başlık, yazar adı, yayınlanma zamanı ve okuma süresi badge'i barındıran modern bir kart görünümü.
2. `ShimmerLoadingView.swift`: Veriler yüklenirken gösterilecek skeleton/shimmer animasyonu bileşeni.
```

---

## 📍 Phase 6: FeatureFeed Module & MVVM Setup

```text
PROMPT 6:
FeatureFeed modülü için:
1. iOS 17 `@Observable` makrosunu kullanan `FeedViewModel.swift` yaz. `ArticleRepositoryProtocol` bağımlılığını almalı. `loadArticles()` metodu ile verileri çekmeli.
2. `FeedView.swift` SwiftUI görünümünü oluştur. 
   - `DesignSystem` modülünden `ArticleCardView` bileşenini kullansın.
   - `AsyncImage` ile kapak resimlerini yüklesin.
   - Pull-to-refresh (`.refreshable`) ve arama çubuğu (`.searchable`) desteği bulunsun.
```

---

## 📍 Phase 7: App Target Integration & Composition Root

```text
PROMPT 7:
Ana iOS uygulama hedefinde (App Target) Dependency Injection kaydını yap:
- `@main` struct dosyasında `ModelContainer` oluştur.
- `DevToNetworkService` ve `ArticleRepository` nesnelerini bağla.
- `FeedView` ekranına oluşturulan repository'yi enjekte ederek uygulamayı başlatacak ana giriş kodunu yaz.
```