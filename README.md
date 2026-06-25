# Source Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Source-location value types for Swift — a `Source` namespace of file-qualified positions, ranges, locations, and a `~Copyable` source manager that owns content and resolves line:column on demand.

---

## Quick Start

`Source` is the vocabulary lexers, parsers, and diagnostic engines use to say *where* something is. Tokens and AST nodes carry a compact `Source.Position` — a file ID plus a byte offset — and never the line:column. Line and column are derived only when a human needs to read them, exactly as swiftc, Clang, and swift-syntax defer that work.

```swift
import Source_Primitives

// The Manager owns all source content; it is the single owner per compilation (~Copyable).
var manager = Source.Manager()

let source = "func foo() {\n    return\n}"
let id = manager.register(
    fileID: "MyModule/main.swift",
    filePath: "/path/to/main.swift",
    content: Array(source.utf8).map(Byte.init)
)

// A token records only file + byte offset — compact and machine-oriented.
let position = Source.Position(file: id, offset: 17)

// Resolve to a display-oriented location (line map computed lazily, once per file).
let location = manager.location(for: position)
print(location)              // MyModule/main.swift:2:5
print(location.line)         // Text.Line.Number(2)
print(location.column)       // Text.Line.Column (1-based, UTF-8 bytes)
```

`Source.Position` answers "which file, and where in that file?" with no line/column. `Source.Location` is the self-contained, human-readable form — `fileID`, optional `filePath`, and a `Text.Location` (line:column) — that needs no manager to display. `Source.Range` marks a half-open `[start, end)` byte extent within one file, the shape used for tokens, AST nodes, and diagnostic highlights:

```swift
import Source_Primitives

let range = Source.Range(file: id, start: 0, count: 4)   // the `func` keyword
print(range.count)                  // Text.Count(4)
print(range.contains(2))            // true
print(range.startPosition)          // file(0):0
```

`Source.File.ID` is a pure identity handle — a sequential integer the manager assigns, with no arithmetic — mirroring swiftc's `BufferID` and Clang's `FileID`. The manager registers files sequentially and never removes them, so a `Source.File.ID` is always a valid index for the run.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-source-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Source Primitives", package: "swift-source-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products. Builds on `Text Primitives` (re-exported: `Text.Position`, `Text.Range`, `Text.Location`, `Text.Line`) and `Byte Primitives` (the `Byte` content element).

| Product | Target | Purpose |
|---------|--------|---------|
| `Source Primitives` | `Sources/Source Primitives/` | The `Source` namespace: `Source.File` and its identity handle `Source.File.ID`; `Source.Position` (file + byte offset); `Source.Range` (file-qualified half-open extent); `Source.Location` (self-contained file + line:column); and `Source.Manager`, the `~Copyable` registry that owns content and resolves locations. |
| `Source Primitives Test Support` | `Tests/Support/` | Re-exports the main target for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
