// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeTrips",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeTrips", targets: ["TripTribeTrips"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
        .package(path: "../TripTribeUI"),
        .package(path: "../TripTribeNavigation"),
        .package(path: "../TripTribeFirebase"),
    ],
    targets: [
        .target(
            name: "TripTribeTrips",
            dependencies: ["TripTribeCore", "TripTribeUI", "TripTribeNavigation", "TripTribeFirebase"]
        ),
        .testTarget(
            name: "TripTribeTripsTests",
            dependencies: ["TripTribeTrips"]
        ),
    ]
)
