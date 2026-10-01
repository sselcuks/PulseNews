import CoreInterfaces
import Foundation

public struct DevToUserDTO: Decodable, Sendable {
    public let name: String?
}

public struct DevToArticleDTO: Decodable, Sendable {
    public let id: Int
    public let title: String
    public let description: String
    public let articleURL: URL
    public let coverImageURL: URL?
    public let publishedAt: Date
    public let readingTimeMinutes: Int
    public let user: DevToUserDTO?

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case articleURL = "url"
        case coverImageURL = "cover_image"
        case socialImageURL = "social_image"
        case readablePublishedAt = "readable_published_at"
        case publishedTimestamp = "published_timestamp"
        case readingTimeMinutes = "reading_time_minutes"
        case user
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        articleURL = try container.decode(URL.self, forKey: .articleURL)
        readingTimeMinutes = try container.decode(Int.self, forKey: .readingTimeMinutes)
        user = try container.decodeIfPresent(DevToUserDTO.self, forKey: .user)

        let rawCoverImage = try container.decodeIfPresent(String.self, forKey: .coverImageURL)
        let rawSocialImage = try container.decodeIfPresent(String.self, forKey: .socialImageURL)
        coverImageURL = Self.imageURL(from: rawCoverImage) ?? Self.imageURL(from: rawSocialImage)

        let readablePublishedAt = try container.decodeIfPresent(String.self, forKey: .readablePublishedAt)
        let publishedTimestamp = try container.decodeIfPresent(String.self, forKey: .publishedTimestamp)

        let resolvedDate = readablePublishedAt.flatMap(Self.readableDateFormatter.date(from:))
            ?? publishedTimestamp.flatMap(Self.timestampDateFormatter.date(from:))

        guard let publishedAt = resolvedDate else {
            throw DecodingError.dataCorruptedError(
                forKey: .readablePublishedAt,
                in: container,
                debugDescription: "Missing or unsupported publication date. readable_published_at: \(readablePublishedAt ?? "nil"), published_timestamp: \(publishedTimestamp ?? "nil")"
            )
        }
        self.publishedAt = publishedAt
    }

    private static let readableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        return formatter
    }()

    private static let timestampDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func imageURL(from rawValue: String?) -> URL? {
        guard let rawValue, !rawValue.isEmpty else { return nil }
        return URL(string: rawValue)
    }
}

extension DevToArticleDTO {
    public func toEntity() -> ArticleEntity {
        ArticleEntity(
            id: id,
            title: title,
            description: description,
            articleURL: articleURL,
            coverImageURL: coverImageURL,
            publishedAt: publishedAt,
            readingTimeMinutes: readingTimeMinutes,
            authorName: user?.name ?? ""
        )
    }
}
