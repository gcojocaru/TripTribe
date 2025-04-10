// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeNetworking",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeNetworking", targets: ["TripTribeNetworking"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
    ],
    targets: [
        .target(
            name: "TripTribeNetworking",
            dependencies: ["TripTribeCore"]
        ),
        .testTarget(
            name: "TripTribeNetworkingTests",
            dependencies: ["TripTribeNetworking"]
        ),
    ]
)
