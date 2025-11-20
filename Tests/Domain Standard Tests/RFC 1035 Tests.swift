//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 28/12/2024.
//

import RFC_1035
import Testing
import Foundation
@testable import Domain_Standard

@Suite
struct `RFC 1035 Domain Tests` {
    @Test
    func `Successfully creates valid domain`() throws {
        let domain = try RFC_1035.Domain("example.com")
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates subdomain`() throws {
        let domain = try RFC_1035.Domain("sub.example.com")
        #expect(domain.name == "sub.example.com")
    }

    @Test
    func `Successfully gets TLD`() throws {
        let domain = try RFC_1035.Domain("example.com")
        #expect(domain.tld.map(String.init) == "com")
    }

    @Test
    func `Successfully gets SLD`() throws {
        let domain = try RFC_1035.Domain("example.com")
        #expect(domain.sld.map(String.init) == "example")
    }

    @Test
    func `Fails with empty domain`() throws {
        #expect(throws: RFC_1035.Domain.Error.empty) {
            _ = try RFC_1035.Domain("")
        }
    }

    @Test
    func `Fails with too many labels`() throws {
        let longDomain = Array(repeating: "a", count: 128).joined(separator: ".")
        #expect(throws: RFC_1035.Domain.Error.tooManyLabels) {
            _ = try RFC_1035.Domain(longDomain)
        }
    }

    @Test
    func `Fails with too long domain`() throws {
        let longLabel = String(repeating: "a", count: 63)
        let longDomain = Array(repeating: longLabel, count: 5).joined(separator: ".")
        #expect(throws: RFC_1035.Domain.Error.tooLong(319)) {
            _ = try RFC_1035.Domain(longDomain)
        }
    }

    @Test
    func `Fails with invalid label starting with hyphen`() throws {
        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.startsWithHyphen("-example"))) {
            _ = try RFC_1035.Domain("-example.com")
        }
    }

    @Test
    func `Fails with invalid label ending with hyphen`() throws {
        #expect(throws: RFC_1035.Domain.Error.invalidLabel(.endsWithHyphen("example-"))) {
            _ = try RFC_1035.Domain("example-.com")
        }
    }

    @Test
    func `Successfully detects subdomain relationship`() throws {
        let parent = try RFC_1035.Domain("example.com")
        let child = try RFC_1035.Domain("sub.example.com")
        #expect(child.isSubdomain(of: parent))
    }

    @Test
    func `Successfully adds subdomain`() throws {
        let domain = try RFC_1035.Domain("example.com")
        let subdomain = try domain.addingSubdomain("sub")
        #expect(subdomain.name == "sub.example.com")
    }

    @Test
    func `Successfully gets parent domain`() throws {
        let domain = try RFC_1035.Domain("sub.example.com")
        let parent = try domain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Successfully gets root domain`() throws {
        let domain = try RFC_1035.Domain("sub.example.com")
        let root = try domain.root()
        #expect(root?.name == "example.com")
    }

    @Test
    func `Successfully creates domain from root components`() throws {
        let domain = try RFC_1035.Domain.root("example", "com")
        #expect(domain.name == "example.com")
    }

    @Test
    func `Successfully creates domain from subdomain components`() throws {
        let domain = try RFC_1035.Domain.subdomain("com", "example", "sub")
        #expect(domain.name == "sub.example.com")
    }

    @Test
    func `Successfully encodes and decodes`() throws {
        let original = try RFC_1035.Domain("example.com")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RFC_1035.Domain.self, from: encoded)
        #expect(original == decoded)
    }
}
