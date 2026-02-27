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
    /// Central registry of source files, content, and line maps.
    ///
    /// `Source.Manager` is the single owner of all source file content within
    /// a compilation. It assigns ``Source/File/ID`` values, stores content as
    /// `[UInt8]`, and provides lazy line/column resolution.
    ///
    /// ## Design
    ///
    /// Array-backed: ``Source/File/ID`` is the array index. Files are registered
    /// sequentially and never removed (consistent with swiftc and Clang).
    ///
    /// Line maps are computed lazily on first resolution request per file.
    ///
    /// ## Layer Boundary
    ///
    /// `Source.Manager` does NOT perform file I/O. Loading files from disk is
    /// the responsibility of `Source.Loader` in swift-source (foundations).
    /// The manager accepts pre-loaded content.
    ///
    /// ## Concurrency
    ///
    /// `Sendable` as a value type. Not internally synchronized. For concurrent
    /// access, wrap in an actor or `Mutex`.
    public struct Manager: Sendable {
        @usableFromInline
        internal var files: [Source.File]

        @usableFromInline
        internal var contents: [[UInt8]]

        @usableFromInline
        internal var lineMaps: [Text.Line.Map?]

        /// Creates an empty source manager.
        @inlinable
        public init() {
            self.files = []
            self.contents = []
            self.lineMaps = []
        }
    }
}

// MARK: - Registration

extension Source.Manager {
    /// Registers a source file with its content.
    ///
    /// - Parameters:
    ///   - fileID: The `#fileID`-style module/file identifier.
    ///   - filePath: The file system path (for display in diagnostics).
    ///   - content: The UTF-8 bytes of the file.
    /// - Returns: The assigned ``Source/File/ID``.
    @inlinable
    @discardableResult
    public mutating func register(
        fileID: Swift.String,
        filePath: Swift.String,
        content: [UInt8]
    ) -> Source.File.ID {
        let id = Source.File.ID(files.count)
        let file = Source.File(id: id, fileID: fileID, filePath: filePath)
        files.append(file)
        contents.append(content)
        lineMaps.append(nil)
        return id
    }
}

// MARK: - Access

extension Source.Manager {
    /// The number of registered source files.
    @inlinable
    public var fileCount: Int {
        files.count
    }

    /// Returns the file metadata for the given ID.
    ///
    /// - Parameter id: A file ID previously returned by ``register(fileID:filePath:content:)``.
    /// - Returns: The file metadata.
    @inlinable
    public func file(for id: Source.File.ID) -> Source.File {
        files[id.rawValue]
    }

    /// Returns the content bytes for the given file ID.
    ///
    /// - Parameter id: A file ID previously returned by ``register(fileID:filePath:content:)``.
    /// - Returns: The UTF-8 content bytes.
    @inlinable
    public func content(for id: Source.File.ID) -> [UInt8] {
        contents[id.rawValue]
    }
}

// MARK: - Line Resolution

extension Source.Manager {
    /// Returns the line map for a file, computing it lazily if needed.
    ///
    /// - Parameter id: A file ID.
    /// - Returns: The line map for that file.
    @inlinable
    public mutating func lineMap(for id: Source.File.ID) -> Text.Line.Map {
        if let existing = lineMaps[id.rawValue] {
            return existing
        }
        let map = Text.Line.Map(scanning: contents[id.rawValue])
        lineMaps[id.rawValue] = map
        return map
    }

    /// Resolves a ``Source/Position`` to a ``Source/Location`` with line, column,
    /// and file identity strings.
    ///
    /// Computes the line map lazily on first call per file.
    ///
    /// - Parameter position: A compact source position (file + offset).
    /// - Returns: A self-contained location with file identity and line:column.
    @inlinable
    public mutating func location(
        for position: Source.Position
    ) -> Source.Location {
        let file = file(for: position.file)
        let map = lineMap(for: position.file)
        let textLocation = map.location(for: position.offset)
        return Source.Location(
            fileID: file.fileID,
            filePath: file.filePath,
            position: textLocation
        )
    }
}
