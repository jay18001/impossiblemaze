// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ImpossibleMaze",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "impossible-maze",
            targets: ["impossible-maze2"]),
        .library(
            name: "ImpossibleMaze",
            type: .dynamic,
            targets: ["ImpossibleMaze"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "fe24cb01640c2d4d48c8555a71adfe346d9543cf"),
        .package(url: "https://github.com/migueldeicaza/SwiftGodotKit", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "impossible-maze2",
            dependencies: [
                "ImpossibleMaze",
//                .product(name: "SwiftGodotKit", package: "SwiftGodotKit")
            ],
            resources: [
                .copy("Resources")
            ]),
        .target(
            name: "ImpossibleMaze",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodot")
            ]),
    ]
)
