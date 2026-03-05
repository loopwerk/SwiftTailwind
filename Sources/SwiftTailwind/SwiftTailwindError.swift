import Foundation

public enum SwiftTailwindError: LocalizedError, Equatable {
  case unsupportedPlatform
  case downloadFailed(String)
  case checksumMismatch

  public var errorDescription: String? {
    switch self {
      case .unsupportedPlatform:
        return "This platform or architecture is not supported by the Tailwind CSS standalone CLI."
      case .downloadFailed(let url):
        return "Failed to download from \(url)."
      case .checksumMismatch:
        return "Downloaded binary failed checksum validation."
    }
  }
}
