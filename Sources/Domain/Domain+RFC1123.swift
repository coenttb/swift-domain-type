import Foundation
import RFC_1123

extension Domain {
    // Forward conversion already exists in Domain.swift
    // public init(rfc1123: RFC_1123.Domain)
}

extension RFC_1123.Domain {
    /// Initialize from Domain
    ///
    /// Enables round-trip conversion between Domain and RFC_1123.Domain.
    ///
    /// - Parameter domain: The Domain to convert
    /// - Returns: The RFC 1123 domain representation
    /// - Note: Since RFC_5321.Domain is RFC_1123.Domain, this always succeeds
    public init(_ domain: Domain) {
        // RFC 5321 uses RFC 1123 domains directly, so we can always get an RFC 1123 representation
        self = domain.rfc5321
    }
}
