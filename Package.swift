// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "TermCalc",
    products: [
        .library(
            name: "CalcLang",
            targets: ["CalcLang"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/dmulholland/janus-swift.git",
            from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "CalcLang",
            dependencies: []),
        .target(
            name: "TermCalc",
            dependencies: ["CalcLang", "Janus"]),
        .testTarget(
            name: "CalcLangTests",
            dependencies: ["CalcLang"]),
    ]
)
