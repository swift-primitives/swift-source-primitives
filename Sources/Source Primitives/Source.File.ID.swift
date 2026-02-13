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
        internal let rawValue: Int

        @inlinable
        internal init(_ rawValue: Int) {
            self.rawValue = rawValue
        }

        @inlinable
        public static func < (lhs: Source.File.ID, rhs: Source.File.ID) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

// MARK: - CustomStringConvertible

extension Source.File.ID: CustomStringConvertible {
    @inlinable
    public var description: Swift.String {
        "file(\(rawValue))"
    }
}
