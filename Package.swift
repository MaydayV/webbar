// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WebBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "WebBar", targets: ["WebBar"])
    ],
    targets: [
        .executableTarget(
            name: "WebBar",
            path: "Sources/WebBar",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("WebKit"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("UserNotifications")
            ]
        ),
        .testTarget(
            name: "WebBarTests",
            dependencies: ["WebBar"],
            path: "Tests/WebBarTests"
        )
    ]
)
