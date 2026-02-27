// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-source-primitives open source project
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp and the swift-source-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Source {
    /// A self-contained, human-readable source location.
    ///
    /// `Source.Location` is the display-oriented representation that includes
    /// a file identifier string, an optional file path, and a ``Text/Location``
    /// (line and column). It is fully self-contained — no manager or handle
    /// required for display.
    ///
    /// This is the type used by diagnostic messages, test frameworks, and
    /// any context where a location must be presented to a human. It composes
    /// ``Text/Location`` for the line:column substructure.
    ///
    /// ## Design
    ///
    /// `Source.Location ≅ FileIdentity × Text.Location`
    ///
    /// The `fileID` string matches Swift's `#fileID` (e.g., `"MyModule/File.swift"`).
    /// The optional `filePath` matches `#filePath` for display when available.
    public struct Location: Sendable, Hashable {
        /// The Swift `#fileID` identifying the source module and file.
        public let fileID: Swift.String

        /// The file system path, if available. Matches Swift's `#filePath`.
        public let filePath: Swift.String?

        /// The line and column within the file.
        public let position: Text.Location

        /// Creates a location from explicit components.
        ///
        /// - Parameters:
        ///   - fileID: The `#fileID`-style module/file identifier.
        ///   - filePath: The optional file system path.
        ///   - position: The line:column position within the file.
        @inlinable
        public init(
            fileID: Swift.String,
            filePath: Swift.String? = nil,
            position: Text.Location
        ) {
            self.fileID = fileID
            self.filePath = filePath
            self.position = position
        }

        /// Creates a location from file identity and integer line/column values.
        ///
        /// This convenience initializer accepts `Int` parameters matching the
        /// types produced by Swift's `#line` and `#column` literals.
        ///
        /// - Parameters:
        ///   - fileID: The `#fileID`-style module/file identifier.
        ///   - filePath: The optional file system path.
        ///   - line: The 1-based line number.
        ///   - column: The 1-based column number.
        @inlinable
        public init(
            fileID: Swift.String,
            filePath: Swift.String? = nil,
            line: Int,
            column: Int
        ) {
            self.fileID = fileID
            self.filePath = filePath
            self.position = Text.Location(
                line: Text.Line.Number(UInt(line)),
                column: Text.Line.Column(__unchecked: (), Cardinal(UInt(column)))
            )
        }
    }
}

// MARK: - Convenience Accessors

extension Source.Location {
    /// The 1-based line number.
    @inlinable
    public var line: Int {
        Int(position.line.rawValue)
    }

    /// The 1-based column number.
    @inlinable
    public var column: Int {
        Int(bitPattern: position.column.rawValue.rawValue)
    }
}

// MARK: - Comparable

extension Source.Location: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.fileID != rhs.fileID { return lhs.fileID < rhs.fileID }
        return lhs.position < rhs.position
    }
}

// MARK: - Codable

extension Source.Location: Codable {
    @usableFromInline
    internal enum CodingKeys: Swift.String, CodingKey {
        case fileID
        case filePath
        case line
        case column
    }

    @inlinable
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileID = try container.decode(Swift.String.self, forKey: .fileID)
        self.filePath = try container.decodeIfPresent(Swift.String.self, forKey: .filePath)
        let line = try container.decode(UInt.self, forKey: .line)
        let column = try container.decode(UInt.self, forKey: .column)
        self.position = Text.Location(
            line: Text.Line.Number(line),
            column: Text.Line.Column(__unchecked: (), Cardinal(column))
        )
    }

    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileID, forKey: .fileID)
        try container.encodeIfPresent(filePath, forKey: .filePath)
        try container.encode(position.line.rawValue, forKey: .line)
        try container.encode(position.column.rawValue.rawValue, forKey: .column)
    }
}

// MARK: - CustomStringConvertible

extension Source.Location: CustomStringConvertible {
    @inlinable
    public var description: Swift.String {
        "\(fileID):\(position.line):\(position.column)"
    }
}
