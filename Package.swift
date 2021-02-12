// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TermCalc",
    dependencies: [
        .package(
            url: "https://github.com/dmulholl/argparser.git",
            from: "2.0.0"
        ),
        .package(
            url: "../calclang",
            from: "1.0.0"
        ),
        .package(
            url: "../termutils",
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "TermCalc",
            dependencies: ["CalcLang", "ArgParser", "TermUtils"]),
    ]
)
