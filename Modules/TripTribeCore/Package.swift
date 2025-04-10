// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeCore",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeCore", targets: ["TripTribeCore"]),
    ],
    targets: [
        .target(
            name: "TripTribeCore",
            dependencies: []
        ),
        .testTarget(
            name: "TripTribeCoreTests",
            dependencies: ["TripTribeCore"]
        ),
    ]
)
