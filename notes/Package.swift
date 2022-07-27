// swift-tools-version:5.6

import PackageDescription
import Foundation

/*
// https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md
// https://theswiftdev.com/the-swift-package-manifest-file/
platforms: [] // define the platforms you support (only iOS)
products: [.executable(name: "app", targets: [various app targets])] (can also do .library)
targets: [name: "app"]

*/

let theosPath = "/home/hamdan/iOS/Theos"
let sdk = "/home/hamdan/iOS/Theos/sdks/iPhoneOS14.5.sdk"
let resourceDir = "/home/hamdan/iOS/Theos/toolchain/linux/iphone/bin/../lib/swift"
let deploymentTarget = "12.2"
let triple = "arm64e-apple-ios\(deploymentTarget)"

let libFlags: [String] = [
    "-F\(theosPath)/vendor/lib", "-F\(theosPath)/lib",
    "-I\(theosPath)/vendor/include", "-I\(theosPath)/include"
]

let cFlags: [String] = libFlags + [
    "-target", triple, "-isysroot", sdk,
    "-Wno-unused-command-line-argument", "-Qunused-arguments",
]

let cxxFlags: [String] = [
]

let swiftFlags: [String] = libFlags + [
    "-target", triple, "-sdk", sdk, "-resource-dir", resourceDir,
]

let package = Package(
    name: "bo",
    platforms: [.iOS(deploymentTarget)],
    products: [
        .library( // since we are compiling a swift library (we want a dylibwsl)
            name: "bo",
            targets: ["bo"]
        ),
    ],
    targets: [
        .target(
            name: "boC",
            cSettings: [.unsafeFlags(cFlags)],
            cxxSettings: [.unsafeFlags(cxxFlags)]
        ),
        .target(
            name: "bo",
            dependencies: ["boC"],
            swiftSettings: [.unsafeFlags(swiftFlags)]
        ),
    ]
)

