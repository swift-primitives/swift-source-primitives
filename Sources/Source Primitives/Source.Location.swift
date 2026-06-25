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

        /// The file system path, if available.
        ///
        /// Matches Swift's `#filePath`.
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
                column: Text.Line.Column(_unchecked: Cardinal(UInt(column)))
            )
        }

        /// Creates a location from a typed ``Text/Line/Number`` and a
        /// 1-based integer column.
        ///
        /// Use this overload when propagating a typed line value (e.g., from
        /// ``Source/Location/line`` on another location, or directly from
        /// ``Text/Location/line``) without an intermediate `Int` round-trip.
        ///
        /// - Parameters:
        ///   - fileID: The `#fileID`-style module/file identifier.
        ///   - filePath: The optional file system path.
        ///   - line: The typed 1-based line number.
        ///   - column: The 1-based column number.
        @inlinable
        public init(
            fileID: Swift.String,
            filePath: Swift.String? = nil,
            line: Text.Line.Number,
            column: Int
        ) {
            self.fileID = fileID
            self.filePath = filePath
            self.position = Text.Location(
                line: line,
                column: Text.Line.Column(_unchecked: Cardinal(UInt(column)))
            )
        }

        /// Creates a location from a typed ``Text/Line/Number`` and a
        /// typed ``Text/Line/Column``.
        ///
        /// Use this overload when propagating both typed line and column
        /// values without intermediate `Int` round-trips. Mirrors the
        /// Wave 1A typed-`line` shape: propagate typed columns end-to-end
        /// (e.g., from ``Source/Location/column`` on another location, or
        /// directly from ``Text/Location/column``) without re-narrowing to
        /// `Int` and re-widening.
        ///
        /// - Parameters:
        ///   - fileID: The `#fileID`-style module/file identifier.
        ///   - filePath: The optional file system path.
        ///   - line: The typed 1-based line number.
        ///   - column: The typed 1-based column offset (UTF-8 bytes).
        @inlinable
        public init(
            fileID: Swift.String,
            filePath: Swift.String? = nil,
            line: Text.Line.Number,
            column: Text.Line.Column
        ) {
            self.fileID = fileID
            self.filePath = filePath
            self.position = Text.Location(line: line, column: column)
        }
    }
}

// MARK: - Convenience Accessors

extension Source.Location {
    /// The 1-based line number.
    ///
    /// Returns the typed ``Text/Line/Number`` directly from the
    /// underlying ``position``. Consumers needing a raw `Int` for
    /// stdlib API (e.g., `JSON(integerLiteral:)`, arithmetic with
    /// existing `Int`-typed offsets) MUST call `.underlying` at the
    /// boundary; consumers propagating the typed value into another
    /// ``Source/Location`` MAY pass it directly via the
    /// ``init(fileID:filePath:line:column:)-(_,_,Text.Line.Number,_)``
    /// overload.
    @inlinable
    public var line: Text.Line.Number {
        position.line
    }

    /// The 1-based column offset, measured in UTF-8 bytes.
    ///
    /// Returns the typed ``Text/Line/Column`` directly from the
    /// underlying ``position``. Consumers needing a raw `Int` for
    /// stdlib API (e.g., `JSON(integerLiteral:)`, arithmetic with
    /// existing `Int`-typed offsets, the SwiftSyntax
    /// `SourceLocationConverter.position(ofLine:column:)` boundary)
    /// MUST call `Int(bitPattern: location.column)` at the boundary
    /// (via the `Int.init<Tag>(bitPattern: Tagged<Tag, Cardinal>)`
    /// overload in `Cardinal Primitives`); consumers propagating the
    /// typed value into another ``Source/Location`` MAY pass it
    /// directly via the
    /// ``init(fileID:filePath:line:column:)-(_,_,Text.Line.Number,Text.Line.Column)``
    /// overload.
    @inlinable
    public var column: Text.Line.Column {
        position.column
    }
}

// MARK: - Comparable

extension Source.Location: Comparable {
    /// Orders locations by file identity first, then by line:column within the file.
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.fileID != rhs.fileID { return lhs.fileID < rhs.fileID }
        return lhs.position < rhs.position
    }
}

// MARK: - Codable

// The `Codable` conformance below realizes the stdlib `Decodable`/`Encodable`
// requirements, whose signatures mandate existential decoder/encoder parameters
// and untyped `throws`. Neither can be narrowed at the conformance site, so the
// two rules are disabled for this block only.
// swiftlint:disable no_any_protocol_existential typed_throws_required
extension Source.Location: Codable {
    @usableFromInline
    internal enum CodingKeys: Swift.String, CodingKey {
        case fileID
        case filePath
        case line
        case column
    }

    /// Decodes a location from its keyed `fileID`, `filePath`, `line`, and `column` representation.
    @inlinable
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileID = try container.decode(Swift.String.self, forKey: .fileID)
        self.filePath = try container.decodeIfPresent(Swift.String.self, forKey: .filePath)
        let line = try container.decode(UInt.self, forKey: .line)
        let column = try container.decode(UInt.self, forKey: .column)
        self.position = Text.Location(
            line: Text.Line.Number(line),
            column: Text.Line.Column(_unchecked: Cardinal(column))
        )
    }

    /// Encodes the location as keyed `fileID`, `filePath`, `line`, and `column` values.
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileID, forKey: .fileID)
        try container.encodeIfPresent(filePath, forKey: .filePath)
        try container.encode(position.line.underlying, forKey: .line)
        try container.encode(position.column.underlying.rawValue, forKey: .column)
    }
}
// swiftlint:enable no_any_protocol_existential typed_throws_required

// MARK: - CustomStringConvertible

extension Source.Location: CustomStringConvertible {
    /// A `fileID:line:column` rendering of the location.
    @inlinable
    public var description: Swift.String {
        "\(fileID):\(position.line):\(position.column)"
    }
}
