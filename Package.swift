// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "SwiftTailwind",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "SwiftTailwind", targets: ["SwiftTailwind"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
  ],
  targets: [
    .target(
      name: "SwiftTailwind",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux])),
      ]
    ),
    .testTarget(
      name: "SwiftTailwindTests",
      dependencies: ["SwiftTailwind"]
    ),
  ]
)
