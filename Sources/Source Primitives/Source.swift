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

/// Namespace for source file abstractions.
///
/// `Source` provides the types needed to track positions, ranges, and file
/// identity within source code. These are the building blocks used by
/// lexers, parsers, and diagnostic systems.
///
/// ## Types
///
/// - ``Source/File``: Metadata for a source file (ID + path).
/// - ``Source/File/ID``: Opaque handle identifying a file within a ``Source/Manager``.
/// - ``Source/Location``: A file-qualified byte offset.
/// - ``Source/Location/Resolved``: A file-qualified line:column position.
/// - ``Source/Range``: A file-qualified half-open byte range.
/// - ``Source/Manager``: Central registry of source files, content, and line maps.
/// - ``Source/Manager/LineMap``: Sorted array of line-start offsets for O(log L) line resolution.
public enum Source {}
