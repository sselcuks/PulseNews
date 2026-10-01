import CoreInterfaces
import DesignSystem
import Observation
import SwiftUI

public struct FeedView: View {
    @Bindable private var viewModel: FeedViewModel

    @Environment(\.openURL) private var openURL

    public init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(message: errorMessage)
                    }

                    content
                }
                .padding(16)
            }
            .background(PulseColor.pageBackground)
            .refreshable {
                await viewModel.refresh()
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search articles"
            )
            .navigationTitle("Pulse")
            .task {
                await viewModel.loadArticles()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.articles.isEmpty {
            ShimmerLoadingView()
        } else if viewModel.filteredArticles.isEmpty {
            emptyState
        } else {
            ForEach(viewModel.filteredArticles) { article in
                ArticleCardView(
                    coverImageURL: article.coverImageURL,
                    title: article.title,
                    authorName: article.authorName,
                    publishedAt: article.publishedAt,
                    readingTimeMinutes: article.readingTimeMinutes,
                    onTap: { openURL(article.articleURL) }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.searchText.isEmpty ? "newspaper" : "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(PulseColor.placeholderIcon)

            Text(viewModel.searchText.isEmpty ? "No articles yet" : "No results for \"\(viewModel.searchText)\"")
                .font(PulseFont.cardTitle)
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)

            if viewModel.searchText.isEmpty {
                Button("Try Again") {
                    Task { await viewModel.loadArticles() }
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseColor.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.orange)

            Text(message)
                .font(PulseFont.meta)
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.dismissError()
            } label: {
                Image(systemName: "xmark")
                    .font(PulseFont.badge)
                    .foregroundStyle(PulseColor.secondaryText)
            }
            .accessibilityLabel(Text("Dismiss"))
        }
        .padding(12)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
