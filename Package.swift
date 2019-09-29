// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Croupier",
    platforms: [
        .iOS(.v11),
    ],
//    products: [
//        .library(name: "MyLibrary", targets: ["MyLibrary"]),
//    ],
    targets: [
        .target(name: "Croupier"),
//        .testTarget(name: "MyLibraryTests", dependencies: ["MyLibrary"]),
    ]
)
