// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeActivities",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeActivities", targets: ["TripTribeActivities"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
        .package(path: "../TripTribeUI"),
        .package(path: "../TripTribeNavigation"),
        .package(path: "../TripTribeFirebase"),
    ],
    targets: [
        .target(
            name: "TripTribeActivities",
            dependencies: ["TripTribeCore", "TripTribeUI", "TripTribeNavigation", "TripTribeFirebase"]
        ),
        .testTarget(
            name: "TripTribeActivitiesTests",
            dependencies: ["TripTribeActivities"]
        ),
    ]
)
