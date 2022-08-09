// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ExportReminders",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "export-reminders",
                    targets: ["ExportReminders"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.0.1")),
    ],
    targets: [
        .target(
            name: "ExportReminders",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "ExportRemindersTests",
            dependencies: ["ExportReminders"]),
    ]
)
