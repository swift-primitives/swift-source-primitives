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

extension Source.Location {
    /// A fully-resolved source location with line and column information.
    ///
    /// Unlike ``Source/Location``, which stores only a byte offset, `Resolved`
    /// includes the line number and column. This is the expensive representation
    /// produced by ``Source/Manager`` for diagnostics and error messages.
    ///
    /// - Line numbers are 1-based (first line is line 1).
    /// - Column numbers are 1-based UTF-8 byte offsets within the line.
    public struct Resolved: Sendable, Equatable {
        /// The file this location refers to.
        public let file: Source.File.ID

        /// The 1-based line number.
        public let line: Int

        /// The 1-based column number (UTF-8 byte offset within the line).
        public let column: Int

        /// The byte offset from the start of the file.
        public let offset: Text.Position

        @inlinable
        public init(
            file: Source.File.ID,
            line: Int,
            column: Int,
            offset: Text.Position
        ) {
            self.file = file
            self.line = line
            self.column = column
            self.offset = offset
        }
    }
}

// MARK: - CustomStringConvertible

extension Source.Location.Resolved: CustomStringConvertible {
    @inlinable
    public var description: Swift.String {
        "\(file):\(line):\(column)"
    }
}
