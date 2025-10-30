//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import Foundation
import Testing

@testable import Domain

@Suite("Domain Tests")
struct DomainTests {
  @Test("Successfully creates domain from string")
  func testCreateFromString() throws {
    let domain = try Domain("example.com")
    #expect(domain.name == "example.com")
  }

  @Test("Successfully creates domain from labels")
  func testCreateFromLabels() throws {
    let domain = try Domain(labels: ["mail", "example", "com"])
    #expect(domain.name == "mail.example.com")
  }

  @Test("Successfully handles subdomain relationship")
  func testSubdomainRelationship() throws {
    let parent = try Domain("example.com")
    let child = try Domain("mail.example.com")
    let unrelated = try Domain("other.com")

    #expect(child.isSubdomain(of: parent))
    #expect(!parent.isSubdomain(of: child))
    #expect(!child.isSubdomain(of: unrelated))
  }

  @Test("Successfully adds subdomain")
  func testAddSubdomain() throws {
    let domain = try Domain("example.com")
    let subdomain = try domain.addingSubdomain("mail")
    #expect(subdomain.name == "mail.example.com")
    #expect(subdomain.isSubdomain(of: domain))
  }

  @Test("Successfully gets parent domain")
  func testParentDomain() throws {
    let domain = try Domain("mail.example.com")
    let parent = try domain.parent()
    #expect(parent?.name == "example.com")
  }

  @Test("Successfully encodes and decodes domain")
  func testCodable() throws {
    let original = try Domain("mail.example.com")
    let encoded = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(Domain.self, from: encoded)
    #expect(original == decoded)
    #expect(decoded.name == "mail.example.com")
  }

  @Test("Successfully uses RawRepresentable")
  func testRawRepresentable() throws {
    let domain = try Domain("example.com")
    #expect(domain.rawValue == "example.com")
    let fromRaw = Domain(rawValue: "example.com")
    #expect(fromRaw != nil)
    #expect(fromRaw?.name == "example.com")
  }

  @Test("Successfully uses CustomStringConvertible")
  func testDescription() throws {
    let domain = try Domain("example.com")
    #expect(domain.description == "example.com")
    #expect("\(domain)" == "example.com")
  }
}
