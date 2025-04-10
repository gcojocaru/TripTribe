// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TripTribeFirebase",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TripTribeFirebase", targets: ["TripTribeFirebase"]),
    ],
    dependencies: [
        .package(path: "../TripTribeCore"),
    ],
    targets: [
        .target(
            name: "TripTribeFirebase",
            dependencies: ["TripTribeCore"]
        ),
        .testTarget(
            name: "TripTribeFirebaseTests",
            dependencies: ["TripTribeFirebase"]
        ),
    ]
)
