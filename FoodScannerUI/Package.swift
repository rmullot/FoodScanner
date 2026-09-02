// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FoodScannerUI",
    defaultLocalization: "fr",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FoodScannerUI", targets: ["FoodScannerUI"])
    ],
    targets: [
        .target(
            name: "FoodScannerUI",
            resources: [
                .process("Resources/FoodScannerUI.xcassets"),
                .process("Resources/Scenes"),
                .process("Resources/fr.lproj"),
                .process("Resources/en.lproj")
            ]
        ),
        .testTarget(name: "FoodScannerUITests", dependencies: ["FoodScannerUI"])
    ]
)
