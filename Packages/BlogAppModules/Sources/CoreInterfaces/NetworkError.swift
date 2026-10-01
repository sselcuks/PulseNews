import Foundation

public enum NetworkError: Error, Sendable {
    case invalidURL
    case serverError
    case decodingError
}
