// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let domain: Self = "Domain"
}

extension Target.Dependency {
    static var domain: Self { .target(name: .domain) }
}

extension Target.Dependency {
    static var rfc1035: Self { .product(name: "RFC 1035", package: "swift-web-standards") }
    static var rfc1123: Self { .product(name: "RFC 1123", package: "swift-web-standards") }
    static var rfc5321: Self { .product(name: "RFC 5321", package: "swift-web-standards") }
}

let package = Package(
    name: "swift-domain-type",
    platforms: [ .macOS(.v13), .iOS(.v16) ],
    products: [
        .library(name: .domain, targets: [.domain])
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-web-standards", branch: "main")
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
                .domain
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
