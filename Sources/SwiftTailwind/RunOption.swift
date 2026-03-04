public enum RunOption: Hashable, Sendable {
  case minify
  case watch

  var arguments: [String] {
    switch self {
      case .minify: return ["--minify"]
      case .watch: return ["--watch"]
    }
  }
}
