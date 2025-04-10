// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeNavigation",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeNavigation", targets: ["TripTribeNavigation"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
    ],
    targets: [
        .target(
            name: "TripTribeNavigation",
            dependencies: ["TripTribeCore"]
        ),
        .testTarget(
            name: "TripTribeNavigationTests",
            dependencies: ["TripTribeNavigation"]
        ),
    ]
)
