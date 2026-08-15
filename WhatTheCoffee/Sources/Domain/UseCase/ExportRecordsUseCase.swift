import Foundation

/// 기록과 사진을 한 덩어리로 묶어 밖으로 내보낸다.
/// 기기에만 있는 자료라 폰을 잃으면 같이 사라진다. 사용자가 스스로 사본을 챙길 수 있어야 한다.
final class ExportRecordsUseCase {

  enum Failure: Error {
    /// 내보낼 기록이 하나도 없음.
    case nothingToExport
  }

  /// 압축 파일과 그 안 폴더의 이름. 같은 날 두 번 내보내면 덮어쓰지만, 날짜가 다르면 남는다.
  private static var archiveName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return "왓더커피 기록 " + formatter.string(from: Date())
  }

  private let cafeRepository: CafeRepositoryProtocol
  private let coffeeRepository: CoffeeRepositoryProtocol

  init(cafeRepository: CafeRepositoryProtocol, coffeeRepository: CoffeeRepositoryProtocol) {
    self.cafeRepository = cafeRepository
    self.coffeeRepository = coffeeRepository
  }

  /// 내보낼 파일을 만들고 그 위치를 돌려준다.
  /// 오래 걸릴 수 있어 호출한 쪽을 막지 않는다. 완료는 메인 큐에서 전달한다.
  func export(completion: @escaping (Result<URL, Error>) -> Void) {
    let cafes = cafeRepository.fetch()
    let coffees = coffeeRepository.fetch()

    DispatchQueue.global(qos: .userInitiated).async {
      let result = Result { try self.makeArchive(cafes: cafes, coffees: coffees) }
      DispatchQueue.main.async { completion(result) }
    }
  }

  private func makeArchive(cafes: [CafeEntity], coffees: [CoffeeEntity]) throws -> URL {
    guard !cafes.isEmpty || !coffees.isEmpty else { throw Failure.nothingToExport }

    // 폴더째 압축하려면 먼저 폴더로 모아야 한다. 끝나면 지운다.
    // 이 폴더 이름이 압축을 풀었을 때 사용자에게 보이는 이름이다.
    // 날짜를 붙여야 여러 번 내보낸 백업을 나란히 두어도 서로 덮어쓰지 않는다.
    let workspace = FileManager.default.temporaryDirectory
      .appendingPathComponent(Self.archiveName, isDirectory: true)
    try? FileManager.default.removeItem(at: workspace)
    try FileManager.default.createDirectory(at: workspace, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: workspace) }

    try writeRecords(cafes: cafes, coffees: coffees, to: workspace)
    try copyImages(cafes: cafes, coffees: coffees, to: workspace)

    return try zip(workspace)
  }

  /// 사람이 열어볼 수 있도록 JSON으로 남긴다. 나중에 다시 읽어 들이기도 이쪽이 쉽다.
  private func writeRecords(cafes: [CafeEntity], coffees: [CoffeeEntity], to directory: URL) throws {
    let formatter = ISO8601DateFormatter()

    let payload: [String: Any] = [
      "exportedAt": formatter.string(from: Date()),
      "cafes": cafes.map { cafe -> [String: Any] in
        var record: [String: Any] = [
          "id": cafe.id,
          "name": cafe.name,
          "rate": cafe.rate,
          "visitDates": cafe.visitDates.map { formatter.string(from: $0) },
          "isClosed": cafe.isClosed
        ]
        record["comment"] = cafe.comment
        record["address"] = cafe.address
        record["latitude"] = cafe.latitude
        record["longitude"] = cafe.longitude
        record["coffeeName"] = cafe.coffeeName
        // 이름만 남기면 같은 이름의 커피가 여럿일 때 어느 것이었는지 되살릴 수 없다.
        record["coffeeId"] = cafe.coffeeId
        return record
      },
      "coffees": coffees.map { ["id": $0.id, "name": $0.name, "date": formatter.string(from: $0.date)] }
    ]

    let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
    try data.write(to: directory.appendingPathComponent("records.json"))
  }

  /// 사진은 기록보다 무겁고 되살릴 수 없다. 한 장이라도 빠지면 안 되므로 이름 그대로 옮긴다.
  ///
  /// 복사 실패를 삼키면 사진이 빠진 파일을 백업이라며 건네게 된다.
  /// 저장 공간이 모자라거나 원본을 못 읽는 상황이 실제로 그렇다. 그래서 실패는 그대로 올린다.
  private func copyImages(cafes: [CafeEntity], coffees: [CoffeeEntity], to directory: URL) throws {
    let targets: [(DirectoryType, [String])] = [
      (.cafe, cafes.map { "cafe_\($0.id).jpg" }),
      (.coffee, coffees.map { "coffee_\($0.id).jpg" })
    ]

    for (type, names) in targets {
      let folder = directory.appendingPathComponent(type.rawValue, isDirectory: true)
      try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

      for name in names {
        // 사진을 넣지 않은 기록도 있다. 없는 것과 못 옮긴 것은 다르다.
        guard let source = SharedImageStore.imageURL(type: type, imageName: name),
              FileManager.default.fileExists(atPath: source.path) else { continue }
        try FileManager.default.copyItem(at: source, to: folder.appendingPathComponent(name))
      }
    }
  }

  /// FileManager의 조정 읽기를 쓰면 별도 압축 라이브러리 없이 폴더를 zip으로 받을 수 있다.
  private func zip(_ directory: URL) throws -> URL {
    var coordinationError: NSError?
    var archived: URL?
    var copyError: Error?

    let coordinator = NSFileCoordinator()
    coordinator.coordinate(readingItemAt: directory, options: [.forUploading], error: &coordinationError) { zipped in
      let destination = FileManager.default.temporaryDirectory
        .appendingPathComponent(Self.archiveName + ".zip")
      try? FileManager.default.removeItem(at: destination)

      do {
        try FileManager.default.copyItem(at: zipped, to: destination)
        archived = destination
      } catch {
        copyError = error
      }
    }

    if let coordinationError { throw coordinationError }
    if let copyError { throw copyError }
    guard let archived else { throw Failure.nothingToExport }
    return archived
  }
}
