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

extension Source.Manager {
    /// A sorted array of line-start byte offsets for O(log L) line resolution.
    ///
    /// Built by scanning source text for line endings (LF, CR, CRLF).
    /// Entry `i` is the byte offset of the first byte of line `i + 1`.
    /// Line numbering is 1-based: line 1 always starts at offset 0.
    ///
    /// This is the universal line map structure used by swiftc, Clang,
    /// rust-analyzer, and swift-syntax.
    public struct LineMap: Sendable {
        /// Sorted line-start byte offsets. Index 0 is always `Text.Position(0)` (line 1).
        @usableFromInline
        internal let lineStarts: [Text.Position]

        /// The total number of lines.
        @inlinable
        public var lineCount: Int {
            lineStarts.count
        }
    }
}

// MARK: - Construction

extension Source.Manager.LineMap {
    /// Builds a line map by scanning UTF-8 bytes for line endings.
    ///
    /// Recognizes three line ending forms:
    /// - LF (`\n`, 0x0A)
    /// - CR (`\r`, 0x0D)
    /// - CRLF (`\r\n`, 0x0D 0x0A) — counted as a single line ending
    ///
    /// - Parameter content: The UTF-8 source text bytes.
    @inlinable
    public init(scanning content: [UInt8]) {
        var starts: [Text.Position] = [.zero]
        var index = 0
        let count = content.count
        while index < count {
            let byte = content[index]
            if byte == 0x0A {
                // LF
                starts.append(Text.Position(index + 1))
            } else if byte == 0x0D {
                // CR or CRLF
                if index + 1 < count && content[index + 1] == 0x0A {
                    // CRLF — skip the LF
                    index += 1
                }
                starts.append(Text.Position(index + 1))
            }
            index += 1
        }
        self.lineStarts = starts
    }
}

// MARK: - Line Resolution

extension Source.Manager.LineMap {
    /// Returns the 1-based line number containing the given byte offset.
    ///
    /// Uses binary search for O(log L) resolution where L is the line count.
    ///
    /// - Parameter offset: A byte offset into the text.
    /// - Returns: The 1-based line number.
    @inlinable
    public func line(containing offset: Text.Position) -> Int {
        // Binary search for the last lineStart <= offset.
        var low = 0
        var high = lineStarts.count
        while low < high {
            let mid = low + (high - low) / 2
            if lineStarts[mid] <= offset {
                low = mid + 1
            } else {
                high = mid
            }
        }
        // `low` is the index of the first lineStart > offset.
        // The line number is `low` (1-based).
        return low
    }

    /// Returns the 1-based column (UTF-8 byte offset within the line) for a byte offset.
    ///
    /// - Parameter offset: A byte offset into the text.
    /// - Returns: The 1-based column number.
    @inlinable
    public func column(for offset: Text.Position) -> Int {
        let lineIndex = line(containing: offset) - 1
        let lineStart = lineStarts[lineIndex]
        return Int(offset - lineStart) + 1
    }

    /// Returns the byte offset of the start of the given 1-based line number.
    ///
    /// - Parameter line: A 1-based line number.
    /// - Returns: The byte offset of the first byte of that line, or `nil` if out of range.
    @inlinable
    public func offset(forLine line: Int) -> Text.Position? {
        let index = line - 1
        guard index >= 0, index < lineStarts.count else { return nil }
        return lineStarts[index]
    }
}
