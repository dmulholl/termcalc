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
            url: "https://github.com/dmulholl/argparser.git",
            from: "2.0.0"
        ),
    ],
    targets: [
        .target(
            name: "CalcLang",
            dependencies: []),
        .target(
            name: "TermCalc",
            dependencies: ["CalcLang", "ArgParser", "TermUtils"]),
        .target(
            name: "TermUtils",
            dependencies: []),
        .target(
            name: "TermTest",
            dependencies: ["TermUtils"]),
        .testTarget(
            name: "CalcLangTests",
            dependencies: ["CalcLang"]),
    ]
)
