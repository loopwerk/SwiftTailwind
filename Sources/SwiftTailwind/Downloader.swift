#if canImport(CryptoKit)
  import CryptoKit
#else
  import Crypto
#endif
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking

  extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
      try await withCheckedThrowingContinuation { continuation in
        let task = self.dataTask(with: url) { data, response, error in
          if let error {
            continuation.resume(throwing: error)
          } else if let data, let response {
            continuation.resume(returning: (data, response))
          } else {
            continuation.resume(throwing: SwiftTailwindError.downloadFailed(url.absoluteString))
          }
        }
        task.resume()
      }
    }
  }
#endif

enum Downloader {
  private static var cacheDirectory: URL {
    FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".swifttailwind")
  }

  static func download(version: String) async throws -> String {
    let binaryName = try PlatformDetector.binaryName()
    let versionDir = cacheDirectory
      .appendingPathComponent(version)
    let binaryURL = versionDir.appendingPathComponent(binaryName)

    // Return cached binary if it exists
    if FileManager.default.isExecutableFile(atPath: binaryURL.path) {
      return binaryURL.path
    }

    print("Downloading Tailwind CSS v\(version)...")
    try FileManager.default.createDirectory(at: versionDir, withIntermediateDirectories: true)

    // Download the binary into memory
    guard let downloadURL = URL(string: "https://github.com/tailwindlabs/tailwindcss/releases/download/v\(version)/\(binaryName)") else {
      throw SwiftTailwindError.downloadFailed("Invalid URL for version \(version)")
    }
    let (binaryData, binaryResponse) = try await URLSession.shared.data(from: downloadURL)
    guard (binaryResponse as? HTTPURLResponse)?.statusCode == 200 else {
      throw SwiftTailwindError.downloadFailed(downloadURL.absoluteString)
    }

    // Download and validate checksum before writing to disk
    guard let checksumURL = URL(string: "https://github.com/tailwindlabs/tailwindcss/releases/download/v\(version)/sha256sums.txt") else {
      throw SwiftTailwindError.downloadFailed("Invalid checksum URL for version \(version)")
    }
    let (checksumData, checksumResponse) = try await URLSession.shared.data(from: checksumURL)
    guard (checksumResponse as? HTTPURLResponse)?.statusCode == 200,
          let checksumFile = String(data: checksumData, encoding: .utf8)
    else {
      throw SwiftTailwindError.downloadFailed(checksumURL.absoluteString)
    }

    try validateChecksum(binaryData: binaryData, binaryName: binaryName, checksumFile: checksumFile)

    // Write validated binary to disk
    try binaryData.write(to: binaryURL)

    // Make executable
    try FileManager.default.setAttributes(
      [.posixPermissions: 0o755],
      ofItemAtPath: binaryURL.path
    )

    print("Tailwind CSS v\(version) downloaded to \(binaryURL.path)")
    return binaryURL.path
  }

  static func validateChecksum(binaryData: Data, binaryName: String, checksumFile: String) throws {
    // Find the expected checksum for our binary
    guard let line = checksumFile.components(separatedBy: "\n").first(where: { $0.contains(binaryName) }),
          let expectedHash = line.split(separator: " ").first.map(String.init)
    else {
      return // No checksum found for this binary, skip validation
    }

    let digest = SHA256.hash(data: binaryData)
    let actualHash = digest.map { String(format: "%02x", $0) }.joined()

    if actualHash != expectedHash {
      throw SwiftTailwindError.checksumMismatch
    }
  }
}
