//
//  PulseNewsApp.swift
//  PulseNews
//
//  Created by Selcuk on 30.09.2026.
//

import CoreNetwork
import CoreStorage
import FeatureFeed
import SwiftData
import SwiftUI

@main
struct PulseNewsApp: App {
    private let modelContainer: ModelContainer
    private let viewModel: FeedViewModel

    init() {
        do {
            let container = try ModelContainer(for: SDArticle.self)
            let networkService = DevToNetworkService()
            let repository = ArticleRepository(networkService: networkService, modelContainer: container)

            modelContainer = container
            viewModel = FeedViewModel(repository: repository)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: viewModel)
        }
        .modelContainer(modelContainer)
    }
}
