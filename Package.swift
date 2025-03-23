// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MacXTerm",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "MacXTerm",
            targets: ["MacXTerm"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0")
    ],
    targets: [
        .executableTarget(
            name: "MacXTerm",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "MacXTermTests",
            dependencies: ["MacXTerm"],
            path: "Tests"
        )
    ]
) 