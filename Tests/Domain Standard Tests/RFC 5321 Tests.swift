//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import RFC_5321
import Testing
import Foundation
@testable import Domain_Standard

@Suite
struct `RFC 5321 Domain Tests` {
    @Test
    func `Successfully creates RFC_5321.Domain from standard domain`() throws {
        let domain = try RFC_5321.Domain("mail.example.com")
        #expect(domain.name == "mail.example.com")
    }

    @Test
    func `Successfully creates RFC_5321.Domain with numeric labels`() throws {
        let domain = try RFC_5321.Domain("123.example.com")
        #expect(domain.name == "123.example.com")
    }

    @Test
    func `Successfully gets TLD from RFC_5321.Domain`() throws {
        let domain = try RFC_5321.Domain("example.com")
        #expect(domain.tld.map(String.init) == "com")
    }

    @Test
    func `Successfully gets SLD from RFC_5321.Domain`() throws {
        let domain = try RFC_5321.Domain("example.com")
        #expect(domain.sld.map(String.init) == "example")
    }

    @Test
    func `Fails with empty domain`() throws {
        #expect(throws: RFC_5321.Domain.ValidationError.empty) {
            _ = try RFC_5321.Domain("")
        }
    }

    @Test
    func `Fails with invalid TLD starting with number`() throws {
        #expect(throws: RFC_5321.Domain.ValidationError.invalidTLD("123com")) {
            _ = try RFC_5321.Domain("example.123com")
        }
    }

    @Test
    func `Successfully detects subdomain relationship`() throws {
        let parent = try RFC_5321.Domain("example.com")
        let child = try RFC_5321.Domain("mail.example.com")
        #expect(child.isSubdomain(of: parent))
    }

    @Test
    func `Successfully adds subdomain`() throws {
        let domain = try RFC_5321.Domain("example.com")
        let subdomain = try domain.addingSubdomain("mail")
        #expect(subdomain.name == "mail.example.com")
    }

    @Test
    func `Successfully gets parent domain`() throws {
        let domain = try RFC_5321.Domain("mail.example.com")
        let parent = try domain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Successfully gets root domain`() throws {
        let domain = try RFC_5321.Domain("mail.example.com")
        let root = try domain.root()
        #expect(root?.name == "example.com")
    }

    @Test
    func `Successfully creates domain from root components`() throws {
        let domain = try RFC_5321.Domain.root("example", "com")
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates domain from subdomain components`() throws {
        let domain = try RFC_5321.Domain.subdomain("com", "example", "mail")
        #expect(domain.name == "mail.example.com")
    }

    @Test
    func `Successfully encodes and decodes`() throws {
        let original = try RFC_5321.Domain("mail.example.com")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RFC_5321.Domain.self, from: encoded)
        #expect(original == decoded)
    }
}
