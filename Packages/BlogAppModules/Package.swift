// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BlogAppModules",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "CoreInterfaces", targets: ["CoreInterfaces"]),
        .library(name: "CoreNetwork", targets: ["CoreNetwork"]),
        .library(name: "CoreStorage", targets: ["CoreStorage"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "FeatureFeed", targets: ["FeatureFeed"])
    ],
    targets: [
        .target(
            name: "CoreInterfaces"
        ),
        .target(
            name: "CoreNetwork",
            dependencies: [
                "CoreInterfaces"
            ]
        ),
        .target(
            name: "CoreStorage",
            dependencies: [
                "CoreInterfaces",
                "CoreNetwork"
            ]
        ),
        .target(
            name: "DesignSystem"
        ),
        .target(
            name: "FeatureFeed",
            dependencies: [
                "CoreInterfaces",
                "DesignSystem"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
