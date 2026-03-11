# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftTailwind is a Swift package that wraps the Tailwind CSS standalone CLI, allowing Swift projects to compile Tailwind CSS without Node.js. It automatically downloads, caches, and validates the official Tailwind CSS binary.

## Build Commands

```
just build     # swift build
just test      # swift test
just format    # swiftformat -swift-version 5 .
```

Run a single test: `swift test --filter TestName`

## Architecture

The library has five source files in `Sources/SwiftTailwind/`:

- **SwiftTailwind.swift** — Public API. `struct SwiftTailwind` takes a Tailwind version, auto-detects the project root by walking up from `#filePath` to find `Package.swift`, and exposes `run(input:output:options:)` which downloads the binary (if needed) and executes it via `Foundation.Process`.
- **Downloader.swift** — Downloads the Tailwind CLI binary from GitHub releases, validates SHA256 checksum, caches at `~/.swifttailwind/{version}/`, and skips download if cached.
- **PlatformDetector.swift** — Compile-time `#if` detection of OS (macOS/Linux/Windows) and architecture (arm64/x64) to determine the correct binary name.
- **RunOption.swift** — `enum RunOption` maps to CLI flags (`.minify`, `.watch`).
- **SwiftTailwindError.swift** — Error types: `unsupportedPlatform`, `downloadFailed`, `checksumMismatch`, `processError`.

## Code Style

Uses swiftformat with 2-space indentation and `--indentcase true`. All public types conform to `Sendable`. No external dependencies — pure Foundation.
