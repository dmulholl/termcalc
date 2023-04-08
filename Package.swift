// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TermCalc",
    products: [
        .executable(
            name: "termcalc",
            targets: ["TermCalc"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/dmulholl/argparser.git",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/dmulholl/calclang.git",
            from: "0.1.0"
        ),
        .package(
            url: "https://github.com/dmulholl/termutils.git",
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "TermCalc",
            dependencies: ["CalcLang", "ArgParser", "TermUtils"]),
    ]
)
