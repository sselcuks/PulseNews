import CoreInterfaces
import Foundation
import SwiftData

@Model
public final class SDArticle {
    @Attribute(.unique) public var id: Int
    public var title: String
    public var articleDescription: String
    public var articleURL: URL
    public var coverImageURL: URL?
    public var publishedAt: Date
    public var readingTimeMinutes: Int
    public var authorName: String

    public init(entity: ArticleEntity) {
        id = entity.id
        title = entity.title
        articleDescription = entity.description
        articleURL = entity.articleURL
        coverImageURL = entity.coverImageURL
        publishedAt = entity.publishedAt
        readingTimeMinutes = entity.readingTimeMinutes
        authorName = entity.authorName
    }

    public func update(with entity: ArticleEntity) {
        title = entity.title
        articleDescription = entity.description
        articleURL = entity.articleURL
        coverImageURL = entity.coverImageURL
        publishedAt = entity.publishedAt
        readingTimeMinutes = entity.readingTimeMinutes
        authorName = entity.authorName
    }

    public var entity: ArticleEntity {
        ArticleEntity(
            id: id,
            title: title,
            description: articleDescription,
            articleURL: articleURL,
            coverImageURL: coverImageURL,
            publishedAt: publishedAt,
            readingTimeMinutes: readingTimeMinutes,
            authorName: authorName
        )
    }
}
