// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Croupier",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_12),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Croupier",
            targets: ["Croupier"]),
    ],
    targets: [
        .target(name: "Croupier", dependencies: [], path: "Croupier"),
//        .testTarget(name: "CroupierTests", dependencies: ["Croupier"]),
    ],
    swiftLanguageVersions: [.v5]
)
