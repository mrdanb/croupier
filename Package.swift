// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Croupier",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "Croupier",
            targets: ["Croupier"]),
    ],
    targets: [
        .target(name: "Croupier", dependencies: [], path: "Croupier"),
//        .testTarget(name: "CroupierTests", dependencies: ["Croupier"]),
    ]
)
