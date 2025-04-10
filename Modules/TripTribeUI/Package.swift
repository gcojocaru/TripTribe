// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeUI",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeUI", targets: ["TripTribeUI"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
    ],
    targets: [
        .target(
            name: "TripTribeUI",
            dependencies: ["TripTribeCore"]
        ),
        .testTarget(
            name: "TripTribeUITests",
            dependencies: ["TripTribeUI"]
        ),
    ]
)
