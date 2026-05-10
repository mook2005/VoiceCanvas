// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "VoiceCanvas",
    platforms: [.iOS("16.0")],
    products: [
        .iOSApplication(
            name: "VoiceCanvas",
            targets: ["VoiceCanvas"],
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .pencil),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight]
        )
    ],
    targets: [
        .executableTarget(
            name: "VoiceCanvas",
            path: "Sources/VoiceCanvas"
        )
    ]
)
