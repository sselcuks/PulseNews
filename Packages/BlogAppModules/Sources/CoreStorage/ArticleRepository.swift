import CoreInterfaces
import CoreNetwork
import Foundation
import SwiftData

public final class ArticleRepository: ArticleRepositoryProtocol {
    private let networkService: DevToNetworkServiceProtocol
    private let modelContainer: ModelContainer

    public init(networkService: DevToNetworkServiceProtocol, modelContainer: ModelContainer) {
        self.networkService = networkService
        self.modelContainer = modelContainer
    }

    public func fetchArticles(page: Int) async throws -> [ArticleEntity] {
        let remoteArticles: [ArticleEntity]

        do {
            remoteArticles = try await networkService.fetchArticles(page: page).map { $0.toEntity() }
        } catch {
            return try await getCachedArticles()
        }

        let context = ModelContext(modelContainer)
        try upsert(remoteArticles, in: context)
        try context.save()

        return try await getCachedArticles()
    }

    public func getCachedArticles() async throws -> [ArticleEntity] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<SDArticle>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(\.entity)
    }

    private func upsert(_ articles: [ArticleEntity], in context: ModelContext) throws {
        guard !articles.isEmpty else { return }

        let incomingIDs = articles.map(\.id)
        let descriptor = FetchDescriptor<SDArticle>(
            predicate: #Predicate { incomingIDs.contains($0.id) }
        )
        let storedArticles = try context.fetch(descriptor)
        let articlesByID = Dictionary(uniqueKeysWithValues: storedArticles.map { ($0.id, $0) })

        for article in articles {
            if let storedArticle = articlesByID[article.id] {
                storedArticle.update(with: article)
            } else {
                context.insert(SDArticle(entity: article))
            }
        }
    }
}
