// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-source-primitives-tests",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    dependencies: [
        // Parent package
        .package(path: "../"),
    ],
    targets: [
        .testTarget(
            name: "Source Primitives Tests",
            dependencies: [
                .product(name: "Source Primitives Test Support", package: "swift-source-primitives"),
            ],
            path: "Sources/Source Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
