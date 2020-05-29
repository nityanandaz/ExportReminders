// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExportReminders",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "export-reminders",
                    targets: ["ExportReminders"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.1")),
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
