//
//  Domain+IDNA.swift
//  swift-domain-standard
//
//  IDNA2008 (Internationalized Domain Names) support
//

import RFC_5890

/// IDNA2008 (Internationalized Domain Names) support for Domain
///
/// RFC 5890 defines IDNA2008, which enables internationalized domain names by converting
/// between Unicode (U-labels) and ASCII-compatible encoding (A-labels).
///
/// ## Category Theory: Natural Transformations
///
/// The IDNA transformations are **natural transformations** between functors:
///
/// ```
/// toASCII:   Domain (Unicode) → Domain (ASCII)
/// toUnicode: Domain (ASCII)   → Domain (Unicode)
/// ```
///
/// These are **bidirectional** (though not quite inverse due to normalization):
/// ```
/// domain.toUnicode().toASCII() ≈ domain.toASCII()
/// domain.toASCII().toUnicode() ≈ domain.toUnicode()
/// ```
///
/// ## Swift API Design: Value-Preserving Conversions
///
/// Per Swift API Design Guidelines, these are **value-preserving conversions**,
/// so we use `init` extensions rather than `to*()` methods:
///
/// ```swift
/// // OLD (imperative):
/// let ascii = try domain.toASCII()
/// let unicode = try domain.toUnicode()
///
/// // NEW (declarative):
/// let asciiDomain = try Domain(ascii: domain)
/// let unicodeDomain = try Domain(unicode: domain)
/// ```
///
/// This better expresses that we're **constructing a new Domain** from the
/// transformed representation, not mutating or querying the original.

extension Domain {
    /// Creates a Domain from ASCII representation (A-label form)
    ///
    /// This initializer converts a domain to ASCII-compatible form using IDNA2008.
    /// Internationalized labels are encoded with Punycode and prefixed with "xn--".
    ///
    /// ## Category Theory
    ///
    /// This is a natural transformation:
    /// ```
    /// Domain(Unicode) → [UInt8] (ASCII bytes) → Domain(ASCII)
    /// ```
    ///
    /// ## Example
    /// ```swift
    /// let unicodeDomain = try Domain("café.com")
    /// let asciiDomain = try Domain(ascii: unicodeDomain)
    /// print(asciiDomain.name)  // "xn--caf-dma.com"
    /// ```
    ///
    /// - Parameter domain: The domain to convert to ASCII form
    /// - Throws: `Domain.Error.idnaConversionFailure` if conversion fails
    public init(ascii domain: Domain) throws(Error) {
        do {
            let asciiString = try IDNA.toASCII(domain.name)
            try self.init(asciiString)
        } catch {
            throw Error.idnaConversionFailure(
                "Failed to convert '\(domain.name)' to ASCII: \(error)"
            )
        }
    }

    /// Creates a Domain from Unicode representation (U-label form)
    ///
    /// This initializer converts ASCII-compatible encoded domain names (A-labels)
    /// back to their Unicode representation by decoding Punycode labels.
    ///
    /// ## Category Theory
    ///
    /// This is a natural transformation:
    /// ```
    /// Domain(ASCII) → Unicode String → Domain(Unicode)
    /// ```
    ///
    /// ## Example
    /// ```swift
    /// let asciiDomain = try Domain("xn--caf-dma.com")
    /// let unicodeDomain = try Domain(unicode: asciiDomain)
    /// print(unicodeDomain.name)  // "café.com"
    /// ```
    ///
    /// - Parameter domain: The domain to convert to Unicode form
    /// - Throws: `Domain.Error.idnaConversionFailure` if conversion fails
    public init(unicode domain: Domain) throws(Error) {
        do {
            let unicodeString = try IDNA.toUnicode(domain.name)
            try self.init(unicodeString)
        } catch {
            throw Error.idnaConversionFailure(
                "Failed to convert '\(domain.name)' to Unicode: \(error)"
            )
        }
    }
}

// MARK: - IDNA Properties

extension Domain {
    /// Returns true if this domain contains internationalized (non-ASCII) labels
    ///
    /// ## Example
    /// ```swift
    /// let asciiDomain = try Domain("example.com")
    /// asciiDomain.isInternationalized  // false
    ///
    /// let unicodeDomain = try Domain("café.com")
    /// unicodeDomain.isInternationalized  // true
    /// ```
    public var isInternationalized: Bool {
        !name.allSatisfy({ $0.isASCII })
    }

    /// Returns true if this domain contains A-labels (ACE-encoded labels with "xn--" prefix)
    ///
    /// A-labels are ASCII-compatible encodings of internationalized domain labels.
    ///
    /// ## Example
    /// ```swift
    /// let encoded = try Domain("xn--caf-dma.com")
    /// encoded.hasALabels  // true
    ///
    /// let plain = try Domain("example.com")
    /// plain.hasALabels  // false
    /// ```
    public var hasALabels: Bool {
        name.split(separator: ".").contains { IDNA.isALabel(String($0)) }
    }

    /// Returns true if this domain is in pure ASCII form (no Unicode characters)
    ///
    /// Note: A domain can be ASCII without having A-labels (e.g., "example.com").
    public var isASCII: Bool {
        name.allSatisfy({ $0.isASCII })
    }
}

// MARK: - Deprecated Methods (for migration)

extension Domain {
    /// Converts this domain to ASCII form (A-label) using IDNA2008
    ///
    /// - Deprecated: Use `Domain(ascii: domain)` instead.
    ///   This better expresses the value-preserving conversion.
    ///
    /// - Returns: ASCII-compatible domain string
    /// - Throws: `Domain.Error.idnaConversionFailure` if conversion fails
    @available(*, deprecated, renamed: "init(ascii:)", message: "Use Domain(ascii:) instead")
    public func toASCII() throws -> String {
        try IDNA.toASCII(name)
    }

    /// Converts this domain to Unicode form (U-label) using IDNA2008
    ///
    /// - Deprecated: Use `Domain(unicode: domain)` instead.
    ///   This better expresses the value-preserving conversion.
    ///
    /// - Returns: Unicode domain string
    /// - Throws: `Domain.Error.idnaConversionFailure` if conversion fails
    @available(*, deprecated, renamed: "init(unicode:)", message: "Use Domain(unicode:) instead")
    public func toUnicode() throws -> String {
        try IDNA.toUnicode(name)
    }
}
