import CoreInterfaces
import Foundation

public final class DevToNetworkService: DevToNetworkServiceProtocol {
    public static let defaultPerPage = 20

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchArticles(page: Int) async throws -> [DevToArticleDTO] {
        let request = try Self.articlesRequest(page: page)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError
            }

            do {
                return try JSONDecoder().decode([DevToArticleDTO].self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.serverError
        }
    }

    private static func articlesRequest(page: Int) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dev.to"
        components.path = "/api/articles"
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(defaultPerPage))
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return URLRequest(
            url: url,
            cachePolicy: .reloadRevalidatingCacheData,
            timeoutInterval: 30
        )
    }
}
