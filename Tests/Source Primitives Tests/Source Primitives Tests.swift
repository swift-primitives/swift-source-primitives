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

import Byte_Primitives
import Source_Primitives_Test_Support
import Testing

@testable import Source_Primitives

// MARK: - Source.File.ID

@Suite("Source.File.ID")
struct FileIDTests {
    @Test
    func `equatable`() {
        let a = Source.File.ID(0)
        let b = Source.File.ID(0)
        let c = Source.File.ID(1)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `comparable`() {
        let a = Source.File.ID(0)
        let b = Source.File.ID(1)
        #expect(a < b)
    }

    @Test
    func `hashable`() {
        var set: Set<Source.File.ID> = [Source.File.ID(0), Source.File.ID(0)]
        #expect(set.count == 1)
        set.insert(Source.File.ID(1))
        #expect(set.count == 2)
    }

    @Test
    func `description`() {
        #expect(Source.File.ID(3).description == "file(3)")
    }
}

// MARK: - Source.File

@Suite("Source.File")
struct FileTests {
    @Test
    func `stores id, fileID, and filePath`() {
        let file = Source.File(
            id: Source.File.ID(0),
            fileID: "MyModule/main.swift",
            filePath: "/path/to/main.swift"
        )
        #expect(file.id == Source.File.ID(0))
        #expect(file.fileID == "MyModule/main.swift")
        #expect(file.filePath == "/path/to/main.swift")
    }

    @Test
    func `equatable`() {
        let a = Source.File(id: Source.File.ID(0), fileID: "M/a.swift", filePath: "a.swift")
        let b = Source.File(id: Source.File.ID(0), fileID: "M/a.swift", filePath: "a.swift")
        let c = Source.File(id: Source.File.ID(1), fileID: "M/b.swift", filePath: "b.swift")
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Source.Position

@Suite("Source.Position")
struct PositionTests {
    @Test
    func `stores file and offset`() {
        let pos = Source.Position(file: Source.File.ID(0), offset: 42)
        #expect(pos.file == Source.File.ID(0))
        #expect(pos.offset == 42)
    }

    @Test
    func `equatable`() {
        let a = Source.Position(file: Source.File.ID(0), offset: 10)
        let b = Source.Position(file: Source.File.ID(0), offset: 10)
        let c = Source.Position(file: Source.File.ID(0), offset: 20)
        let d = Source.Position(file: Source.File.ID(1), offset: 10)
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test
    func `hashable`() {
        let a = Source.Position(file: Source.File.ID(0), offset: 10)
        let b = Source.Position(file: Source.File.ID(0), offset: 10)
        let set: Set<Source.Position> = [a, b]
        #expect(set.count == 1)
    }

    @Test
    func `description`() {
        let pos = Source.Position(file: Source.File.ID(2), offset: 42)
        #expect(pos.description == "file(2):42")
    }
}

// MARK: - Source.Location

@Suite("Source.Location")
struct LocationTests {
    @Test
    func `memberwise init`() {
        let location = Source.Location(
            fileID: "MyModule/File.swift",
            filePath: "/path/File.swift",
            position: Text.Location(
                line: 10,
                column: Text.Line.Column(_unchecked: Cardinal(5))
            )
        )
        #expect(location.fileID == "MyModule/File.swift")
        #expect(location.filePath == "/path/File.swift")
        #expect(location.position.line == 10)
    }

    @Test
    func `convenience init with Int line/column`() {
        let location = Source.Location(
            fileID: "MyModule/File.swift",
            line: 10,
            column: 5
        )
        #expect(location.line == 10)
        #expect(location.column == 5)
        #expect(location.filePath == nil)
    }

    @Test
    func `line and column accessors`() {
        let location = Source.Location(
            fileID: "M/F.swift",
            line: 42,
            column: 17
        )
        #expect(location.line == 42)
        #expect(location.column == 17)
    }

    @Test
    func `description`() {
        let location = Source.Location(
            fileID: "MyModule/File.swift",
            line: 10,
            column: 5
        )
        #expect(location.description == "MyModule/File.swift:10:5")
    }

    @Test
    func `comparable — different files`() {
        let a = Source.Location(fileID: "A/a.swift", line: 100, column: 1)
        let b = Source.Location(fileID: "B/b.swift", line: 1, column: 1)
        #expect(a < b)
    }

    @Test
    func `comparable — same file, different lines`() {
        let a = Source.Location(fileID: "M/F.swift", line: 1, column: 99)
        let b = Source.Location(fileID: "M/F.swift", line: 2, column: 1)
        #expect(a < b)
    }

    @Test
    func `comparable — same file and line, different columns`() {
        let a = Source.Location(fileID: "M/F.swift", line: 5, column: 1)
        let b = Source.Location(fileID: "M/F.swift", line: 5, column: 10)
        #expect(a < b)
    }

    @Test
    func `equatable`() {
        let a = Source.Location(fileID: "M/F.swift", line: 5, column: 10)
        let b = Source.Location(fileID: "M/F.swift", line: 5, column: 10)
        let c = Source.Location(fileID: "M/F.swift", line: 5, column: 11)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `hashable`() {
        let a = Source.Location(fileID: "M/F.swift", line: 5, column: 10)
        let b = Source.Location(fileID: "M/F.swift", line: 5, column: 10)
        let set: Set<Source.Location> = [a, b]
        #expect(set.count == 1)
    }
}

// MARK: - Source.Range

@Suite("Source.Range")
struct RangeTests {
    @Test
    func `init from start and end`() {
        let range = Source.Range(file: Source.File.ID(0), start: 10, end: 20)
        #expect(range.file == Source.File.ID(0))
        #expect(range.start == 10)
        #expect(range.end == 20)
    }

    @Test
    func `init from start and count`() {
        let range = Source.Range(file: Source.File.ID(0), start: 10, count: 15)
        #expect(range.end == 25)
    }

    @Test
    func `count`() {
        let range = Source.Range(file: Source.File.ID(0), start: 10, end: 25)
        #expect(range.count == 15)
    }

    @Test
    func `isEmpty`() {
        let empty = Source.Range(file: Source.File.ID(0), start: 10, end: 10)
        let nonEmpty = Source.Range(file: Source.File.ID(0), start: 10, end: 11)
        #expect(empty.isEmpty)
        #expect(!nonEmpty.isEmpty)
    }

    @Test
    func `contains`() {
        let range = Source.Range(file: Source.File.ID(0), start: 10, end: 20)
        #expect(range.contains(10))
        #expect(range.contains(15))
        #expect(!range.contains(20))
        #expect(!range.contains(9))
    }

    @Test
    func `textRange`() {
        let range = Source.Range(file: Source.File.ID(0), start: 10, end: 20)
        let tr = range.textRange
        #expect(tr.start == 10)
        #expect(tr.end == 20)
    }

    @Test
    func `startPosition and endPosition`() {
        let range = Source.Range(file: Source.File.ID(3), start: 10, end: 20)
        #expect(range.startPosition.file == Source.File.ID(3))
        #expect(range.startPosition.offset == 10)
        #expect(range.endPosition.offset == 20)
    }
}

// MARK: - Source.Manager

@Suite("Source.Manager")
struct ManagerTests {
    @Test
    func `empty manager`() {
        let manager = Source.Manager()
        #expect(manager.fileCount() == 0)
    }

    @Test
    func `register file`() {
        var manager = Source.Manager()
        let content: [Byte] = "let x = 1".utf8.map(Byte.init)
        let id = manager.register(
            fileID: "TestModule/main.swift",
            filePath: "main.swift",
            content: content
        )
        #expect(manager.fileCount() == 1)
        #expect(manager.file(for: id).fileID == "TestModule/main.swift")
        #expect(manager.file(for: id).filePath == "main.swift")
        #expect(manager.content(for: id) == content)
    }

    @Test
    func `sequential IDs`() {
        var manager = Source.Manager()
        let id0 = manager.register(fileID: "M/a.swift", filePath: "a.swift", content: [])
        let id1 = manager.register(fileID: "M/b.swift", filePath: "b.swift", content: [])
        let id2 = manager.register(fileID: "M/c.swift", filePath: "c.swift", content: [])
        #expect(id0 < id1)
        #expect(id1 < id2)
        #expect(manager.fileCount() == 3)
    }

    @Test
    func `location resolution`() {
        var manager = Source.Manager()
        // "func foo() {\n    return\n}"
        let content: [Byte] = "func foo() {\n    return\n}".utf8.map(Byte.init)
        let id = manager.register(
            fileID: "TestModule/test.swift",
            filePath: "test.swift",
            content: content
        )

        let pos1 = Source.Position(file: id, offset: .zero)
        let loc1 = manager.location(for: pos1)
        #expect(loc1.line == 1)
        #expect(loc1.column == 1)
        #expect(loc1.fileID == "TestModule/test.swift")

        let pos2 = Source.Position(file: id, offset: 17)
        let loc2 = manager.location(for: pos2)
        #expect(loc2.line == 2)
        #expect(loc2.column == 5)

        let pos3 = Source.Position(file: id, offset: 24)
        let loc3 = manager.location(for: pos3)
        #expect(loc3.line == 3)
        #expect(loc3.column == 1)
    }

    @Test
    func `lazy line map computation`() {
        var manager = Source.Manager()
        let content: [Byte] = "a\nb\nc".utf8.map(Byte.init)
        let id = manager.register(fileID: "M/test.swift", filePath: "test.swift", content: content)

        let map1 = manager.lineMap(for: id)
        #expect(map1.lineCount == 3)

        let map2 = manager.lineMap(for: id)
        #expect(map2.lineCount == 3)
    }

    @Test
    func `multiple files with independent line maps`() {
        var manager = Source.Manager()
        let id0 = manager.register(
            fileID: "M/a.swift",
            filePath: "a.swift",
            content: "line1\nline2".utf8.map(Byte.init)
        )
        let id1 = manager.register(
            fileID: "M/b.swift",
            filePath: "b.swift",
            content: "only one line".utf8.map(Byte.init)
        )

        let map0 = manager.lineMap(for: id0)
        let map1 = manager.lineMap(for: id1)
        #expect(map0.lineCount == 2)
        #expect(map1.lineCount == 1)
    }
}
