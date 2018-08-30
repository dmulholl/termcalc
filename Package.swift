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
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/dmulholland/linenoise-swift.git",
            from: "0.0.5"
        ),
    ],
    targets: [
        .target(
            name: "CalcLang",
            dependencies: []),
        .target(
            name: "TermCalc",
            dependencies: ["CalcLang", "Janus", "TermUtils"]),
        .target(
            name: "TermUtils",
            dependencies: ["LineNoise"]),
        .target(
            name: "TermTest",
            dependencies: ["TermUtils"]),
        .testTarget(
            name: "CalcLangTests",
            dependencies: ["CalcLang"]),
    ]
)
