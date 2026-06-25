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

extension Source.File {
    /// Opaque handle identifying a source file within a ``Source/Manager``.
    ///
    /// File IDs are sequential integers assigned by the manager during
    /// registration. They are the array index into the manager's internal storage.
    ///
    /// The raw value is internal — only ``Source/Manager`` creates IDs.
    /// File IDs do not support arithmetic; they are pure identity handles.
    ///
    /// This follows the universal compiler pattern: swiftc's `BufferID` and
    /// Clang's `FileID` are both lightweight integer handles.
    public struct ID: Sendable, Equatable, Hashable, Comparable {
        @usableFromInline
        internal let underlying: Int

        @inlinable
        internal init(_ underlying: Int) {
            self.underlying = underlying
        }

        /// Orders two file IDs by their registration sequence.
        @inlinable
        public static func < (lhs: Source.File.ID, rhs: Source.File.ID) -> Bool {
            lhs.underlying < rhs.underlying
        }
    }
}

// MARK: - CustomStringConvertible

extension Source.File.ID: CustomStringConvertible {
    /// A `file(n)` rendering of the file ID, where `n` is the registration index.
    @inlinable
    public var description: Swift.String {
        "file(\(underlying))"
    }
}
