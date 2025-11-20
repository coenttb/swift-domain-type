//
//  Domain+RFC.swift
//  swift-domain-standard
//
//  RFC standard interoperability extensions
//

import RFC_1035
import RFC_1123

// MARK: - RFC_1035.Domain Extensions

extension RFC_1035.Domain {
    /// Creates an RFC 1035 domain from a Domain
    ///
    /// This conversion only succeeds if the domain conforms to RFC 1035 rules.
    ///
    /// - Parameter domain: The domain to convert
    /// - Throws: If the domain doesn't conform to RFC 1035
    public init(_ domain: Domain) throws(RFC_1035.Domain.Error) {
        if let rfc1035 = domain.rfc1035 {
            self = rfc1035
        } else {
            // Try to parse as RFC 1035
            try self.init(domain.name)
        }
    }
}

// MARK: - RFC_1123.Domain Extensions

extension RFC_1123.Domain {
    /// Creates an RFC 1123 domain from a Domain
    ///
    /// This conversion always succeeds since all domains stored in
    /// Domain conform to at least RFC 1123.
    ///
    /// - Parameter domain: The domain to convert
    public init(_ domain: Domain) {
        self = domain.rfc1123
    }
}
