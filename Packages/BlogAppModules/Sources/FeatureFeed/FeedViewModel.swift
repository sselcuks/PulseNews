import CoreInterfaces
import Foundation
import Observation

@MainActor
@Observable
public final class FeedViewModel {
    public private(set) var articles: [ArticleEntity] = []
    public private(set) var isLoading = false
    public private(set) var isRefreshing = false
    public private(set) var errorMessage: String?
    public var searchText = ""

    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public var filteredArticles: [ArticleEntity] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return articles }

        return articles.filter { article in
            article.title.localizedCaseInsensitiveContains(query)
                || article.description.localizedCaseInsensitiveContains(query)
                || article.authorName.localizedCaseInsensitiveContains(query)
        }
    }

    public func loadArticles() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if articles.isEmpty {
            await loadCachedArticles()
        }

        await fetchFromNetwork()
    }

    public func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        await fetchFromNetwork()
    }

    public func dismissError() {
        errorMessage = nil
    }

    private func loadCachedArticles() async {
        do {
            articles = try await repository.getCachedArticles()
        } catch {
            errorMessage = Self.missingDataMessage
        }
    }

    private func fetchFromNetwork() async {
        do {
            articles = try await repository.fetchArticles(page: 1)
            errorMessage = nil
        } catch {
            errorMessage = articles.isEmpty ? Self.missingDataMessage : Self.offlineMessage
        }
    }

    private static let missingDataMessage = "Couldn't load articles. Check your connection and try again."
    private static let offlineMessage = "Couldn't refresh. Showing saved articles."
}
