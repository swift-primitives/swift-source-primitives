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

import Testing
@testable import Source_Primitives
import Source_Primitives_Test_Support

// MARK: - Source.File.ID

@Suite("Source.File.ID")
struct FileIDTests {
    @Test("equatable")
    func equatable() {
        let a = Source.File.ID(0)
        let b = Source.File.ID(0)
        let c = Source.File.ID(1)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("comparable")
    func comparable() {
        let a = Source.File.ID(0)
        let b = Source.File.ID(1)
        #expect(a < b)
    }

    @Test("hashable")
    func hashable() {
        var set: Set<Source.File.ID> = [Source.File.ID(0), Source.File.ID(0)]
        #expect(set.count == 1)
        set.insert(Source.File.ID(1))
        #expect(set.count == 2)
    }

    @Test("description")
    func description() {
        #expect(Source.File.ID(3).description == "file(3)")
    }
}

// MARK: - Source.File

@Suite("Source.File")
struct FileTests {
    @Test("stores id and path")
    func storesIdAndPath() {
        let file = Source.File(id: Source.File.ID(0), path: "main.swift")
        #expect(file.id == Source.File.ID(0))
        #expect(file.path == "main.swift")
    }

    @Test("equatable")
    func equatable() {
        let a = Source.File(id: Source.File.ID(0), path: "main.swift")
        let b = Source.File(id: Source.File.ID(0), path: "main.swift")
        let c = Source.File(id: Source.File.ID(1), path: "lib.swift")
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Source.Location

@Suite("Source.Location")
struct LocationTests {
    @Test("stores file and offset")
    func storesFileAndOffset() {
        let loc = Source.Location(file: Source.File.ID(0), offset: Text.Position(42))
        #expect(loc.file == Source.File.ID(0))
        #expect(loc.offset == Text.Position(42))
    }

    @Test("equatable")
    func equatable() {
        let a = Source.Location(file: Source.File.ID(0), offset: Text.Position(10))
        let b = Source.Location(file: Source.File.ID(0), offset: Text.Position(10))
        let c = Source.Location(file: Source.File.ID(0), offset: Text.Position(20))
        let d = Source.Location(file: Source.File.ID(1), offset: Text.Position(10))
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test("hashable")
    func hashable() {
        let a = Source.Location(file: Source.File.ID(0), offset: Text.Position(10))
        let b = Source.Location(file: Source.File.ID(0), offset: Text.Position(10))
        var set: Set<Source.Location> = [a, b]
        #expect(set.count == 1)
    }
}

// MARK: - Source.Location.Resolved

@Suite("Source.Location.Resolved")
struct ResolvedLocationTests {
    @Test("stores all fields")
    func storesAllFields() {
        let resolved = Source.Location.Resolved(
            file: Source.File.ID(0),
            line: 5,
            column: 12,
            offset: Text.Position(100)
        )
        #expect(resolved.file == Source.File.ID(0))
        #expect(resolved.line == 5)
        #expect(resolved.column == 12)
        #expect(resolved.offset == Text.Position(100))
    }

    @Test("description")
    func description() {
        let resolved = Source.Location.Resolved(
            file: Source.File.ID(2),
            line: 10,
            column: 5,
            offset: Text.Position(200)
        )
        #expect(resolved.description == "file(2):10:5")
    }
}

// MARK: - Source.Range

@Suite("Source.Range")
struct RangeTests {
    @Test("init from start and end")
    func initStartEnd() {
        let range = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            end: Text.Position(20)
        )
        #expect(range.file == Source.File.ID(0))
        #expect(range.start == Text.Position(10))
        #expect(range.end == Text.Position(20))
    }

    @Test("init from start and count")
    func initStartCount() {
        let range = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            count: Text.Count(15)
        )
        #expect(range.end == Text.Position(25))
    }

    @Test("count")
    func count() {
        let range = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            end: Text.Position(25)
        )
        #expect(range.count == 15)
    }

    @Test("isEmpty")
    func isEmpty() {
        let empty = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            end: Text.Position(10)
        )
        let nonEmpty = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            end: Text.Position(11)
        )
        #expect(empty.isEmpty)
        #expect(!nonEmpty.isEmpty)
    }

    @Test("contains")
    func contains() {
        let range = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            end: Text.Position(20)
        )
        #expect(range.contains(Text.Position(10)))
        #expect(range.contains(Text.Position(15)))
        #expect(!range.contains(Text.Position(20)))
        #expect(!range.contains(Text.Position(9)))
    }

    @Test("textRange")
    func textRange() {
        let range = Source.Range(
            file: Source.File.ID(0),
            start: Text.Position(10),
            end: Text.Position(20)
        )
        let tr = range.textRange
        #expect(tr.start == Text.Position(10))
        #expect(tr.end == Text.Position(20))
    }

    @Test("startLocation and endLocation")
    func locationAccessors() {
        let range = Source.Range(
            file: Source.File.ID(3),
            start: Text.Position(10),
            end: Text.Position(20)
        )
        #expect(range.startLocation.file == Source.File.ID(3))
        #expect(range.startLocation.offset == Text.Position(10))
        #expect(range.endLocation.offset == Text.Position(20))
    }
}

// MARK: - Source.Manager.LineMap

@Suite("Source.Manager.LineMap")
struct LineMapTests {
    @Test("empty content has one line")
    func emptyContent() {
        let map = Source.Manager.LineMap(scanning: [])
        #expect(map.lineCount == 1)
    }

    @Test("single line without newline")
    func singleLine() {
        let content: [UInt8] = Array("hello".utf8)
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.lineCount == 1)
        #expect(map.line(containing: Text.Position(0)) == 1)
        #expect(map.line(containing: Text.Position(4)) == 1)
    }

    @Test("LF line endings")
    func lfLineEndings() {
        // "line1\nline2\nline3"
        let content: [UInt8] = Array("line1\nline2\nline3".utf8)
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.lineCount == 3)
        #expect(map.line(containing: Text.Position(0)) == 1)
        #expect(map.line(containing: Text.Position(5)) == 1)
        #expect(map.line(containing: Text.Position(6)) == 2)
        #expect(map.line(containing: Text.Position(12)) == 3)
    }

    @Test("CR line endings")
    func crLineEndings() {
        // "a\rb\rc"
        let content: [UInt8] = [0x61, 0x0D, 0x62, 0x0D, 0x63]
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.lineCount == 3)
        #expect(map.line(containing: Text.Position(0)) == 1)
        #expect(map.line(containing: Text.Position(2)) == 2)
        #expect(map.line(containing: Text.Position(4)) == 3)
    }

    @Test("CRLF line endings")
    func crlfLineEndings() {
        // "a\r\nb\r\nc"
        let content: [UInt8] = [0x61, 0x0D, 0x0A, 0x62, 0x0D, 0x0A, 0x63]
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.lineCount == 3)
        #expect(map.line(containing: Text.Position(0)) == 1)
        #expect(map.line(containing: Text.Position(3)) == 2)
        #expect(map.line(containing: Text.Position(6)) == 3)
    }

    @Test("mixed line endings")
    func mixedLineEndings() {
        // "a\nb\rc\r\nd"
        let content: [UInt8] = [0x61, 0x0A, 0x62, 0x0D, 0x63, 0x0D, 0x0A, 0x64]
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.lineCount == 4)
        #expect(map.line(containing: Text.Position(0)) == 1)
        #expect(map.line(containing: Text.Position(2)) == 2)
        #expect(map.line(containing: Text.Position(4)) == 3)
        #expect(map.line(containing: Text.Position(7)) == 4)
    }

    @Test("column computation")
    func column() {
        // "hello\nworld"
        let content: [UInt8] = Array("hello\nworld".utf8)
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.column(for: Text.Position(0)) == 1)
        #expect(map.column(for: Text.Position(4)) == 5)
        #expect(map.column(for: Text.Position(6)) == 1)
        #expect(map.column(for: Text.Position(8)) == 3)
    }

    @Test("offset for line")
    func offsetForLine() {
        // "aaa\nbbb\nccc"
        let content: [UInt8] = Array("aaa\nbbb\nccc".utf8)
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.offset(forLine: 1) == Text.Position(0))
        #expect(map.offset(forLine: 2) == Text.Position(4))
        #expect(map.offset(forLine: 3) == Text.Position(8))
        #expect(map.offset(forLine: 0) == nil)
        #expect(map.offset(forLine: 4) == nil)
    }

    @Test("trailing newline adds empty last line")
    func trailingNewline() {
        // "hello\n"
        let content: [UInt8] = Array("hello\n".utf8)
        let map = Source.Manager.LineMap(scanning: content)
        #expect(map.lineCount == 2)
        #expect(map.line(containing: Text.Position(0)) == 1)
        #expect(map.line(containing: Text.Position(6)) == 2)
    }
}

// MARK: - Source.Manager

@Suite("Source.Manager")
struct ManagerTests {
    @Test("empty manager")
    func emptyManager() {
        let manager = Source.Manager()
        #expect(manager.fileCount == 0)
    }

    @Test("register file")
    func registerFile() {
        var manager = Source.Manager()
        let content: [UInt8] = Array("let x = 1".utf8)
        let id = manager.register(path: "main.swift", content: content)
        #expect(manager.fileCount == 1)
        #expect(manager.file(for: id).path == "main.swift")
        #expect(manager.content(for: id) == content)
    }

    @Test("sequential IDs")
    func sequentialIDs() {
        var manager = Source.Manager()
        let id0 = manager.register(path: "a.swift", content: [])
        let id1 = manager.register(path: "b.swift", content: [])
        let id2 = manager.register(path: "c.swift", content: [])
        #expect(id0 < id1)
        #expect(id1 < id2)
        #expect(manager.fileCount == 3)
    }

    @Test("resolve location")
    func resolveLocation() {
        var manager = Source.Manager()
        // "func foo() {\n    return\n}"
        let content: [UInt8] = Array("func foo() {\n    return\n}".utf8)
        let id = manager.register(path: "test.swift", content: content)

        let loc1 = Source.Location(file: id, offset: Text.Position(0))
        let resolved1 = manager.resolve(loc1)
        #expect(resolved1.line == 1)
        #expect(resolved1.column == 1)

        let loc2 = Source.Location(file: id, offset: Text.Position(17))
        let resolved2 = manager.resolve(loc2)
        #expect(resolved2.line == 2)
        #expect(resolved2.column == 5)

        let loc3 = Source.Location(file: id, offset: Text.Position(24))
        let resolved3 = manager.resolve(loc3)
        #expect(resolved3.line == 3)
        #expect(resolved3.column == 1)
    }

    @Test("lazy line map computation")
    func lazyLineMap() {
        var manager = Source.Manager()
        let content: [UInt8] = Array("a\nb\nc".utf8)
        let id = manager.register(path: "test.swift", content: content)

        let map1 = manager.lineMap(for: id)
        #expect(map1.lineCount == 3)

        let map2 = manager.lineMap(for: id)
        #expect(map2.lineCount == 3)
    }

    @Test("multiple files with independent line maps")
    func multipleFiles() {
        var manager = Source.Manager()
        let id0 = manager.register(path: "a.swift", content: Array("line1\nline2".utf8))
        let id1 = manager.register(path: "b.swift", content: Array("only one line".utf8))

        let map0 = manager.lineMap(for: id0)
        let map1 = manager.lineMap(for: id1)
        #expect(map0.lineCount == 2)
        #expect(map1.lineCount == 1)
    }
}
