// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "YoloApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "YoloApp",
            targets: ["YoloApp"]
        )
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .target(
            name: "YoloApp",
            dependencies: []
        ),
        .testTarget(
            name: "YoloAppTests",
            dependencies: ["YoloApp"]
        )
    ]
) 