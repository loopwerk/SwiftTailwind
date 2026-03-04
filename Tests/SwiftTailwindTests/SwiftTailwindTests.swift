@testable import SwiftTailwind
import XCTest

final class ChecksumValidationTests: XCTestCase {
  func testValidChecksum() throws {
    let data = Data("hello world".utf8)
    // SHA256 of "hello world"
    let checksumFile = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9  tailwindcss-macos-arm64\n"

    XCTAssertNoThrow(
      try Downloader.validateChecksum(
        binaryData: data,
        binaryName: "tailwindcss-macos-arm64",
        checksumFile: checksumFile
      )
    )
  }

  func testInvalidChecksum() {
    let data = Data("hello world".utf8)
    let checksumFile = "0000000000000000000000000000000000000000000000000000000000000000  tailwindcss-macos-arm64\n"

    XCTAssertThrowsError(
      try Downloader.validateChecksum(
        binaryData: data,
        binaryName: "tailwindcss-macos-arm64",
        checksumFile: checksumFile
      )
    ) { error in
      XCTAssertEqual(error as? SwiftTailwindError, .checksumMismatch)
    }
  }

  func testMissingChecksumEntry() throws {
    let data = Data("hello world".utf8)
    let checksumFile = "abcdef1234567890  tailwindcss-linux-x64\n"

    // Should not throw when binary name is not in checksum file
    XCTAssertNoThrow(
      try Downloader.validateChecksum(
        binaryData: data,
        binaryName: "tailwindcss-macos-arm64",
        checksumFile: checksumFile
      )
    )
  }

  func testEmptyChecksumFile() throws {
    let data = Data("hello world".utf8)

    XCTAssertNoThrow(
      try Downloader.validateChecksum(
        binaryData: data,
        binaryName: "tailwindcss-macos-arm64",
        checksumFile: ""
      )
    )
  }
}
