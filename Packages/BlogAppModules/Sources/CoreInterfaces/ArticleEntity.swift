import Foundation

public struct ArticleEntity: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let description: String
    public let articleURL: URL
    public let coverImageURL: URL?
    public let publishedAt: Date
    public let readingTimeMinutes: Int
    public let authorName: String

    public init(
        id: Int,
        title: String,
        description: String,
        articleURL: URL,
        coverImageURL: URL?,
        publishedAt: Date,
        readingTimeMinutes: Int,
        authorName: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.articleURL = articleURL
        self.coverImageURL = coverImageURL
        self.publishedAt = publishedAt
        self.readingTimeMinutes = readingTimeMinutes
        self.authorName = authorName
    }
}
