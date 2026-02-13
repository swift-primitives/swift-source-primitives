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
    /// Metadata for a source file.
    ///
    /// A lightweight, copyable handle that stores the file's identity and path.
    /// The file's content lives in ``Source/Manager``, not in this struct.
    ///
    /// This follows the Clang model where `FileID` is a lightweight handle
    /// and the `SourceManager` owns buffers.
    public struct File: Sendable, Equatable {
        /// The unique identifier for this file within a ``Source/Manager``.
        public let id: File.ID

        /// The file path as provided during registration.
        public let path: Swift.String

        @inlinable
        internal init(id: File.ID, path: Swift.String) {
            self.id = id
            self.path = path
        }
    }
}
