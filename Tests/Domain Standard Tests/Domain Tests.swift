//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import Testing

@testable import Domain_Standard

@Suite
struct `Domain Tests` {
    @Test
    func `Successfully creates domain from string`() throws {
        let domain = try Domain("example.com")
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates domain from labels`() throws {
        let domain = try Domain(labels: ["mail", "example", "com"])
        #expect(domain.name == "mail.example.com")
    }

    @Test
    func `Successfully handles subdomain relationship`() throws {
        let parent = try Domain("example.com")
        let child = try Domain("mail.example.com")
        let unrelated = try Domain("other.com")

        #expect(child.isSubdomain(of: parent))
        #expect(!parent.isSubdomain(of: child))
        #expect(!child.isSubdomain(of: unrelated))
    }

    @Test
    func `Successfully adds subdomain`() throws {
        let domain = try Domain("example.com")
        let subdomain = try domain.addingSubdomain("mail")
        #expect(subdomain.name == "mail.example.com")
        #expect(subdomain.isSubdomain(of: domain))
    }

    @Test
    func `Successfully gets parent domain`() throws {
        let domain = try Domain("mail.example.com")
        let parent = try domain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Successfully encodes and decodes domain`() throws {
        let original = try Domain("mail.example.com")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Domain.self, from: encoded)
        #expect(original == decoded)
        #expect(decoded.name == "mail.example.com")
    }

    @Test
    func `Successfully uses RawRepresentable`() throws {
        let domain = try Domain("example.com")
        #expect(domain.rawValue == "example.com")
        let fromRaw = Domain(rawValue: "example.com")
        #expect(fromRaw != nil)
        #expect(fromRaw?.name == "example.com")
    }

    @Test
    func `Successfully uses CustomStringConvertible`() throws {
        let domain = try Domain("example.com")
        #expect(domain.description == "example.com")
        #expect("\(domain)" == "example.com")
    }
}
