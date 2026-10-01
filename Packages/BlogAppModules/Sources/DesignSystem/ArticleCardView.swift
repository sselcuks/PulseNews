import SwiftUI

public struct ArticleCardView: View {
    public static let cornerRadius: CGFloat = 18
    public static let coverAspectRatio: CGFloat = 16.0 / 9.0

    private let coverImageURL: URL?
    private let title: String
    private let authorName: String
    private let publishedAt: Date
    private let readingTimeMinutes: Int
    private let onTap: (() -> Void)?

    public init(
        coverImageURL: URL?,
        title: String,
        authorName: String,
        publishedAt: Date,
        readingTimeMinutes: Int,
        onTap: (() -> Void)? = nil
    ) {
        self.coverImageURL = coverImageURL
        self.title = title
        self.authorName = authorName
        self.publishedAt = publishedAt
        self.readingTimeMinutes = readingTimeMinutes
        self.onTap = onTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coverImage
            details
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PulseColor.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .stroke(PulseColor.cardBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap ?? {})
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var coverImage: some View {
        GeometryReader { proxy in
            coverContent
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .aspectRatio(Self.coverAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(PulseColor.shimmerBase)
    }

    @ViewBuilder
    private var coverContent: some View {
        if let coverImageURL {
            AsyncImage(url: coverImageURL, transaction: Transaction(animation: .easeInOut(duration: 0.25))) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    coverPlaceholder(isShimmering: false)
                case .empty:
                    coverPlaceholder(isShimmering: true)
                @unknown default:
                    coverPlaceholder(isShimmering: false)
                }
            }
        } else {
            coverPlaceholder(isShimmering: false)
        }
    }

    private func coverPlaceholder(isShimmering: Bool) -> some View {
        ZStack {
            PulseColor.shimmerBase
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(PulseColor.placeholderIcon)
        }
        .shimmer(active: isShimmering)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(PulseFont.cardTitle)
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                metaText
                    .frame(maxWidth: .infinity, alignment: .leading)

                readingTimeBadge
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var metaText: some View {
        HStack(spacing: 6) {
            if !authorName.isEmpty {
                Text(authorName)
                    .font(PulseFont.author)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(0)

                metaSeparator
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
            }

            Text(publishedAt, style: .relative)
                .font(PulseFont.meta)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
        }
        .foregroundStyle(PulseColor.secondaryText)
    }

    private var metaSeparator: some View {
        Text("·")
            .font(PulseFont.meta)
            .foregroundStyle(PulseColor.secondaryText)
    }

    private var readingTimeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(PulseFont.badge)
            Text("\(readingTimeMinutes) min")
                .font(PulseFont.badge)
        }
        .foregroundStyle(PulseColor.badgeText)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(PulseColor.badgeBackground, in: Capsule())
    }
}
