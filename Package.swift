// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Blurry",
    dependencies: [
        .package(url: "https://github.com/kinglouie/CommandLine.git", from: "3.1.1"),
    ],
    targets: [
        .target(
            name: "PrivateCG",
            dependencies: []),
        .target(
            name: "Blurry",
            dependencies: ["PrivateCG", "CommandLineKit"]),
    ]
)
