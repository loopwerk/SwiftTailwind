import Foundation

enum PlatformDetector {
  static func binaryName() throws -> String {
    let os = try detectOS()
    let arch = try detectArchitecture()
    let ext = os == "windows" ? ".exe" : ""
    return "tailwindcss-\(os)-\(arch)\(ext)"
  }

  private static func detectOS() throws -> String {
    #if os(macOS)
      return "macos"
    #elseif os(Linux)
      return "linux"
    #elseif os(Windows)
      return "windows"
    #else
      throw SwiftTailwindError.unsupportedPlatform
    #endif
  }

  private static func detectArchitecture() throws -> String {
    #if arch(arm64)
      return "arm64"
    #elseif arch(x86_64)
      return "x64"
    #else
      throw SwiftTailwindError.unsupportedPlatform
    #endif
  }
}
