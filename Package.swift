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
    ],
    targets: [
        .target(
            name: "CalcLang",
            dependencies: []),
        .target(
            name: "TermCalc",
            dependencies: ["CalcLang"]),
        .testTarget(
            name: "CalcLangTests",
            dependencies: ["CalcLang"]),
    ]
)
