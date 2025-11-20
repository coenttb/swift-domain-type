//
//  Domain+RFC5890.swift
//  swift-domain-standard
//
//  Created by Coen ten Thije Boonkkamp on 20/11/2025.
//

import RFC_5890

/// IDNA2008 (Internationalized Domain Names) support for Domain
///
/// RFC 5890 defines IDNA2008, which enables internationalized domain names by converting
/// between Unicode (U-labels) and ASCII-compatible encoding (A-labels).
///
/// ## Example
///
/// ```swift
/// // Convert Unicode domain to ASCII
/// let domain = try Domain("münchen.de")
/// let ascii = try domain.toASCII()  // "xn--mnchen-3ya.de"
///
/// // Convert ASCII back to Unicode
/// let asciiDomain = try Domain("xn--mnchen-3ya.de")
/// let unicode = try asciiDomain.toUnicode()  // "münchen.de"
/// ```
extension Domain {
    /// Converts this domain to ASCII form (A-label) using IDNA2008
    ///
    /// This operation converts internationalized domain names to ASCII-compatible form
    /// by encoding non-ASCII labels with Punycode and adding the "xn--" prefix.
    ///
    /// - Returns: ASCII-compatible domain name
    /// - Throws: `IDNA.Error` if conversion fails
    ///
    /// ## Example
    /// ```swift
    /// let domain = try Domain("café.com")
    /// let ascii = try domain.toASCII()  // "xn--caf-dma.com"
    /// ```
    public func toASCII() throws -> String {
        try IDNA.toASCII(name)
    }

    /// Converts this domain to Unicode form (U-label) using IDNA2008
    ///
    /// This operation converts ASCII-compatible encoded domain names (A-labels)
    /// back to their Unicode representation by decoding Punycode labels.
    ///
    /// - Returns: Unicode domain name
    /// - Throws: `IDNA.Error` if conversion fails
    ///
    /// ## Example
    /// ```swift
    /// let domain = try Domain("xn--caf-dma.com")
    /// let unicode = try domain.toUnicode()  // "café.com"
    /// ```
    public func toUnicode() throws -> String {
        try IDNA.toUnicode(name)
    }

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
}
