// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "wrp-swift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "Wrp", targets: ["Wrp"])
    ],
    dependencies: [
        // GRPC library for protobuf serializer/deserializer
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.7.3"),
        // Protobuf library for en/decoding Wrp messages
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.19.0"),
        // Swift logging API
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Wrp",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Logging", package: "swift-log"),
            ],
            exclude: ["Messages/wrp.proto"]
        ),
        .testTarget(
            name: "WrpTests",
            dependencies: ["Wrp"]
        )
    ]
)
