//
//  ReadmeVerificationTests.swift
//  swift-domain-type
//
//  Validates all code examples from README.md
//

import Foundation
import Testing
import RFC_1035

@testable import Domain

@Suite("README Code Examples Validation", .serialized)
struct ReadmeVerificationTests {

  @Test("Quick Start - Basic Domain Creation (README lines 43-53)")
  func quickStartBasicDomainCreation() throws {
    // Create a domain from a string
    let domain = try _Domain("example.com")
    #expect(domain.name == "example.com")

    // Access domain components
    #expect(domain.tld == "com")
    #expect(domain.sld == "example")
  }

  @Test("Quick Start - Working with Subdomains (README lines 57-68)")
  func quickStartWorkingWithSubdomains() throws {
    let domain = try _Domain("example.com")

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

  @Test("Quick Start - Multi-RFC Format Support (README lines 72-88)")
  func quickStartMultiRFCFormatSupport() throws {
    // The Domain type automatically detects which RFC formats are valid
    let domain = try _Domain("example.com")

    // Check which formats are supported
    #expect(domain.isStandardDomain == true)

    // Access specific RFC representations if needed
    if let rfc1035 = domain.rfc1035 {
      // Use strict DNS domain
      #expect(rfc1035.name == "example.com")
    }
    if let rfc1123 = domain.rfc1123 {
      // Use internet host name
      #expect(rfc1123.name == "example.com")
    }
    // RFC 5321 format is always available
    #expect(domain.rfc5321.name == "example.com")
  }

  @Test("Initializing Domains (README lines 94-104)")
  func initializingDomains() throws {
    // From string
    let domain1 = try _Domain("example.com")
    #expect(domain1.name == "example.com")

    // From labels array
    let domain2 = try _Domain(labels: ["www", "example", "com"])
    #expect(domain2.name == "www.example.com")

    // From specific RFC format
    let rfc1035Domain = try RFC_1035.Domain("example.com")
    let domain3 = try _Domain(rfc1035: rfc1035Domain)
    #expect(domain3.name == "example.com")
  }

  @Test("Domain Operations (README lines 108-125)")
  func domainOperations() throws {
    let domain = try _Domain("example.com")

    // Add multiple subdomain levels
    let deepSubdomain = try domain.addingSubdomain("api", "v1")
    // Note: subdomains are added in the order given, so "api" then "v1"
    #expect(deepSubdomain.name == "api.v1.example.com")

    // Walk up the domain hierarchy
    var current: _Domain? = deepSubdomain
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

  @Test("Subdomain Checking (README lines 129-139)")
  func subdomainChecking() throws {
    let root = try _Domain("example.com")
    let sub1 = try _Domain("www.example.com")
    let sub2 = try _Domain("api.example.com")
    let other = try _Domain("other.com")

    #expect(sub1.isSubdomain(of: root) == true)
    #expect(sub2.isSubdomain(of: root) == true)
    #expect(other.isSubdomain(of: root) == false)
    #expect(root.isSubdomain(of: sub1) == false)
  }

  @Test("Codable Support (README lines 143-155)")
  func codableSupport() throws {
    struct Config: Codable {
      let domain: _Domain
    }

    // Encoding
    let config = Config(domain: try _Domain("example.com"))
    let jsonData = try JSONEncoder().encode(config)
    #expect(!jsonData.isEmpty)

    // Decoding
    let decoded = try JSONDecoder().decode(Config.self, from: jsonData)
    #expect(decoded.domain.name == "example.com")
  }

  @Test("RawRepresentable (README lines 159-168)")
  func rawRepresentable() throws {
    let domain = try _Domain("example.com")

    // Get raw value
    let rawValue = domain.rawValue
    #expect(rawValue == "example.com")

    // Initialize from raw value
    let reconstructed = _Domain(rawValue: "example.com")
    #expect(reconstructed?.name == "example.com")
  }

  @Test("Error Handling (README lines 207-219)")
  func errorHandling() throws {
    // DomainError enum provides detailed error information
    // Note: Invalid domains throw errors from underlying RFC implementations
    do {
      let _ = try _Domain("invalid domain with spaces")
      Issue.record("Should have thrown an error for invalid domain")
    } catch {
      // Expected to catch an error for invalid domain format
      #expect(true, "Correctly threw error for invalid domain")
    }
  }
}
