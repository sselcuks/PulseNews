import Foundation

public protocol DevToNetworkServiceProtocol: Sendable {
    func fetchArticles(page: Int) async throws -> [DevToArticleDTO]
}
