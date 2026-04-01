// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-source-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Source Primitives",
            targets: ["Source Primitives"]
        ),
        .library(
            name: "Source Primitives Test Support",
            targets: ["Source Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-text-primitives")
    ],
    targets: [
        .target(
            name: "Source Primitives",
            dependencies: [
                .product(name: "Text Primitives", package: "swift-text-primitives")
            ]
        ),
        .target(
            name: "Source Primitives Test Support",
            dependencies: [
                "Source Primitives",
                .product(name: "Text Primitives Test Support", package: "swift-text-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Source Primitives Tests",
            dependencies: [
                "Source Primitives",
                "Source Primitives Test Support",
            ],
            path: "Tests/Source Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
