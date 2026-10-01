import Foundation

public protocol ArticleRepositoryProtocol: Sendable {
    func fetchArticles(page: Int) async throws -> [ArticleEntity]
    func getCachedArticles() async throws -> [ArticleEntity]
}
