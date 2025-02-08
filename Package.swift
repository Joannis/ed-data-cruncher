// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ed",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        .package(path: "/Users/joannisorlandos/git/orlandos-nl/ikigajson"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.66.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ed",
            dependencies: [
                .product(name: "JSONCore", package: "ikigajson"),
                .product(name: "IkigaJSON", package: "ikigajson"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "_NIOFileSystem", package: "swift-nio"),
            ]
        ),
    ]
)
