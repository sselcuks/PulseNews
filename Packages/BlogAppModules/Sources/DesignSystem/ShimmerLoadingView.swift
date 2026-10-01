import SwiftUI

public extension View {
    func shimmer(active: Bool = true, duration: Double = 1.4) -> some View {
        modifier(ShimmerEffect(isActive: active, duration: duration))
    }
}

public struct ShimmerEffect: ViewModifier {
    private let isActive: Bool
    private let duration: Double

    public init(isActive: Bool = true, duration: Double = 1.4) {
        self.isActive = isActive
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { proxy in
                        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                            LinearGradient(
                                colors: [.clear, PulseColor.shimmerHighlight, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: proxy.size.width)
                            .rotationEffect(.degrees(20))
                            .offset(x: (Self.progress(at: timeline.date, duration: duration) * 2 - 1) * proxy.size.width)
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
    }

    private static func progress(at date: Date, duration: Double) -> CGFloat {
        let cycle = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration
        return CGFloat(cycle)
    }
}

public struct ArticleCardSkeletonView: View {
    public static let cornerRadius: CGFloat = 18
    public static let coverAspectRatio: CGFloat = 16.0 / 9.0

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PulseColor.shimmerBase
                .frame(maxWidth: .infinity)
                .aspectRatio(Self.coverAspectRatio, contentMode: .fill)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                PulseColor.shimmerBase
                    .frame(height: 16)
                    .clipShape(Capsule())
                PulseColor.shimmerBase
                    .frame(width: 220, height: 16)
                    .clipShape(Capsule())
                PulseColor.shimmerBase
                    .frame(width: 130, height: 12)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(PulseColor.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .stroke(PulseColor.cardBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .shimmer()
    }
}

public struct ShimmerLoadingView: View {
    public static let defaultRowCount = 4

    public let rowCount: Int

    public init(rowCount: Int = ShimmerLoadingView.defaultRowCount) {
        self.rowCount = rowCount
    }

    public var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<max(rowCount, 0), id: \.self) { _ in
                ArticleCardSkeletonView()
            }
        }
        .accessibilityLabel(Text("Loading articles"))
    }
}
