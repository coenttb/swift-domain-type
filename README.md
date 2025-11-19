# swift-domain-standard

[![CI](https://github.com/coenttb/swift-domain-standard/workflows/CI/badge.svg)](https://github.com/coenttb/swift-domain-standard/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Type-safe domain name handling for Swift with multi-RFC standard support.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Architecture](#architecture)
- [Error Handling](#error-handling)
- [Related Packages](#related-packages)
- [Requirements](#requirements)
- [License](#license)
- [Contributing](#contributing)

## Overview

`swift-domain-standard` provides a unified `Domain` type that supports multiple RFC standards for domain names:

- **RFC 1035**: DNS domain names (strict DNS format)
- **RFC 1123**: Internet host names (allows leading digits)
- **RFC 5321**: SMTP domain names (most permissive, includes address literals)

The library automatically selects the most appropriate RFC format based on the input, providing a single unified API for working with domain names across different standards.

## Features

- **Multi-RFC Support**: Handles RFC 1035, 1123, and 5321 formats
- **Type Safety**: Compile-time guarantees with Swift 6.0 strict concurrency
- **Domain Operations**: Add subdomains, get parent domains, check subdomain relationships
- **Component Access**: Extract TLD, SLD, and domain labels
- **Codable Support**: Full JSON encoding/decoding
- **Protocol Conformances**: RawRepresentable, CustomStringConvertible

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-domain-standard", from: "0.1.0")
]
```

## Quick Start

### Basic Domain Creation

```swift
import Domain_Standard

// Create a domain from a string
let domain = try Domain("example.com")
print(domain.name)  // "example.com"

// Access domain components
print(domain.tld)   // Optional("com")
print(domain.sld)   // Optional("example")
```

### Working with Subdomains

```swift
// Create a subdomain
let subdomain = try domain.addingSubdomain("www")
print(subdomain.name)  // "www.example.com"

// Check subdomain relationships
let isSubdomain = subdomain.isSubdomain(of: domain)  // true

// Get parent domain
let parent = try subdomain.parent()
print(parent?.name)  // Optional("example.com")
```

### Multi-RFC Format Support

```swift
// The Domain type automatically detects which RFC formats are valid
let domain = try Domain("example.com")

// Check which formats are supported
print(domain.isStandardDomain)  // true

// Access specific RFC representations if needed
if let rfc1035 = domain.rfc1035 {
    // Use strict DNS domain
}
if let rfc1123 = domain.rfc1123 {
    // Use internet host name
}
// RFC 5321 format is always available
print(domain.rfc5321.name)
```

## Usage Examples

### Initializing Domains

```swift
// From string
let domain1 = try Domain("example.com")

// From labels array
let domain2 = try Domain(labels: ["www", "example", "com"])

// From specific RFC format
let rfc1035Domain = try RFC_1035.Domain("example.com")
let domain3 = try Domain(rfc1035: rfc1035Domain)
```

### Domain Operations

```swift
let domain = try Domain("example.com")

// Add multiple subdomain levels
let deepSubdomain = try domain.addingSubdomain("api", "v1")
print(deepSubdomain.name)  // "api.v1.example.com"

// Walk up the domain hierarchy
var current: Domain? = deepSubdomain
while let domain = current {
    print(domain.name)
    current = try? domain.parent()
}
// Prints:
// api.v1.example.com
// v1.example.com
// example.com
// com
```

### Subdomain Checking

```swift
let root = try Domain("example.com")
let sub1 = try Domain("www.example.com")
let sub2 = try Domain("api.example.com")
let other = try Domain("other.com")

print(sub1.isSubdomain(of: root))   // true
print(sub2.isSubdomain(of: root))   // true
print(other.isSubdomain(of: root))  // false
print(root.isSubdomain(of: sub1))   // false
```

### Codable Support

```swift
struct Config: Codable {
    let domain: Domain
}

// Encoding
let config = Config(domain: try Domain("example.com"))
let jsonData = try JSONEncoder().encode(config)

// Decoding
let decoded = try JSONDecoder().decode(Config.self, from: jsonData)
print(decoded.domain.name)  // "example.com"
```

### RawRepresentable

```swift
let domain = try Domain("example.com")

// Get raw value
let rawValue = domain.rawValue  // "example.com"

// Initialize from raw value
let reconstructed = Domain(rawValue: "example.com")
print(reconstructed?.name)  // Optional("example.com")
```

## Architecture

### RFC Standards

The package uses three underlying RFC implementations:

- **RFC 1035** (`swift-rfc-1035`): DNS domain names
  - Strictest format
  - Labels cannot start with digits
  - Used for traditional DNS domains

- **RFC 1123** (`swift-rfc-1123`): Internet host names
  - Allows labels to start with digits
  - More permissive than RFC 1035
  - Standard for internet hostnames

- **RFC 5321** (`swift-rfc-5321`): SMTP domain names
  - Most permissive format
  - Supports address literals (IP addresses in brackets)
  - Always available as fallback

### Domain Type

The `Domain` type wraps all three formats:

```swift
public struct Domain {
    let rfc1035: RFC_1035.Domain?    // Optional (strictest)
    let rfc1123: RFC_1123.Domain?    // Optional
    let rfc5321: RFC_5321.Domain     // Always present (most permissive)
}
```

When you create a `Domain`, it attempts to validate against all three standards and stores the results. This allows the library to provide the most appropriate behavior based on which standards the domain name conforms to.

## Error Handling

```swift
// DomainError enum provides detailed error information
do {
    let domain = try Domain("invalid domain with spaces")
} catch let error as Domain.DomainError {
    print(error.localizedDescription)
}

// Error cases:
// - cannotCreateSubdomain: Cannot add subdomains to IP address literals
// - conversionFailure: Failed to convert between RFC formats
// - invalidFormat: Domain string doesn't match any RFC format
```

## Related Packages

### Used By

- [swift-emailaddress-standard](https://github.com/coenttb/swift-emailaddress-standard): A Swift package with a type-safe EmailAddress model.
- [swift-types-foundation](https://github.com/coenttb/swift-types-foundation): A Swift package bundling essential type-safe packages for domain modeling.
- [swift-web-foundation](https://github.com/coenttb/swift-web-foundation): A Swift package with tools to simplify web development.

## Requirements

- Swift 6.0+
- macOS 13.0+ / iOS 16.0+

## License

This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.
