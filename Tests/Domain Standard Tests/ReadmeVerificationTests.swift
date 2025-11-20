//
//  ReadmeVerificationTests.swift
//  swift-domain-standard
//
//  Validates all code examples from README.md
//

import RFC_1035
import Testing
import Foundation
@testable import Domain_Standard

@Suite("README Code Examples Validation", .serialized)
struct ReadmeVerificationTests {

    @Test
    func `Quick Start - Basic Domain Creation (README lines 43-53)`() throws {
        // Create a domain from a string
        let domain = try Domain("example.com")
        #expect(domain.name == "example.com")

        // Access domain components
        #expect(domain.tld == "com")
        #expect(domain.sld == "example")
    }

    @Test
    func `Quick Start - Working with Subdomains (README lines 57-68)`() throws {
        let domain = try Domain("example.com")

        // Create a subdomain
        let subdomain = try domain.addingSubdomain("www")
        #expect(subdomain.name == "www.example.com")

        // Check subdomain relationships
        let isSubdomain = subdomain.isSubdomain(of: domain)
        #expect(isSubdomain == true)

        // Get parent domain
        let parent = try subdomain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Quick Start - Multi-RFC Format Support (README lines 72-88)`() throws {
        // The Domain type automatically detects which RFC formats are valid
        let domain = try Domain("example.com")

        // Check which formats are supported
        #expect(domain.isStandardDomain == true)

        // Access specific RFC representations if needed
        if let rfc1035 = domain.rfc1035 {
            // Use strict DNS domain
            #expect(rfc1035.name == "example.com")
        }
        // RFC 1123 format is always available
        #expect(domain.rfc1123.name == "example.com")
        // RFC 5321 uses RFC 1123 domain syntax
        #expect(domain.rfc1123.name == "example.com")
    }

    @Test
    func `Initializing Domains (README lines 94-104)`() throws {
        // From string
        let domain1 = try Domain("example.com")
        #expect(domain1.name == "example.com")

        // From labels array
        let domain2 = try Domain(labels: ["www", "example", "com"])
        #expect(domain2.name == "www.example.com")

        // From specific RFC format
        let rfc1035Domain = try RFC_1035.Domain("example.com")
        let domain3 = try Domain(rfc1035: rfc1035Domain)
        #expect(domain3.name == "example.com")
    }

    @Test
    func `Domain Operations (README lines 108-125)`() throws {
        let domain = try Domain("example.com")

        // Add multiple subdomain levels
        let deepSubdomain = try domain.addingSubdomain("api", "v1")
        // Note: subdomains are added in the order given, so "api" then "v1"
        #expect(deepSubdomain.name == "api.v1.example.com")

        // Walk up the domain hierarchy
        var current: Domain? = deepSubdomain
        var hierarchy: [String] = []
        while let dom = current {
            hierarchy.append(dom.name)
            current = try? dom.parent()
        }
        // Parent hierarchy includes all levels up to TLD
        #expect(hierarchy.contains("api.v1.example.com"))
        #expect(hierarchy.contains("v1.example.com"))
        #expect(hierarchy.contains("example.com"))
    }

    @Test
    func `Subdomain Checking (README lines 129-139)`() throws {
        let root = try Domain("example.com")
        let sub1 = try Domain("www.example.com")
        let sub2 = try Domain("api.example.com")
        let other = try Domain("other.com")

        #expect(sub1.isSubdomain(of: root) == true)
        #expect(sub2.isSubdomain(of: root) == true)
        #expect(other.isSubdomain(of: root) == false)
        #expect(root.isSubdomain(of: sub1) == false)
    }

    @Test
    func `Codable Support (README lines 143-155)`() throws {
        struct Config: Codable {
            let domain: Domain
        }

        // Encoding
        let config = Config(domain: try Domain("example.com"))
        let jsonData = try JSONEncoder().encode(config)
        #expect(!jsonData.isEmpty)

        // Decoding
        let decoded = try JSONDecoder().decode(Config.self, from: jsonData)
        #expect(decoded.domain.name == "example.com")
    }

    @Test
    func `RawRepresentable (README lines 159-168)`() throws {
        let domain = try Domain("example.com")

        // Get raw value
        let rawValue = domain.rawValue
        #expect(rawValue == "example.com")

        // Initialize from raw value
        let reconstructed = Domain(rawValue: "example.com")
        #expect(reconstructed?.name == "example.com")
    }

    @Test
    func `Error Handling (README lines 207-219)`() throws {
        // DomainError enum provides detailed error information
        // Note: Invalid domains throw errors from underlying RFC implementations
        do {
            let _ = try Domain("invalid domain with spaces")
            Issue.record("Should have thrown an error for invalid domain")
        } catch {
            // Expected to catch an error for invalid domain format
            #expect(true, "Correctly threw error for invalid domain")
        }
    }
}
