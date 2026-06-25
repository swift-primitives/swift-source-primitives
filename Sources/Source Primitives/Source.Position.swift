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
    /// A file-qualified byte offset into source text.
    ///
    /// `Source.Position` is the compact representation stored in every token
    /// and AST node. It answers "which file, and where in that file?" using
    /// only a file ID and a byte offset — no line/column information.
    ///
    /// Line and column are resolved on demand via ``Source/Manager`` into
    /// a ``Source/Location`` value. This follows the universal compiler
    /// convention: swiftc, Clang, rust-analyzer, and swift-syntax all defer
    /// line/column resolution.
    public struct Position: Sendable, Equatable, Hashable {
        /// The file this position refers to.
        public let file: Source.File.ID

        /// The byte offset from the start of the file.
        public let offset: Text.Position

        /// Creates a position from a file identity and a byte offset.
        ///
        /// - Parameters:
        ///   - file: The file this position refers to.
        ///   - offset: The byte offset from the start of the file.
        @inlinable
        public init(file: Source.File.ID, offset: Text.Position) {
            self.file = file
            self.offset = offset
        }
    }
}

// MARK: - CustomStringConvertible

extension Source.Position: CustomStringConvertible {
    /// A `file:offset` rendering of the position.
    @inlinable
    public var description: Swift.String {
        "\(file):\(offset)"
    }
}
