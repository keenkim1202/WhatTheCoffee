import UIKit
import ImageIO

enum DirectoryType: String {
  case coffee = "coffeeImages"
  case cafe = "cafeImages"
}

/// 사진이 어디에 있는지 정하는 한 곳.
/// 앱 샌드박스에 두면 위젯이 읽지 못하므로 앱 그룹 컨테이너를 쓴다.
enum SharedImageStore {

  static let appGroupID = "group.keen.WhatTheCoffee"

  /// 앱 그룹을 열지 못하는 상황에서도 사진을 잃지 않도록 예전 위치로 물러난다.
  static func directory(for type: DirectoryType) -> URL? {
    let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
      ?? sandboxDirectory
    guard let base else { return nil }

    let directory = base.appendingPathComponent(type.rawValue)
    if !FileManager.default.fileExists(atPath: directory.path) {
      try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    return directory
  }

  static func imageURL(type: DirectoryType, imageName: String) -> URL? {
    return directory(for: type)?.appendingPathComponent(imageName)
  }

  /// maxPixelSize를 주면 그 크기로 줄여서 읽는다.
  /// 위젯은 쓸 수 있는 메모리가 적어 원본을 그대로 펼치면 그리다 만다.
  static func load(type: DirectoryType, imageName: String, maxPixelSize: CGFloat? = nil) -> UIImage? {
    guard let url = imageURL(type: type, imageName: imageName) else { return nil }
    guard let maxPixelSize else { return UIImage(contentsOfFile: url.path) }

    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }

    let options = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
    ] as CFDictionary

    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
    return UIImage(cgImage: cgImage)
  }

  // MARK: - Migration
  /// 예전 기록의 사진은 앱 샌드박스에 있다. 처음 한 번 앱 그룹으로 옮겨야 위젯이 볼 수 있다.
  /// 원본은 지우지 않는다. 옮기다 실패해도 사진이 사라지지 않아야 한다.
  static func migrateFromSandboxIfNeeded() {
    guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil,
          let sandboxDirectory else { return }

    for type in [DirectoryType.coffee, .cafe] {
      let source = sandboxDirectory.appendingPathComponent(type.rawValue)
      guard FileManager.default.fileExists(atPath: source.path),
            let target = directory(for: type),
            target != source else { continue }

      let names = (try? FileManager.default.contentsOfDirectory(atPath: source.path)) ?? []
      for name in names {
        let origin = source.appendingPathComponent(name)
        let destination = target.appendingPathComponent(name)

        // 이미 옮겨둔 것은 다시 쓰지 않는다. 앱이 그 뒤에 고쳐 저장했을 수 있다.
        if !FileManager.default.fileExists(atPath: destination.path) {
          try? FileManager.default.copyItem(at: origin, to: destination)
        }

        // 옮겨진 것이 확인된 뒤에만 원본을 지운다.
        // 사진 한 장이 몇 MB라 두 벌로 두면 기기 용량을 그만큼 두 번 쓴다.
        if fileSize(of: origin) != nil, fileSize(of: origin) == fileSize(of: destination) {
          try? FileManager.default.removeItem(at: origin)
        }
      }
    }
  }

  private static var sandboxDirectory: URL? {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
  }

  private static func fileSize(of url: URL) -> Int? {
    return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.size] as? Int
  }
}
