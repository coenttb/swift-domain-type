//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import RFC_1123
import Testing
import Foundation
@testable import Domain_Standard

@Suite
struct `RFC 1123 Host Tests` {
    @Test
    func `Successfully creates valid host`() throws {
        let host = try RFC_1123.Domain("host.example.com")
        #expect(host.name == "host.example.com")
    }

    @Test
    func `Successfully creates host with numeric labels`() throws {
        let host = try RFC_1123.Domain("123.example.com")
        #expect(host.name == "123.example.com")
    }

    @Test
    func `Successfully creates host with mixed alphanumeric labels`() throws {
        let host = try RFC_1123.Domain("host123.example456.com")
        #expect(host.name == "host123.example456.com")
    }

    @Test
    func `Fails with empty host`() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.empty) {
            _ = try RFC_1123.Domain("")
        }
    }

    @Test
    func `Fails with invalid TLD starting with number`() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.invalidTLD("123com")) {
            _ = try RFC_1123.Domain("example.123com")
        }
    }

    @Test
    func `Fails with invalid TLD ending with number`() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.invalidTLD("com123")) {
            _ = try RFC_1123.Domain("example.com123")
        }
    }

    @Test
    func `Fails with invalid label containing special characters`() throws {
        #expect(throws: RFC_1123.Domain.ValidationError.invalidLabel("host@name")) {
            _ = try RFC_1123.Domain("host@name.com")
        }
    }

    @Test
    func `Successfully gets TLD`() throws {
        let host = try RFC_1123.Domain("example.com")
        #expect(host.tld.map(String.init) == "com")
    }

    @Test
    func `Successfully gets SLD`() throws {
        let host = try RFC_1123.Domain("example.com")
        #expect(host.sld.map(String.init) == "example")
    }

    @Test
    func `Successfully detects subdomain relationship`() throws {
        let parent = try RFC_1123.Domain("example.com")
        let child = try RFC_1123.Domain("host.example.com")
        #expect(child.isSubdomain(of: parent))
    }

    @Test
    func `Successfully adds subdomain`() throws {
        let host = try RFC_1123.Domain("example.com")
        let subdomain = try host.addingSubdomain("host")
        #expect(subdomain.name == "host.example.com")
    }

    @Test
    func `Successfully gets parent domain`() throws {
        let host = try RFC_1123.Domain("host.example.com")
        let parent = try host.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Successfully gets root domain`() throws {
        let host = try RFC_1123.Domain("host.example.com")
        let root = try host.root()
        #expect(root?.name == "example.com")
    }

    @Test
    func `Successfully creates host from root components`() throws {
        let host = try RFC_1123.Domain.root("example", "com")
        #expect(host.name == "example.com")
    }

    @Test
    func `Successfully creates host from subdomain components`() throws {
        let host = try RFC_1123.Domain.subdomain("com", "example", "host")
        #expect(host.name == "host.example.com")
    }

    @Test
    func `Successfully encodes and decodes`() throws {
        let original = try RFC_1123.Domain("example.com")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RFC_1123.Domain.self, from: encoded)
        #expect(original == decoded)
    }
}
