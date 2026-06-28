// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Graphite",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Graphite", targets: ["Graphite"])
    ],
    targets: [
        .executableTarget(
            name: "Graphite",
            path: "Graphite"
        ),
        .testTarget(
            name: "GraphiteTests",
            dependencies: ["Graphite"],
            path: "GraphiteTests"
        )
    ]
)
