// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Miknatizale",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Miknatizale", targets: ["Miknatizale"])
    ],
    targets: [
        .executableTarget(
            name: "Miknatizale",
            path: "Sources",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Carbon"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("SwiftUI")
            ]
        )
    ]
)
