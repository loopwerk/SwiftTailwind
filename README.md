# SwiftTailwind

A Swift package to download and run the [Tailwind CSS](https://tailwindcss.com) CLI from Swift projects. Useful for static site generators, server-side Swift apps, or any Swift project that needs to compile Tailwind CSS.

## Installation

Add SwiftTailwind to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/loopwerk/SwiftTailwind", from: "1.0.0"),
],
targets: [
  .executableTarget(
    name: "YourApp",
    dependencies: ["SwiftTailwind"]
  ),
]
```

## Usage

SwiftTailwind automatically downloads the official [Tailwind CSS standalone CLI](https://tailwindcss.com/blog/standalone-cli) from GitHub. No Node.js or npm required. The binary is cached in `~/.swifttailwind/` so it's only downloaded once per version. Versions 3.x and 4.x are supported.

```swift
import SwiftTailwind

let tailwind = SwiftTailwind(version: "4.2.1")

try await tailwind.run(
  input: "input.css",
  output: "output.css",
  options: .minify
)
```

The standalone CLI bundles first-party plugins (`@tailwindcss/typography`, `@tailwindcss/forms`, `@tailwindcss/aspect-ratio`). Third-party plugins from `node_modules` are also supported.

### Options

- `.minify` - minify the output CSS
- `.watch` - watch for changes and rebuild automatically

## Requirements

- macOS 12+ or Linux
- Swift 5.5+

## Acknowledgements

SwiftTailwind is inspired by (the archived) [SwiftyTailwind](https://github.com/tuist/SwiftyTailwind).

## License

SwiftTailwind is available under the MIT license. See the LICENSE file for more info.
