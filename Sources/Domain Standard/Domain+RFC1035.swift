import RFC_1035

extension Domain {
    // Forward conversion already exists in Domain.swift
    // public init(rfc1035: RFC_1035.Domain) throws
}

extension RFC_1035.Domain {
    /// Initialize from Domain
    ///
    /// Enables round-trip conversion between Domain and RFC_1035.Domain.
    ///
    /// - Parameter domain: The Domain to convert
    /// - Throws: If the Domain doesn't have a valid RFC 1035 representation
    public init(_ domain: Domain) throws {
        guard let rfc1035 = domain.rfc1035 else {
            throw Domain.DomainError.conversionFailure
        }
        self = rfc1035
    }
}
