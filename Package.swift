// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AdventOfCode",
    platforms: [
       .macOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4"),
    ],
    targets: [
        .executableTarget(
            name: "advent-of-code",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
    ]
)
