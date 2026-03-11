import Foundation

public struct SwiftTailwind: Sendable {
  private let version: String
  private let projectRoot: String

  /// Create an instance that auto-downloads the standalone Tailwind CSS CLI.
  /// The binary is cached in `~/.swifttailwind/{version}/`.
  public init(version: String, originFile: StaticString = #filePath) {
    self.version = version
    self.projectRoot = Self.resolveProjectRoot(from: originFile)
  }

  /// Run the Tailwind CSS CLI.
  public func run(input: String, output: String, options: RunOption...) async throws {
    try await run(input: input, output: output, options: options)
  }

  /// Run the Tailwind CSS CLI.
  public func run(input: String, output: String, options: [RunOption]) async throws {
    let binary = try await Downloader.download(version: version)

    let resolvedInput = resolvePath(input)
    let resolvedOutput = resolvePath(output)

    var arguments = ["--input", resolvedInput, "--output", resolvedOutput]
    for option in options {
      arguments.append(contentsOf: option.arguments)
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: binary)
    process.arguments = arguments
    process.currentDirectoryURL = URL(fileURLWithPath: projectRoot)

    try process.run()
    process.waitUntilExit()
  }

  private func resolvePath(_ path: String) -> String {
    if path.hasPrefix("/") {
      return path
    }
    return projectRoot + "/" + path
  }

  private static func resolveProjectRoot(from originFile: StaticString) -> String {
    var url = URL(fileURLWithPath: "\(originFile)").deletingLastPathComponent()
    while url.path != "/" {
      if FileManager.default.fileExists(atPath: url.appendingPathComponent("Package.swift").path) {
        return url.path
      }
      url = url.deletingLastPathComponent()
    }
    // Fallback to current working directory
    return FileManager.default.currentDirectoryPath
  }
}
