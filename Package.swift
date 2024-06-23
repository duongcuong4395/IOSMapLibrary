// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapLibrary",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MapLibrary",
            targets: ["MapLibrary"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MapLibrary",
            resources: [
                .process("Resources/Traffic/BusRoutes.json"),
                .process("Resources/Traffic/BusServices.json"),
                .process("Resources/Traffic/BusStops.json"),
                .process("Resources/Traffic/CarPark.json"),
                .process("Resources/Maps/MapsStylingLight.geojson"),
                .process("Resources/Maps/MapsStylingNight.geojson")
            ])
    ]
)
