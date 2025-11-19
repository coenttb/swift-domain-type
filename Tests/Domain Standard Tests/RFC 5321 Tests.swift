//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import RFC_5321
import Testing

@testable import Domain_Standard

@Suite("RFC 5321 Domain Tests")
struct RFC5321Tests {
    @Test("Successfully creates RFC_5321.Domain from standard domain")
    func testStandardDomain() throws {
        let domain = try RFC_5321.Domain("mail.example.com")
        #expect(domain.name == "mail.example.com")
    }

    @Test("Successfully creates RFC_5321.Domain with numeric labels")
    func testNumericLabels() throws {
        let domain = try RFC_5321.Domain("123.example.com")
        #expect(domain.name == "123.example.com")
    }

    @Test("Successfully gets TLD from RFC_5321.Domain")
    func testTLD() throws {
        let domain = try RFC_5321.Domain("example.com")
        #expect(domain.tld?.stringValue == "com")
    }

    @Test("Successfully gets SLD from RFC_5321.Domain")
    func testSLD() throws {
        let domain = try RFC_5321.Domain("example.com")
        #expect(domain.sld?.stringValue == "example")
    }

    @Test("Fails with empty domain")
    func testEmptyDomain() throws {
        #expect(throws: RFC_5321.Domain.ValidationError.empty) {
            _ = try RFC_5321.Domain("")
        }
    }

    @Test("Fails with invalid TLD starting with number")
    func testInvalidTLD() throws {
        #expect(throws: RFC_5321.Domain.ValidationError.invalidTLD("123com")) {
            _ = try RFC_5321.Domain("example.123com")
        }
    }

    @Test("Successfully detects subdomain relationship")
    func testIsSubdomain() throws {
        let parent = try RFC_5321.Domain("example.com")
        let child = try RFC_5321.Domain("mail.example.com")
        #expect(child.isSubdomain(of: parent))
    }

    @Test("Successfully adds subdomain")
    func testAddSubdomain() throws {
        let domain = try RFC_5321.Domain("example.com")
        let subdomain = try domain.addingSubdomain("mail")
        #expect(subdomain.name == "mail.example.com")
    }

    @Test("Successfully gets parent domain")
    func testParentDomain() throws {
        let domain = try RFC_5321.Domain("mail.example.com")
        let parent = try domain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test("Successfully gets root domain")
    func testRootDomain() throws {
        let domain = try RFC_5321.Domain("mail.example.com")
        let root = try domain.root()
        #expect(root?.name == "example.com")
    }

    @Test("Successfully creates domain from root components")
    func testRootInitializer() throws {
        let domain = try RFC_5321.Domain.root("example", "com")
        #expect(domain.name == "example.com")
    }

    @Test("Successfully creates domain from subdomain components")
    func testSubdomainInitializer() throws {
        let domain = try RFC_5321.Domain.subdomain("com", "example", "mail")
        #expect(domain.name == "mail.example.com")
    }

    @Test("Successfully encodes and decodes")
    func testCodable() throws {
        let original = try RFC_5321.Domain("mail.example.com")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RFC_5321.Domain.self, from: encoded)
        #expect(original == decoded)
    }
}
