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

public import Byte_Primitives

extension Source {
    /// Central registry of source files, content, and line maps.
    ///
    /// `Source.Manager` is the single owner of all source file content within
    /// a compilation. It assigns ``Source/File/ID`` values, stores content as
    /// `[Byte]`, and provides lazy line/column resolution.
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
    /// ## Ownership
    ///
    /// `~Copyable` — a single owner per compilation. The `Source.Manager` IS
    /// the registry of all source content and line maps; allowing copies
    /// would split file ID assignment (each copy would assign IDs sequentially
    /// against its own count) and yield divergent line resolution for the
    /// same `Source.Position`. The `~Copyable` shape compiler-enforces the
    /// single-owner invariant that swiftc and Clang's `SourceManager` express
    /// in their respective worlds. The retained-for-the-run `contents`
    /// storage (proportional to total source-tree size) also rules out
    /// accidental whole-tree copies as a cost class.
    ///
    /// Mutating operations (`register`, `lineMap(for:)`, `location(for:)`) take
    /// `inout` access at call sites; non-mutating reads (`fileCount`,
    /// `file(for:)`, `content(for:)`) are `borrowing func`. Engines thread
    /// a single `var manager` through the run via `inout` parameters.
    ///
    /// ## Concurrency
    ///
    /// `Sendable` as a value type. Not internally synchronized. For concurrent
    /// access, wrap in an actor or `Mutex`.
    public struct Manager: ~Copyable, Sendable {
        @usableFromInline
        internal var files: [Source.File]

        @usableFromInline
        internal var contents: [[Byte]]

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
        content: [Byte]
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
    public borrowing func fileCount() -> Int {
        files.count
    }

    /// Returns the file metadata for the given ID.
    ///
    /// - Parameter id: A file ID previously returned by ``register(fileID:filePath:content:)``.
    /// - Returns: The file metadata.
    @inlinable
    public borrowing func file(for id: Source.File.ID) -> Source.File {
        files[id.underlying]
    }

    /// Returns the content bytes for the given file ID.
    ///
    /// - Parameter id: A file ID previously returned by ``register(fileID:filePath:content:)``.
    /// - Returns: The UTF-8 content bytes.
    @inlinable
    public borrowing func content(for id: Source.File.ID) -> [Byte] {
        contents[id.underlying]
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
        if let existing = lineMaps[id.underlying] {
            return existing
        }
        let map = Text.Line.Map(scanning: contents[id.underlying])
        lineMaps[id.underlying] = map
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
