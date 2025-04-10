// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeAuth",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeAuth", targets: ["TripTribeAuth"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
        .package(path: "../TripTribeUI"),
        .package(path: "../TripTribeNavigation"),
        .package(path: "../TripTribeFirebase"),
    ],
    targets: [
        .target(
            name: "TripTribeAuth",
            dependencies: ["TripTribeCore", "TripTribeUI", "TripTribeNavigation", "TripTribeFirebase"]
        ),
        .testTarget(
            name: "TripTribeAuthTests",
            dependencies: ["TripTribeAuth"]
        ),
    ]
)
