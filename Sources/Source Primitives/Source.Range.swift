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
    /// A file-qualified half-open byte range within source text.
    ///
    /// Represents the contiguous byte sequence `[start, end)` within a single
    /// source file. This is the type used to mark the extent of tokens, AST
    /// nodes, and diagnostic highlights.
    ///
    /// Half-open ranges are the universal compiler convention (swiftc, Clang,
    /// rust-analyzer, swift-syntax, tree-sitter, LSP).
    ///
    /// ## Invariant
    ///
    /// `start <= end` and both offsets refer to positions within the file
    /// identified by `file`.
    public struct Range: Sendable, Equatable, Hashable {
        /// The file this range refers to.
        public let file: Source.File.ID

        /// The inclusive start position (first byte in the range).
        public let start: Text.Position

        /// The exclusive end position (first byte after the range).
        public let end: Text.Position

        /// Creates a range from explicit start and end positions.
        ///
        /// - Parameters:
        ///   - file: The file this range refers to.
        ///   - start: The inclusive start position.
        ///   - end: The exclusive end position. Must be >= `start`.
        @inlinable
        public init(file: Source.File.ID, start: Text.Position, end: Text.Position) {
            self.file = file
            self.start = start
            self.end = end
        }

        /// Creates a range from a start position and byte count.
        ///
        /// - Parameters:
        ///   - file: The file this range refers to.
        ///   - start: The inclusive start position.
        ///   - count: The number of bytes in the range.
        @inlinable
        public init(file: Source.File.ID, start: Text.Position, count: Text.Count) {
            self.file = file
            self.start = start
            // reason: adding a non-negative cardinal to a position cannot underflow;
            // overflow is theoretically possible but not for text-sized inputs.
            // swift-format-ignore: NeverUseForceTry
            // swiftlint:disable:next force_try
            self.end = try! start + Text.Offset(count)
        }
    }
}

// MARK: - Properties

extension Source.Range {
    /// The number of bytes in this range.
    @inlinable
    public var count: Text.Count {
        // reason: start <= end invariant guarantees a non-negative, representable result.
        // swift-format-ignore: NeverUseForceTry
        // swiftlint:disable:next force_try
        try! start.distance.forward(to: end)
    }

    /// Whether this range contains zero bytes.
    @inlinable
    public var isEmpty: Bool {
        start == end
    }

    /// Whether this range contains the given position.
    @inlinable
    public func contains(_ position: Text.Position) -> Bool {
        start <= position && position < end
    }

    /// The underlying text range (without file identity).
    @inlinable
    public var textRange: Text.Range {
        Text.Range(start: start, end: end)
    }

    /// Creates a ``Source/Position`` at the start of this range.
    @inlinable
    public var startPosition: Source.Position {
        Source.Position(file: file, offset: start)
    }

    /// Creates a ``Source/Position`` at the end of this range.
    @inlinable
    public var endPosition: Source.Position {
        Source.Position(file: file, offset: end)
    }
}

// MARK: - CustomStringConvertible

extension Source.Range: CustomStringConvertible {
    /// A `file:start..<end` rendering of the range.
    @inlinable
    public var description: Swift.String {
        "\(file):\(start)..<\(end)"
    }
}
