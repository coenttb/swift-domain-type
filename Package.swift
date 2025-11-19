// swift-tools-version:6.0

import PackageDescription

extension String {
    static let domain: Self = "Domain Standard"
}

extension Target.Dependency {
    static var domain: Self { .target(name: .domain) }
}

extension Target.Dependency {
    static var rfc1035: Self { .product(name: "RFC_1035", package: "swift-rfc-1035") }
    static var rfc1123: Self { .product(name: "RFC_1123", package: "swift-rfc-1123") }
    static var rfc5321: Self { .product(name: "RFC_5321", package: "swift-rfc-5321") }
}

let package = Package(
    name: "swift-domain-standard",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: .domain, targets: [.domain])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-1035", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-1123", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-5321", from: "0.1.0")
    ],
    targets: [
        .target(
            name: .domain,
            dependencies: [
                .rfc1035,
                .rfc1123,
                .rfc5321
            ]
        ),
        .testTarget(
            name: .domain.tests,
            dependencies: [
                .domain,
                .rfc1035,
                .rfc1123,
                .rfc5321
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
