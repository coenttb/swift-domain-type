//
//  Domain.swift
//  swift-domain-standard
//
//  Universal domain type supporting multiple RFC standards
//

import RFC_1035
import RFC_1123

/// A universal domain name that tracks conformance to multiple RFC standards
///
/// ## Category Theory
///
/// Domain is a **product type** that stores the most permissive representation
/// along with optional stricter variants:
///
/// ```
/// Domain = RFC_1123.Domain × Optional<RFC_1035.Domain>
/// ```
///
/// ## RFC Hierarchy
///
/// ```
/// RFC 1035 ⊂ RFC 1123
/// ```
///
/// - **RFC 1035**: Strictest (labels must start with letter)
/// - **RFC 1123**: Allows labels starting with digits (used by RFC 5321/SMTP)
///
/// ## Canonical Storage
///
/// - **Required**: `rfc1123` (always present, most permissive stored)
/// - **Optional**: `rfc1035` (if domain conforms to strictest rules)
///
/// Note: RFC 5321 (SMTP) uses RFC 1123 domain syntax, so `rfc1123` serves both purposes.
public struct Domain: Hashable, Sendable {
    /// RFC 1035 domain if this domain conforms to the strictest standard
    public let rfc1035: RFC_1035.Domain?

    /// RFC 1123 domain (always present)
    ///
    /// Also serves as RFC 5321 domain since RFC 5321 uses RFC 1123 syntax.
    public let rfc1123: RFC_1123.Domain

    /// Initialize with an RFC 1035 domain (strictest)
    ///
    /// Automatically populates rfc1123 since RFC 1035 ⊂ RFC 1123.
    public init(rfc1035: RFC_1035.Domain) throws(Error) {
        self.rfc1035 = rfc1035

        // RFC 1035 domains are valid RFC 1123 domains
        do {
            self.rfc1123 = try RFC_1123.Domain(rfc1035.name)
        } catch {
            throw Error.conversionFailure("RFC 1035", to: "RFC 1123")
        }
    }

    /// Initialize with an RFC 1123 domain (canonical init)
    ///
    /// Attempts to upgrade to RFC 1035 if possible.
    public init(rfc1123: RFC_1123.Domain) {
        // Try to upgrade to RFC 1035 if possible
        self.rfc1035 = try? RFC_1035.Domain(rfc1123.name)
        self.rfc1123 = rfc1123
    }
}

// MARK: - Convenience Initializers

extension Domain {
    /// Initialize from a string representation
    ///
    /// Parses and validates the domain, storing it with all applicable RFC variants.
    public init<S: StringProtocol>(_ string: S) throws(Error) {
        // Always try RFC 1123 (required for rfc5321)
        guard let rfc1123 = try? RFC_1123.Domain(String(string)) else {
            throw Error.invalidFormat(String(string))
        }

        self.init(rfc1123: rfc1123)
    }

    /// Initialize from an array of labels
    public init<S: StringProtocol>(labels: [S]) throws(Error) {
        try self.init(labels.map { String($0) }.joined(separator: "."))
    }
}

// MARK: - Properties

extension Domain {
    /// The domain string, using the most specific format available
    public var name: String {
        rfc1035?.name ?? rfc1123.name
    }

    /// The top-level domain (rightmost label)
    public var tld: String? {
        rfc1035?.tld?.value ?? rfc1123.tld?.value
    }

    /// The second-level domain (second from right)
    public var sld: String? {
        rfc1035?.sld?.value ?? rfc1123.sld?.value
    }

    /// Returns true if this domain conforms to RFC 1035 (strictest)
    public var isRFC1035Compliant: Bool {
        rfc1035 != nil
    }

    /// Returns true if this is a standard domain (has labels, not an IP address)
    ///
    /// Always true for Domain since we only store valid RFC 1123 domains.
    public var isStandardDomain: Bool {
        true
    }
}

// MARK: - Domain Operations

extension Domain {
    /// Returns true if this is a subdomain of the given domain
    public func isSubdomain(of parent: Domain) -> Bool {
        // Use the most specific format available for both domains
        if let myRFC1035 = rfc1035, let parentRFC1035 = parent.rfc1035 {
            return myRFC1035.isSubdomain(of: parentRFC1035)
        }
        return rfc1123.isSubdomain(of: parent.rfc1123)
    }

    /// Creates a subdomain by prepending new labels
    public func addingSubdomain<S: StringProtocol>(_ components: S...) throws(Error) -> Domain {
        let stringComponents = components.map { String($0) }
        // Use the most specific format available
        if let domain = rfc1035 {
            do {
                return try Domain(rfc1035: domain.addingSubdomain(stringComponents))
            } catch {
                throw Error.cannotCreateSubdomain
            }
        }
        // Fall back to RFC 1123
        do {
            let subdomain = try rfc1123.addingSubdomain(stringComponents)
            return Domain(rfc1123: subdomain)
        } catch {
            throw Error.cannotCreateSubdomain
        }
    }

    /// Returns the parent domain by removing the leftmost label
    public func parent() throws(Error) -> Domain? {
        // Use the most specific format available
        if let domain = rfc1035 {
            do {
                guard let parent = try domain.parent() else { return nil }
                return try Domain(rfc1035: parent)
            } catch {
                throw Error.conversionFailure("RFC 1035", to: "parent domain")
            }
        }
        // Fall back to RFC 1123
        do {
            guard let parent = try rfc1123.parent() else { return nil }
            return Domain(rfc1123: parent)
        } catch {
            throw Error.conversionFailure("RFC 1123", to: "parent domain")
        }
    }

    /// Returns the root domain (tld + sld)
    public func root() throws(Error) -> Domain? {
        if let domain = rfc1035 {
            do {
                guard let root = try domain.root() else { return nil }
                return try Domain(rfc1035: root)
            } catch {
                throw Error.conversionFailure("RFC 1035", to: "root domain")
            }
        }
        // Fall back to RFC 1123
        do {
            guard let root = try rfc1123.root() else { return nil }
            return Domain(rfc1123: root)
        } catch {
            throw Error.conversionFailure("RFC 1123", to: "root domain")
        }
    }
}

// MARK: - Errors

extension Domain {
    /// Errors that can occur during domain operations
    public enum Error: Swift.Error, Equatable {
        /// Invalid domain format
        case invalidFormat(_ description: String)

        /// Cannot create subdomain for this domain type
        case cannotCreateSubdomain

        /// RFC conversion failed
        case conversionFailure(_ from: String, to: String)

        /// IDNA conversion failed
        case idnaConversionFailure(_ reason: String)
    }
}

// MARK: - CustomStringConvertible

extension Domain.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidFormat(let desc):
            return "Invalid domain format: \(desc)"
        case .cannotCreateSubdomain:
            return "Cannot create subdomain for this domain type"
        case .conversionFailure(let from, let to):
            return "Failed to convert from \(from) to \(to)"
        case .idnaConversionFailure(let reason):
            return "IDNA conversion failed: \(reason)"
        }
    }
}

// MARK: - Protocol Conformances

extension Domain: CustomStringConvertible {
    public var description: String { name }
}

extension Domain: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }
}

extension Domain: RawRepresentable {
    public var rawValue: String { name }
    public init?(rawValue: String) { try? self.init(rawValue) }
}
