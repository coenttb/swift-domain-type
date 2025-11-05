//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import Foundation
import RFC_1123
import Testing

@testable import Domain

@Suite("RFC 1123 Host Tests")
struct RFC1123Tests {
    @Test("Successfully creates valid host")
    func testValidHost() throws {
        let host = try RFC_1123.Domain("host.example.com")
        #expect(host.name == "host.example.com")
    }

    @Test("Successfully creates host with numeric labels")
    func testNumericLabels() throws {
        let host = try RFC_1123.Domain("123.example.com")
        #expect(host.name == "123.example.com")
    }

    @Test("Successfully creates host with mixed alphanumeric labels")
    func testMixedLabels() throws {
        let host = try RFC_1123.Domain("host123.example456.com")
        #expect(host.name == "host123.example456.com")
    }

    @Test("Fails with empty host")
    func testEmptyHost() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.empty) {
            _ = try RFC_1123.Domain("")
        }
    }

    @Test("Fails with invalid TLD starting with number")
    func testInvalidTLDStartingWithNumber() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.invalidTLD("123com")) {
            _ = try RFC_1123.Domain("example.123com")
        }
    }

    @Test("Fails with invalid TLD ending with number")
    func testInvalidTLDEndingWithNumber() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.invalidTLD("com123")) {
            _ = try RFC_1123.Domain("example.com123")
        }
    }

    @Test("Fails with invalid label containing special characters")
    func testInvalidLabelSpecialChars() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.invalidLabel("host@name")) {
            _ = try RFC_1123.Domain("host@name.com")
        }
    }

    @Test("Successfully gets TLD")
    func testTLD() throws {
        let host = try RFC_1123.Domain("example.com")
        #expect(host.tld?.stringValue == "com")
    }

    @Test("Successfully gets SLD")
    func testSLD() throws {
        let host = try RFC_1123.Domain("example.com")
        #expect(host.sld?.stringValue == "example")
    }

    @Test("Successfully detects subdomain relationship")
    func testIsSubdomain() throws {
        let parent = try RFC_1123.Domain("example.com")
        let child = try RFC_1123.Domain("host.example.com")
        #expect(child.isSubdomain(of: parent))
    }

    @Test("Successfully adds subdomain")
    func testAddSubdomain() throws {
        let host = try RFC_1123.Domain("example.com")
        let subdomain = try host.addingSubdomain("host")
        #expect(subdomain.name == "host.example.com")
    }

    @Test("Successfully gets parent domain")
    func testParentDomain() throws {
        let host = try RFC_1123.Domain("host.example.com")
        let parent = try host.parent()
        #expect(parent?.name == "example.com")
    }

    @Test("Successfully gets root domain")
    func testRootDomain() throws {
        let host = try RFC_1123.Domain("host.example.com")
        let root = try host.root()
        #expect(root?.name == "example.com")
    }

    @Test("Successfully creates host from root components")
    func testRootInitializer() throws {
        let host = try RFC_1123.Domain.root("example", "com")
        #expect(host.name == "example.com")
    }

    @Test("Successfully creates host from subdomain components")
    func testSubdomainInitializer() throws {
        let host = try RFC_1123.Domain.subdomain("com", "example", "host")
        #expect(host.name == "host.example.com")
    }

    @Test("Successfully encodes and decodes")
    func testCodable() throws {
        let original = try RFC_1123.Domain("example.com")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RFC_1123.Domain.self, from: encoded)
        #expect(original == decoded)
    }
}
